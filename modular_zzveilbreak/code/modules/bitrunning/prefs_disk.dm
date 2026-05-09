/// Carried into a netpod to apply saved character preferences to the virtual avatar (Bubber).
/obj/item/disk/bitrunning/prefs
	name = "DeForest biological simulation disk"
	desc = "A disk containing the biological simulation data necessary to load custom characters into bitrunning domains."
	icon = 'icons/obj/devices/circuitry_n_data.dmi'
	base_icon_state = "datadisk"
	sticker_icon_state = "o_dna1"
	w_class = WEIGHT_CLASS_SMALL
	/// Also apply job loadout when spawning the avatar
	var/include_loadout = FALSE
	/// Preferences snapshot to transfer (read by quantum server when entering a pod)
	var/datum/preferences/loaded_preference

/obj/item/disk/bitrunning/prefs/Initialize(mapload)
	. = ..()
	var/datum/component/loads_avatar_gear/unused = GetComponent(/datum/component/loads_avatar_gear)
	qdel(unused)

/obj/item/disk/bitrunning/prefs/examine(mob/user)
	. = ..()
	if(!isnull(loaded_preference))
		var/name = loaded_preference.read_preference(/datum/preference/name/real_name)
		. += "It currently has the character [name] loaded, with loadouts [(include_loadout ? "enabled" : "disabled")]"
		. += span_notice("Ctrl-Click to change loadout loading")

/obj/item/disk/bitrunning/prefs/item_ctrl_click(mob/user)
	include_loadout = !include_loadout
	balloon_alert(user, include_loadout ? "Loadout enabled" : "Loadout disabled")

/obj/item/disk/bitrunning/prefs/attack_self(mob/user, modifiers)
	. = ..()

	var/list/prefdata_names = user.client.prefs?.create_character_profiles()
	if(isnull(prefdata_names))
		return

	var/response = tgui_alert(user, message = "Change selected prefs?", title = "Prefchange", buttons = list("Yes", "No"))
	if(isnull(response) || response == "No")
		return
	var/choice = tgui_input_list(user, message = "Select a character", title = "Character selection", items = prefdata_names)
	if(isnull(choice) || !user.is_holding(src))
		return

	loaded_preference = new(user.client)
	loaded_preference.load_character(prefdata_names.Find(choice))

	balloon_alert(user, "character set")
	to_chat(user, span_notice("Character set to [choice] sucessfully!"))

/obj/item/disk/bitrunning/prefs/load_onto_avatar(mob/living/carbon/human/neo, mob/living/carbon/human/avatar, domain_flags)
	return NONE
