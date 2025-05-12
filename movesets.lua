local ACT_SONK_GP = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_ATTACKING | ACT_FLAG_MOVING | ACT_FLAG_AIR)
local ACT_WALL_SLIDE = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_MOVING | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)
local ACT_DIVE_POUND = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_ATTACKING | ACT_FLAG_AIR | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)
local ACT_DIVE_POUND_LAND = allocate_mario_action(ACT_GROUP_STATIONARY | ACT_FLAG_IDLE | ACT_FLAG_ALLOW_FIRST_PERSON | ACT_FLAG_PAUSE_EXIT | ACT_FLAG_SHORT_HITBOX)

local gSonkExtraStates = {}
for i = 0, MAX_PLAYERS - 1 do
    gSonkExtraStates[i] = {}
    local s = gSonkExtraStates[i]
    s.sonkDoubleJump = true
    s.sonkSpin = false
end

-- CUSTOM ACTIONS --

function act_dive_pound(m)
	if m.actionTimer < 2 then
		play_sound(SOUND_ACTION_SPIN, m.marioObj.header.gfx.cameraToObject)
	end
    common_air_action_step(m, ACT_DIVE_POUND_LAND, MARIO_ANIM_START_GROUND_POUND, AIR_STEP_CHECK_LEDGE_GRAB)
    m.actionTimer = m.actionTimer + 5
    m.vel.y = m.vel.y - 30
end

hook_mario_action(ACT_DIVE_POUND, act_dive_pound, INT_GROUND_POUND)

function act_dive_pound_land(m)
    if m.actionTimer < 10 then 
      m.particleFlags = m.particleFlags | PARTICLE_MIST_CIRCLE | PARTICLE_HORIZONTAL_STAR
      play_mario_heavy_landing_sound(m, SOUND_ACTION_TERRAIN_HEAVY_LANDING)
      set_camera_shake_from_hit(SHAKE_GROUND_POUND)
      m.actionTimer = m.actionTimer + 1
      if m.actionTimer > 1 then 
         m.vel.y = 50
         m.forwardVel = 0
         return set_mario_action(m, ACT_FORWARD_ROLLOUT, 0)
      end
    else
      m.actionTimer = 0
    end
end

hook_mario_action(ACT_DIVE_POUND_LAND, act_dive_pound_land, INT_GROUND_POUND)

local function act_wall_slide(m)
    if (m.input & INPUT_A_PRESSED) ~= 0 then
        local rc = set_mario_action(m, ACT_WALL_KICK_AIR, 0)
        m.vel.y = 72.0

        if m.forwardVel < 20.0 then
            m.forwardVel = 20.0
        end
        m.wallKickTimer = 0
        return rc
    end

    -- attempt to stick to the wall a bit. if it's 0, sometimes you'll get kicked off of slightly sloped walls
    mario_set_forward_vel(m, -1.0)

    m.particleFlags = m.particleFlags | PARTICLE_DUST

    play_sound(SOUND_MOVING_TERRAIN_SLIDE + m.terrainSoundAddend, m.marioObj.header.gfx.cameraToObject)
    set_mario_animation(m, MARIO_ANIM_START_WALLKICK)

    if perform_air_step(m, 0) == AIR_STEP_LANDED then
        mario_set_forward_vel(m, 0.0)
        if check_fall_damage_or_get_stuck(m, ACT_HARD_BACKWARD_GROUND_KB) == 0 then
            return set_mario_action(m, ACT_FREEFALL_LAND, 0)
        end
    end

    m.actionTimer = m.actionTimer + 1
    if m.wall == nil and m.actionTimer > 2 then
        mario_set_forward_vel(m, 0.0)
        return set_mario_action(m, ACT_FREEFALL, 0)
    end

    -- gravity
    m.vel.y = m.vel.y + 2

    return 0
end

hook_mario_action(ACT_WALL_SLIDE, act_wall_slide)

function act_sonkie_ground_pound(m)
    play_sound_if_no_flag(m, SOUND_ACTION_THROW, MARIO_ACTION_SOUND_PLAYED)

    set_mario_animation(m, m.actionArg == 0 and MARIO_ANIM_FORWARD_SPINNING
                                             or MARIO_ANIM_TRIPLE_JUMP_GROUND_POUND)
    if (m.actionTimer == 0) then
        --m.forwardVel = m.forwardVel * 2
        play_character_sound(m, CHAR_SOUND_GROUND_POUND_WAH)
        play_sound(SOUND_ACTION_SPIN, m.marioObj.header.gfx.cameraToObject)
    end

    m.vel.y = m.vel.y - 1
    m.forwardVel = m.forwardVel + 0.1
    
    if is_anim_at_end(m) ~= 0 then
        --m.actionTimer = 1
        --m.actionState = 1
        play_sound(SOUND_ACTION_SPIN, m.marioObj.header.gfx.cameraToObject)
        --set_anim_to_frame(m, 0)
    end

    if (m.input & INPUT_NONZERO_ANALOG) ~= 0 then
        intendedDYaw = ((m.intendedYaw - m.faceAngle.y) + 0x8000) % 0x10000 - 0x8000
        intendedMag = m.intendedMag / 32.0;

        m.faceAngle.y = m.faceAngle.y + math.floor(512.0 * sins(intendedDYaw) * intendedMag*3)
    end

    m.vel.x = m.forwardVel*sins(m.faceAngle.y)
    m.vel.z = m.forwardVel*coss(m.faceAngle.y)

    local stepResult = perform_air_step(m, 0)

    if stepResult == AIR_STEP_LANDED then
        if should_get_stuck_in_ground(m) ~= 0 then
            queue_rumble_data_mario(m, 5, 80)
            play_character_sound(m, CHAR_SOUND_OOOF2)
            set_mario_particle_flags(m, PARTICLE_MIST_CIRCLE, false)
            set_mario_action(m, ACT_BUTT_STUCK_IN_GROUND, 0)
        else
            if m.actionTimer == 2 and m.actionState == 2 then
                return set_mario_action(m, ACT_GROUND_POUND_LAND, 0)
            end
            play_mario_heavy_landing_sound(m, SOUND_ACTION_TERRAIN_HEAVY_LANDING)
            if check_fall_damage(m, ACT_HARD_BACKWARD_GROUND_KB) == 0 then
                set_mario_particle_flags(m, (PARTICLE_MIST_CIRCLE | PARTICLE_HORIZONTAL_STAR), false)
                m.vel.y = math.abs(m.vel.y)*0.9
                --[[
                if m.forwardVel < 0 then
                    m.forwardVel = -m.forwardVel
                    m.faceAngle.y = m.faceAngle.y - 32768
                end
                ]]
                if m.action == ACT_SONK_GP and (m.input & INPUT_Z_DOWN) ~= 0 then
                    set_mario_action(m, ACT_DIVE, 0)
                    play_character_sound(m, CHAR_SOUND_HOOHOO)
					mario_set_forward_vel(m, m.forwardVel + 5)
                else
                    set_mario_action(m, ACT_GROUND_POUND_LAND, 0)
                end
            end
        end
        if m.playerIndex == 0 then
            set_camera_shake_from_hit(SHAKE_GROUND_POUND)
        end
    elseif stepResult == AIR_STEP_HIT_WALL then
        mario_set_forward_vel(m, -16)

        set_mario_particle_flags(m, PARTICLE_VERTICAL_STAR, false)
        set_mario_action(m, ACT_BACKWARD_AIR_KB, 0)
    end
    m.actionTimer = m.actionTimer + 1
    
    return false
end

hook_mario_action(ACT_SONK_GP, { every_frame = act_sonkie_ground_pound }, INT_GROUND_POUND_OR_TWIRL)

-- UPDATES --

function sonk_on_set_action(m)
    local s = gSonkExtraStates[m.playerIndex]

    -- ground pound
    if m.action == ACT_GROUND_POUND then
        set_mario_action(m, ACT_SONK_GP, 0)

    end
    -- wall spin
    if m.action == ACT_BACKWARD_AIR_KB and ((m.input & INPUT_A_DOWN) ~= 0 or m.prevAction == ACT_SONK_GP) and m.wall ~= nil then
        s.sonkSpin = true
        m.vel.y = 80
        m.faceAngle.y = atan2s(m.wall.normal.z, m.wall.normal.x)
        set_mario_action(m, ACT_TWIRLING, 0)
    end
    -- wall slide
    if m.action == ACT_SOFT_BONK then
        m.faceAngle.y = m.faceAngle.y + 0x8000
        set_mario_action(m, ACT_WALL_SLIDE, 0)
        m.vel.x = 0
        m.vel.y = 0
        m.vel.z = 0
    end
end

local actCapStates = {
    [ACT_SPECIAL_TRIPLE_JUMP] = MARIO_HAS_WING_CAP_ON,
    [ACT_TRIPLE_JUMP] = MARIO_HAS_WING_CAP_ON,
    [ACT_VERTICAL_WIND] = MARIO_HAS_WING_CAP_ON,
    [ACT_TWIRLING] = MARIO_HAS_WING_CAP_ON,
    [ACT_DIVE] = MARIO_HAS_WING_CAP_ON,
}

local actEyeStates = {
    -- Look Down
    [ACT_FREEFALL] = MARIO_EYES_LOOK_DOWN,
    [ACT_FREEFALL_LAND] = MARIO_EYES_LOOK_DOWN,
    [ACT_DOUBLE_JUMP_LAND] = MARIO_EYES_LOOK_DOWN,
    [ACT_FALL_AFTER_STAR_GRAB] = MARIO_EYES_LOOK_DOWN,
    [ACT_JUMP_LAND] = MARIO_EYES_LOOK_DOWN,
    [ACT_SIDE_FLIP_LAND] = MARIO_EYES_LOOK_DOWN,
    [ACT_GROUND_POUND_LAND] = MARIO_EYES_LOOK_DOWN,
    [ACT_WALL_KICK_AIR] = MARIO_EYES_LOOK_DOWN,
    -- Look Up
    [ACT_DOUBLE_JUMP] = MARIO_EYES_LOOK_UP,
    [ACT_STAR_DANCE_NO_EXIT] = MARIO_EYES_LOOK_UP,
    [ACT_FLYING_TRIPLE_JUMP] = MARIO_EYES_LOOK_UP,
    [ACT_FLYING] = MARIO_EYES_LOOK_UP,
    [ACT_BACKFLIP] = MARIO_EYES_LOOK_UP,
    [ACT_LEDGE_GRAB] = MARIO_EYES_LOOK_UP,
    -- Look Dead
    [ACT_SPECIAL_TRIPLE_JUMP] = MARIO_EYES_DEAD,
    [ACT_TRIPLE_JUMP] = MARIO_EYES_DEAD,
    [ACT_TWIRLING] = MARIO_EYES_DEAD,
    [ACT_SONK_GP] = MARIO_EYES_DEAD,
    [ACT_VERTICAL_WIND] = MARIO_EYES_DEAD,
    [ACT_FORWARD_ROLLOUT] = MARIO_EYES_DEAD,
    [ACT_BACKWARD_ROLLOUT] = MARIO_EYES_DEAD,
    [ACT_TWIRL_LAND] = MARIO_EYES_DEAD,
    [ACT_GROUND_BONK] = MARIO_EYES_DEAD,
    [ACT_BACKWARD_GROUND_KB] = MARIO_EYES_DEAD,
    [ACT_HARD_BACKWARD_GROUND_KB] = MARIO_EYES_DEAD,
    [ACT_HARD_BACKWARD_GROUND_KB] = MARIO_EYES_DEAD,
    [16910512] = MARIO_EYES_DEAD,
    -- Look Right
    [ACT_TURNING_AROUND] = MARIO_EYES_LOOK_RIGHT,
    -- Look Closed
    [ACT_JUMP_KICK] = MARIO_EYES_CLOSED,
    [ACT_PUNCHING] = MARIO_EYES_CLOSED,
    [ACT_MOVE_PUNCHING] = MARIO_EYES_CLOSED,
    [ACT_TRIPLE_JUMP_LAND] = MARIO_EYES_CLOSED,
    [ACT_SOFT_BONK] = MARIO_EYES_CLOSED,
    [ACT_LONG_JUMP] = MARIO_EYES_CLOSED,
}

local actHandStates = {
    [ACT_FREEFALL] = MARIO_HAND_OPEN,
    [ACT_FREEFALL_LAND] = MARIO_HAND_OPEN,
    [ACT_LONG_JUMP] = MARIO_HAND_OPEN,
    [ACT_DIVE] = MARIO_HAND_OPEN,
    [ACT_TRIPLE_JUMP_LAND] = MARIO_HAND_OPEN,
    [ACT_DOUBLE_JUMP_LAND] = MARIO_HAND_OPEN,
    [ACT_FALL_AFTER_STAR_GRAB] = MARIO_HAND_OPEN,
    [ACT_JUMP_LAND] = MARIO_HAND_OPEN,
    [ACT_SIDE_FLIP_LAND] = MARIO_HAND_OPEN,
    [ACT_GROUND_POUND_LAND] = MARIO_HAND_OPEN,
    [ACT_WALL_KICK_AIR] = MARIO_HAND_OPEN,
    [ACT_SLIDE_KICK_SLIDE] = MARIO_HAND_OPEN,
    [ACT_SLIDE_KICK] = MARIO_HAND_OPEN,
    [ACT_DOUBLE_JUMP] = MARIO_HAND_OPEN,
    [ACT_TRIPLE_JUMP] = MARIO_HAND_OPEN,
    [ACT_BACKFLIP] = MARIO_HAND_OPEN,
}

function sonk_update(m)
    local s = gSonkExtraStates[m.playerIndex]

    m.peakHeight = m.pos.y -- no fall damage

    -- midair jump
    local shouldMidairJump = (m.action == ACT_JUMP or m.action == ACT_DOUBLE_JUMP or m.action == ACT_HOLD_JUMP or m.action == ACT_LONG_JUMP or m.action == ACT_FREEFALL or m.action == ACT_WALL_KICK_AIR or m.action == ACT_BACKFLIP or m.action == ACT_SIDE_FLIP) and ((m.input & INPUT_A_PRESSED) ~= 0 and m.vel.y < 4)
    
    if shouldMidairJump and s.sonkDoubleJump == true then
        m.faceAngle.y = m.intendedYaw
        m.particleFlags = m.particleFlags | PARTICLE_MIST_CIRCLE
        set_mario_action(m, ACT_SPECIAL_TRIPLE_JUMP, 0)
        m.vel.y = 50
        --m.forwardVel = 5
        s.sonkDoubleJump = false
    end
    -- reset midair jump
    if m.pos.y == m.floorHeight then
        s.sonkDoubleJump = true
    end

    -- Cap, Wing, and Hand States
    if actCapStates[m.action] then
        m.marioBodyState.capState = actCapStates[m.action]
    end
    if actEyeStates[m.action] then
        m.marioBodyState.eyeState = actEyeStates[m.action]
    end
    if actHandStates[m.action] then
        m.marioBodyState.handState = actHandStates[m.action]
    end      

    -- Dive Pound
    if m.action == ACT_DIVE or m.action == ACT_VERTICAL_WIND then
        if m.vel.y < 0 and (m.input & INPUT_Z_PRESSED) ~= 0 then
            set_mario_action(m, ACT_DIVE_POUND, 0)
     end
end

    -- disable tilt
    if m.action == ACT_WALKING then
        m.marioBodyState.torsoAngle.x = 0
        m.marioBodyState.torsoAngle.z = 0
    end

    if m.marioObj.header.gfx.animInfo.animID == charSelect.CS_ANIM_MENU then
        m.marioBodyState.eyeState = MARIO_EYES_LOOK_LEFT
    end

    -- wall spin
    if s.sonkSpin == true and m.action == ACT_TWIRLING then
        if m.vel.y < 10 then
            set_mario_action(m, ACT_FREEFALL, 0)
            s.sonkSpin = false
        end
    end

    -- wind
    if m.action == ACT_DIVE then
        if m.vel.y < 0 and (m.input & INPUT_A_PRESSED) ~= 0 then
            m.particleFlags = m.particleFlags | PARTICLE_MIST_CIRCLE
            set_mario_action(m, ACT_VERTICAL_WIND, 0)
            m.forwardVel = m.forwardVel + 3
            m.vel.y = 35
        end
        --[[
        if (m.input & INPUT_Z_PRESSED) ~= 0 then
            set_mario_action(m, ACT_SONK_GP, 0)
        end
        ]]
    end
end


_G.charSelect.character_hook_moveset(CT_SONKIE, HOOK_MARIO_UPDATE, sonk_update)
_G.charSelect.character_hook_moveset(CT_SONKIE, HOOK_ON_SET_MARIO_ACTION, sonk_on_set_action)
