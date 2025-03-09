-- name: [CS] Sonkie Himself 2.0
-- description: The dude whit the weirdest hair shape ever. Thank you to Pizizito morishiko and jerthepear for the model! \n\n\\#ff7777\\This Pack requires Character Select\nto use as a Library!

--[[
    API Documentation for Character Select can be found below:
    https://github.com/Squishy6094/character-select-coop/wiki/API-Documentation

    Use this if you're curious on how anything here works >v<
	(This is an edited version of the Template File by Squishy)
]]

local TEXT_MOD_NAME = "Sonkie Himself"

-- Stops mod from loading if Character Select isn't on
if not _G.charSelectExists then
    djui_popup_create("\\#ffffdc\\\n"..TEXT_MOD_NAME.."\nRequires the Character Select Mod\nto use as a Library!\n\nPlease turn on the Character Select Mod\nand Restart the Room!", 6)
    return 0
end

local E_MODEL_SONKS = smlua_model_util_get_id("sonks_geo") -- Located in "actors"

local SONKS_OFFSET = 0

local TEX_SONKS_ICON = get_texture_info("sonks-icon") -- Located in "textures"

-- All Located in "sound" Name them whatever you want. Remember to include the .ogg extension
local VOICETABLE_SONKS = {
    [CHAR_SOUND_ATTACKED] = 'Sonks_ay.ogg',
	[CHAR_SOUND_OKEY_DOKEY] = 'Sonks_holos.ogg',-- Starting game
	[CHAR_SOUND_LETS_A_GO] = 'Sonks_presionastartpendejo.ogg', -- Starting level
    [CHAR_SOUND_COUGHING3] = 'Sonks_coughing.ogg',
    [CHAR_SOUND_DOH] = 'Sonks_hep.ogg',
    [CHAR_SOUND_DROWNING] = 'Sonks_Drowing.ogg',
    [CHAR_SOUND_DYING] = '1down.ogg',
    [CHAR_SOUND_EEUH] = 'Sonks_hap.ogg',
    [CHAR_SOUND_GROUND_POUND_WAH] = 'Sonks_hop.ogg',
    [CHAR_SOUND_HAHA] = 'Sonks_joya.ogg',
    [CHAR_SOUND_HAHA_2] = 'Sonks_nice.ogg',
    [CHAR_SOUND_HERE_WE_GO] = 'Sonks_nice.ogg',
    [CHAR_SOUND_HOOHOO] = 'Sonks_hop.ogg',
    [CHAR_SOUND_HRMM] = 'Sonks_hap.ogg',
    [CHAR_SOUND_MAMA_MIA] = 'Sonks_Verga.ogg',
    [CHAR_SOUND_ON_FIRE] = 'Sonks_onfire.ogg',
    [CHAR_SOUND_OOOF] = 'Sonks_ouch.ogg',
    [CHAR_SOUND_OOOF2] = 'Sonks_ouch.ogg',
    [CHAR_SOUND_PUNCH_HOO] = 'Sonks_haaa!.ogg',
    [CHAR_SOUND_PUNCH_WAH] = 'Sonks_hop.ogg',
    [CHAR_SOUND_PUNCH_YAH] = 'Sonks_yah.ogg',
    [CHAR_SOUND_SO_LONGA_BOWSER] = 'Sonks_talkaboutlow.mp3',
    [CHAR_SOUND_TWIRL_BOUNCE] = 'Sonks_wohoo.ogg',
    [CHAR_SOUND_UH] = 'Sonks_ay.ogg',
    [CHAR_SOUND_UH2] = 'Sonks_ay.ogg',
    [CHAR_SOUND_UH2_2] = 'Sonks_ay.ogg',
    [CHAR_SOUND_WAAAOOOW] = 'Sonks_conooooo.ogg',
    [CHAR_SOUND_WHOA] = 'Sonks_wow.ogg',
    [CHAR_SOUND_YAHOO] = 'Sonks_Yahoo.ogg',
    [CHAR_SOUND_YAHOO_WAHA_YIPPEE] = {'Sonks_yupiiiii.ogg', 'Sonks_wahaa.ogg', 'Sonks_Yahoo.ogg'},
    [CHAR_SOUND_YAH_WAH_HOO] = 'Sonks_yah.ogg',
}

local PALETTE_SONKS = {
    [PANTS]  = "221c1a",
    [SHIRT]  = "249fde",
    [GLOVES] = "ffffff",
    [SHOES]  = "221c1a",
    [HAIR]   = "221c1a",
    [SKIN]   = "e9b5a3",
    [CAP]    = "221c1a",
	[EMBLEM] = "221c1a"
}

local ANIMTABLE_SONKS = {
            [CHAR_ANIM_IDLE_HEAD_CENTER] = 'sonks_center',
            [CHAR_ANIM_IDLE_HEAD_LEFT] = 'sonks_center',
            [CHAR_ANIM_IDLE_HEAD_RIGHT] = 'sonks_center',
	    [CHAR_ANIM_RETURN_FROM_STAR_DANCE] = 'sonks_fast_ledge_grab',
            [CHAR_ANIM_RUNNING] = 'sonks_run',
}

if _G.charSelectExists then
    CT_SONKS = _G.charSelect.character_add("Sonkie", {"The dude who has the weirdest hair shape ever"}, "Model: Pizizito Model fixes: Morishiko, JairThePear", {r = 92, g = 190, b = 255},  E_MODEL_SONKS, CT_LUIGI, TEX_SONKS_ICON, 1.0, SONKS_OFFSET) 
end

local CSloaded = false
local function on_character_select_load()
    _G.charSelect.character_add_voice(E_MODEL_SONKS, VOICETABLE_SONKS)
	_G.charSelect.character_add_celebration_star(E_MODEL_SONKS, E_MODEL_WOODEN_SIGNPOST)
	_G.charSelect.character_add_palette_preset(E_MODEL_SONKS, PALETTE_SONKS)
	_G.charSelect.character_add_animations(E_MODEL_SONKS, ANIMTABLE_SONKS)

    CSloaded = true
end

local function on_character_sound(m, sound)
    if not CSloaded then return end
    if _G.charSelect.character_get_voice(m) == VOICETABLE_SONKS then return _G.charSelect.voice.sound(m, sound) end
end

local function on_character_snore(m)
    if not CSloaded then return end
    if _G.charSelect.character_get_voice(m) == VOICETABLE_SONKS then return _G.charSelect.voice.snore(m) end
end

hook_event(HOOK_ON_MODS_LOADED, on_character_select_load)
hook_event(HOOK_CHARACTER_SOUND, on_character_sound)
hook_event(HOOK_MARIO_UPDATE, on_character_snore)

local function menupose(m)
if _G.charSelect.is_menu_open() and
 CT_SONKS == _G.charSelect.character_get_current_number() and m.playerIndex == 0  then
	smlua_anim_util_set_animation(m.marioObj, "sonkie_menupose")
	m.marioBodyState.eyeState = 4
	m.marioBodyState.handState = MARIO_HAND_OPEN
	end
end

hook_event(HOOK_MARIO_UPDATE, menupose)




hook_event(HOOK_MARIO_UPDATE, menupose)
