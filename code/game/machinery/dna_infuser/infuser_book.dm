
/obj/item/tgui_book/manual/infuser
	name = "\improper DNA infusion book"
	desc = "An entire book on how to not turn yourself into a fly mutant."
	w_class = WEIGHT_CLASS_TINY

	ui_name = "InfuserBook"

/obj/item/tgui_book/manual/infuser/ui_static_data(mob/user)
	var/list/data = list()
	// Collect all info from each intry.
	var/list/entry_data = list()
	for(var/datum/infuser_entry/entry as anything in assoc_to_values(GLOB.infuser_entries))
		if(entry.tier == DNA_MUTANT_UNOBTAINABLE)
			continue
		var/list/individual_entry_data = list()
		individual_entry_data["name"] = entry.name
		individual_entry_data["infuse_mob_name"] = entry.infuse_mob_name
		individual_entry_data["desc"] = entry.desc
		individual_entry_data["threshold_desc"] = entry.threshold_desc
		individual_entry_data["qualities"] = entry.qualities
		individual_entry_data["tier"] = entry.tier
		entry_data += list(individual_entry_data)
	data["entries"] = entry_data
	return data

// VEILBREAK/SPLURT fork sync: procs present in fork but missing from upstream (auto-restored)
/obj/item/infuser_book/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "InfuserBook")
		ui.open()
		playsound(src, SFX_PAGE_TURN, 30, TRUE)

/obj/item/infuser_book/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(action == "play_flip_sound")
		playsound(src, SFX_PAGE_TURN, 30, TRUE)

/obj/item/infuser_book/ui_static_data(mob/user)
	var/list/data = list()
	// Collect all info from each intry.
	var/list/entry_data = list()
	for(var/datum/infuser_entry/entry as anything in assoc_to_values(GLOB.infuser_entries))
		if(entry.tier == DNA_MUTANT_UNOBTAINABLE)
			continue
		var/list/individual_entry_data = list()
		individual_entry_data["name"] = entry.name
		individual_entry_data["infuse_mob_name"] = entry.infuse_mob_name
		individual_entry_data["desc"] = entry.desc
		individual_entry_data["threshold_desc"] = entry.threshold_desc
		individual_entry_data["qualities"] = entry.qualities
		individual_entry_data["tier"] = entry.tier
		entry_data += list(individual_entry_data)
	data["entries"] = entry_data
	return data
