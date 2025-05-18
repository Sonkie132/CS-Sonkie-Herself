-- name: [CS] Sonkie Herself! (wip)
-- description: The Tiny Horny (that means she has horns) Half Demon Lady! Thank you to Jer for the model! \n\n\\#ff7777\\This Pack requires Character Select\nto use as a Library!

local TEXT_MOD_NAME = "Sonkie"
local TEXT_VERSION = "3.0"

-- Stops mod from loading if Character Select isn't on
if not _G.charSelectExists then
    djui_popup_create("\\#ffffdc\\\n"..TEXT_MOD_NAME.."\nRequires the Character Select Mod\nto use as a Library!\n\nPlease turn on the Character Select Mod\nand Restart the Room!", 6)
    return 0
end

local E_MODEL_SONKIE = smlua_model_util_get_id("sonkie_geo")
local E_MODEL_SQUISHYPLUSHIE = smlua_model_util_get_id("squishyplushie_geo")

local TEX_SONKIE_ICON = get_texture_info("sonkie-icon")

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

local sonkiepalettes = {
    {
        name = "Default",
        [PANTS]  = "221C1A",
        [SHIRT]  = "793A80",
        [GLOVES] = "221C1A",
        [SHOES]  = "793A80",
        [HAIR]   = "221C1A",
        [SKIN]   = "BFD3FF",
        [CAP]    = "793A80",
        [EMBLEM] = "ffffff"
    },
    {
        name = "Supressed Form",
        [PANTS]  = "221c1a",
        [SHIRT]  = "249fde",
        [GLOVES] = "221c1a",
        [SHOES]  = "249fde",
        [HAIR]   = "221C1A",
        [SKIN]   = "e9b5a3",
        [CAP]    = "221c1a",
        [EMBLEM] = "ffffff"
    },
    {
        name = "Rleased Demon",
        [PANTS]  = "3b1725",
        [SHIRT]  = "b4202a",
        [GLOVES] = "ffffff",
        [SHOES]  = "ffffff",
        [HAIR]   = "3b1725",
        [SKIN]   = "ffffff",
        [CAP]    = "b4202a",
        [EMBLEM] = "ffffff"
    },
    {
        name = "Pretty lady",
        [PANTS] = "221C1A",
        [SHIRT] = "122020",
        [GLOVES] = "FFFFFF",
        [SHOES] = "4A5462",
        [HAIR] = "3B1725",
        [SKIN] = "E9B5A3",
        [CAP] = "221C1A",
        [EMBLEM] = "FFFFFF",
    },
    {
        name = "Game Girl",
        [PANTS]  = "6110a2",
        [SHIRT]  = "9241f3",
        [GLOVES] = "6110a2",
        [SHOES]  = "9241f3",
        [HAIR]   = "6110a2",
        [SKIN]   = "ffffff",
        [CAP]    = "9241f3",
        [EMBLEM] = "ffffff"
    }

}

local ANIMTABLE_SONKIE = {
        [CHAR_ANIM_IDLE_HEAD_CENTER] = 'sonkie_stealed_jess_idle',
        [CHAR_ANIM_IDLE_HEAD_LEFT] = 'sonkie_stealed_jess_idle',
        [CHAR_ANIM_IDLE_HEAD_RIGHT] = 'sonkie_stealed_jess_idle',
        [CHAR_ANIM_RUNNING] = "sonkie_run",
        [CHAR_ANIM_TRIPLE_JUMP] = 'sonkie_spinn',
        [CHAR_ANIM_START_RIDING_SHELL] = 'sonkie_start_riding_shell',
        [CHAR_ANIM_RIDING_SHELL] = 'sonkie_riding_shell',
        [CHAR_ANIM_JUMP_RIDING_SHELL] = 'sonkie_jump_shell',
        [CHAR_ANIM_TRIPLE_JUMP_GROUND_POUND] = "sonkie_spinn",
        [CHAR_ANIM_START_GROUND_POUND] = "sonkie_spinn",
        [CHAR_ANIM_GROUND_POUND] = "sonkie_spinn",
        [charSelect.CS_ANIM_MENU] = "sonkie_menupose",
}

local SONKIE_HEALTH_METER = {
	label = {
		left = get_texture_info("sonkie-hp-left"),
		right = get_texture_info("sonkie-hp-right")
	},
	pie = {
		get_texture_info("sonkie-hp-1"),
		get_texture_info("sonkie-hp-2"),
		get_texture_info("sonkie-hp-3"),
		get_texture_info("sonkie-hp-4"),
		get_texture_info("sonkie-hp-5"),
		get_texture_info("sonkie-hp-6"),
		get_texture_info("sonkie-hp-7"),
		get_texture_info("sonkie-hp-8")
	}
}

if _G.charSelectExists then
    CT_SONKIE = _G.charSelect.character_add("Sonkie", {"The Pretty Half Demon lady is here to collect Some Stars! :3"}, "Model: JerThePear", {r = 121, g = 58, b = 128},  E_MODEL_SONKIE, CT_MARIO, TEX_SONKIE_ICON) 
end

local CSloaded = false
local function on_character_select_load()
    _G.charSelect.character_add_voice(E_MODEL_SONKIE, VOICETABLE_SONKS)
	_G.charSelect.character_add_celebration_star(E_MODEL_SONKIE, E_MODEL_SQUISHYPLUSHIE)
	_G.charSelect.character_add_animations(E_MODEL_SONKIE, ANIMTABLE_SONKIE)
    _G.charSelect.character_add_health_meter(CT_SONKIE, SONKIE_HEALTH_METER)
    _G.charSelect.character_set_category(CT_SONKIE, "Workshop")

    for i = 1, #sonkiepalettes do
        _G.charSelect.character_add_palette_preset(E_MODEL_SONKIE, sonkiepalettes[i], sonkiepalettes[i].name)
    end

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