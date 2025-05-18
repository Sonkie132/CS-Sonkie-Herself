-- description: edited from the king reremake\n\nby king    who tf else you think it was
-- name: template end screen

TEX_CAKE = get_texture_info("sonkie-end")

function render_miku_end()
    if _G.charSelectExists then
        local gSync = gPlayerSyncTable[0]

        local x = djui_hud_get_screen_width() / 2 - TEX_CAKE.width / 2
        local y = djui_hud_get_screen_height() / 2 - TEX_CAKE.height / 2

        if gNetworkPlayers[0].currLevelNum ~= LEVEL_ENDING then
            return
        end

        if _G.charSelect.character_get_current_number() == CT_SONKIE then
            djui_hud_set_color(0, 0, 0, 255)
            djui_hud_render_rect(0, 0, djui_hud_get_screen_width(), djui_hud_get_screen_height())
            djui_hud_set_color(255, 255, 255, 255)

            djui_hud_set_filter(FILTER_LINEAR)
            djui_hud_render_texture(TEX_CAKE, x, y, 1, 1)
        end
    end
end

hook_event(HOOK_ON_HUD_RENDER_BEHIND, function()
    djui_hud_set_resolution(RESOLUTION_N64)
    djui_hud_set_font(FONT_HUD)

    djui_hud_set_color(255, 255, 255, 255)
    render_miku_end()
end)

local function on_thankyou(soundBits, pos)
    if _G.charSelectExists then
        if (_G.charSelect.character_get_current_number() == CT_SONKIE) then
            if (soundBits == SOUND_MENU_THANK_YOU_PLAYING_MY_GAME) then
                local thankYouSound = audio_stream_load("BigNotif.mp3")
                audio_stream_play(thankYouSound, false, 2.0)
                return NO_SOUND
            end
        end
    end
end

hook_event(HOOK_ON_PLAY_SOUND, on_thankyou)

-- thank you code by Baconator2558
-- If you want the original Endscreen used instead of the Miku one, feel free to delete or move this lua file elsewhere
-- description: edited from the king reremake\n\nby king    who tf else you think it was
-- name: template end screen

TEX_CAKE = get_texture_info("sonkie-end")

function render_miku_end()
    if _G.charSelectExists then
        local gSync = gPlayerSyncTable[0]

        local x = djui_hud_get_screen_width() / 2 - TEX_CAKE.width / 2
        local y = djui_hud_get_screen_height() / 2 - TEX_CAKE.height / 2

        if gNetworkPlayers[0].currLevelNum ~= LEVEL_ENDING then
            return
        end

        if _G.charSelect.character_get_current_number() == CT_SONKIE then
            djui_hud_set_color(0, 0, 0, 255)
            djui_hud_render_rect(0, 0, djui_hud_get_screen_width(), djui_hud_get_screen_height())
            djui_hud_set_color(255, 255, 255, 255)

            djui_hud_set_filter(FILTER_LINEAR)
            djui_hud_render_texture(TEX_CAKE, x, y, 1, 1)
        end
    end
end

hook_event(HOOK_ON_HUD_RENDER_BEHIND, function()
    djui_hud_set_resolution(RESOLUTION_N64)
    djui_hud_set_font(FONT_HUD)

    djui_hud_set_color(255, 255, 255, 255)
    render_miku_end()
end)

local function on_thankyou(soundBits, pos)
    if _G.charSelectExists then
        if (_G.charSelect.character_get_current_number() == CT_SONKIE) then
            if (soundBits == SOUND_MENU_THANK_YOU_PLAYING_MY_GAME) then
                local thankYouSound = audio_stream_load("BigNotif.mp3")
                audio_stream_play(thankYouSound, false, 2.0)
                return NO_SOUND
            end
        end
    end
end

hook_event(HOOK_ON_PLAY_SOUND, on_thankyou)

-- thank you code by Baconator2558
-- If you want the original Endscreen used instead of the Miku one, feel free to delete or move this lua file elsewhere
