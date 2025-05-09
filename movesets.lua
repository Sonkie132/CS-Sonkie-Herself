local ACT_SONK_GP = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_ATTACKING | ACT_FLAG_MOVING | ACT_FLAG_AIR)

local gSonkExtraStates = {}
for i = 0, MAX_PLAYERS - 1 do
    gSonkExtraStates[i] = {}
    local s = gSonkExtraStates[i]
    s.sonkDoubleJump = true
    s.sonkSpin = false
end

-- CUSTOM ACTIONS --

function act_sonkie_ground_pound(m)
    play_sound_if_no_flag(m, SOUND_ACTION_THROW, MARIO_ACTION_SOUND_PLAYED)

    set_mario_animation(m, m.actionArg == 0 and MARIO_ANIM_START_GROUND_POUND
                                             or MARIO_ANIM_TRIPLE_JUMP_GROUND_POUND)
    if (m.actionTimer == 0) then
        m.forwardVel = m.forwardVel * 2
        play_character_sound(m, CHAR_SOUND_GROUND_POUND_WAH)
        play_sound(SOUND_ACTION_SPIN, m.marioObj.header.gfx.cameraToObject)
    end
    m.actionTimer = m.actionTimer+1
    
    if is_anim_at_end(m) ~= 0 then
        m.actionTimer = 1
        m.actionState = 1
        play_sound(SOUND_ACTION_SPIN, m.marioObj.header.gfx.cameraToObject)
        set_anim_to_frame(m, 0)
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
                m.vel.y = math.abs(m.vel.y)
                if m.forwardVel < 0 then
                    m.forwardVel = -m.forwardVel
                    m.faceAngle.y = m.faceAngle.y - 32768
                end
                if m.action == ACT_SONK_GP and (m.input & INPUT_Z_DOWN) ~= 0 then
                    set_mario_action(m, ACT_DIVE, 0)
					mario_set_forward_vel(m, 60)
                else
                    set_mario_action(m, ACT_GROUND_POUND_LAND, 0)
                end
            end
        end
        if m.playerIndex == 0 then set_camera_shake_from_hit(SHAKE_GROUND_POUND) end
    elseif stepResult == AIR_STEP_HIT_WALL then
        --if gLevelValues.fixCollisionBugs and gLevelValues.fixCollisionBugsGroundPoundBonks then
        --    -- do nothing
        --else
            mario_set_forward_vel(m, -16)
            -- if (m.vel.y > 0) then
            --     m.vel.y = 0
            -- end

            set_mario_particle_flags(m, PARTICLE_VERTICAL_STAR, false)
            set_mario_action(m, ACT_BACKWARD_AIR_KB, 0)
        --end
    end
    
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
    if m.action == ACT_BACKWARD_AIR_KB and (m.input & INPUT_A_DOWN) ~= 0 then
        s.sonkSpin = true
        m.vel.y = 80
        m.forwardVel = -1
        set_mario_action(m, ACT_TWIRLING, 0)
    end
end

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
        m.forwardVel = 5
        s.sonkDoubleJump = false
    end
    -- reset midair jump
    if m.pos.y == m.floorHeight then
        s.sonkDoubleJump = true
    end
    -- Wings thing
    if m.action == ACT_SPECIAL_TRIPLE_JUMP or m.action == ACT_VERTICAL_WIND or m.action == ACT_TWIRLING then
        m.marioBodyState.capState = MARIO_HAS_WING_CAP_ON
    end
    -- Eyes Stuff
    if m.action == ACT_FREEFALL or m.action == ACT_FREEFALL_LAND or m.action == ACT_DOUBLE_JUMP_LAND or m.action == ACT_FALL_AFTER_STAR_GRAB or m.action == ACT_JUMP_LAND or m.action == ACT_SIDE_FLIP_LAND or m.action == ACT_GROUND_POUND_LAND then
        m.marioBodyState.eyeState = MARIO_EYES_LOOK_DOWN
    end
    if m.action == ACT_DOUBLE_JUMP or m.action == ACT_TRIPLE_JUMP or m.action == ACT_JUMP then
        m.marioBodyState.eyeState = MARIO_EYES_LOOK_UP
    end
    if m.action == ACT_SPECIAL_TRIPLE_JUMP or m.action == ACT_TWIRLING or m.action == ACT_SONK_GP or m.action == ACT_VERTICAL_WIND or m.action == ACT_LEDGE_GRAB or m.action == ACT_FORWARD_ROLLOUT or m.action == ACT_BACKWARDS_ROLLOUT then
        m.marioBodyState.eyeState = MARIO_EYES_DEAD
    end        
    if m.action == ACT_JUMP_KICK or m.action == ACT_KICK or m.action == ACT_PUNCHING or m.action == ACT_MOVE_PUNCHING then
        m.marioBodyState.eyeState = MARIO_EYES_CLOSED
    end     
    -- disable tilt
    if m.action == ACT_WALKING then
        m.marioBodyState.torsoAngle.x = 0
        m.marioBodyState.torsoAngle.z = 0
    end
    -- menu pose (Concept by Wall_E20)
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
    if m.action == ACT_DIVE and m.pos.y > m.floorHeight and m.vel.y < 0 and (m.input & INPUT_Z_PRESSED) ~= 0 then
        m.particleFlags = m.particleFlags | PARTICLE_MIST_CIRCLE
        set_mario_action(m, ACT_VERTICAL_WIND, 0)
        m.forwardVel = m.forwardVel + 3
        m.vel.y = 35
    end
end


_G.charSelect.character_hook_moveset(CT_SONKIE, HOOK_MARIO_UPDATE, sonk_update)
_G.charSelect.character_hook_moveset(CT_SONKIE, HOOK_ON_SET_MARIO_ACTION, sonk_on_set_action)
