local sonkDoubleJump = true
local sonkSpin = false
local ACT_SONK_GP = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_ATTACKING | ACT_FLAG_MOVING | ACT_FLAG_AIR)

function sonks_update(m)
    m.peakHeight = m.pos.y -- no fall damage

    if m.playerIndex == 0 then -- always capless
        m.flags = m.flags & ~(MARIO_NORMAL_CAP | MARIO_CAP_ON_HEAD)
    end

    -- midair jump
    local shouldMidairJump = (m.action == ACT_JUMP or m.action == ACT_DOUBLE_JUMP or m.action == ACT_HOLD_JUMP or m.action == ACT_LONG_JUMP or m.action == ACT_DIVE or m.action == ACT_FREEFALL) and ((m.input & INPUT_A_PRESSED) ~= 0 and m.vel.y < 4)
    if shouldMidairJump and sonkDoubleJump == true then
        m.faceAngle.y = m.intendedYaw
        m.particleFlags = m.particleFlags | PARTICLE_MIST_CIRCLE
        set_mario_action(m, ACT_TRIPLE_JUMP, 0)
        m.vel.y = 50
        if m.input & INPUT_NONZERO_ANALOG ~= 0 or m.forwardVel > 45 then
            m.forwardVel = 45
        end
        sonkDoubleJump = false
    end
    -- reset midair jump
    if m.pos.y == m.floorHeight then
        sonkDoubleJump = true
    end
    -- wall bump to spin
    if m.action == ACT_BACKWARD_AIR_KB and (m.input & INPUT_A_DOWN) ~= 0 then
        sonkSpin = true
        m.vel.y = 80
        m.forwardVel = -1
        set_mario_action(m, ACT_TWIRLING, 0)
    end
    if sonkSpin == true and m.action == ACT_TWIRLING then
        if m.vel.y < 10 then
            set_mario_action(m, ACT_FREEFALL, 0)
            sonkSpin = false
        end
    end
end

function sonks_on_set_action(m)
    -- ground pound
    if m.action == ACT_GROUND_POUND then
        set_mario_action(m, ACT_SONK_GP, 0)
    end
    -- long jump from slide
    if m.action == ACT_FORWARD_ROLLOUT and (m.input & INPUT_A_PRESSED) ~= 0 then
        set_mario_action(m, ACT_LONG_JUMP, 0)
    end
end

---@param m MarioState
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
_G.charSelect.character_hook_moveset(CT_SONKS, HOOK_MARIO_UPDATE, sonks_update)
_G.charSelect.character_hook_moveset(CT_SONKS, HOOK_ON_SET_MARIO_ACTION, sonks_on_set_action)
