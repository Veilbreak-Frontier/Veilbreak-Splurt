/datum/preference_middleware/loadout/proc/ensure_loadout_preset_structure()
	var/datum/preference/loadout/loadout_pref = GLOB.preference_entries[/datum/preference/loadout]
	var/list/loadout_entries = preferences.read_preference(/datum/preference/loadout)
	if(!loadout_pref.loadout_needs_normalization(loadout_entries))
		return

	var/list/normalized = loadout_pref.normalize_loadout_presets(loadout_entries, preferences)
	var/active_name = preferences.read_preference(/datum/preference/loadout_index)
	if(!istext(active_name) || !(active_name in normalized))
		active_name = "Default"

	preferences.update_preference(loadout_pref, normalized)
	if(preferences.read_preference(/datum/preference/loadout_index) != active_name)
		preferences.update_preference(GLOB.preference_entries[/datum/preference/loadout_index], active_name)

/datum/preference_middleware/loadout/on_new_character(mob/user)
	. = ..()
	ensure_loadout_preset_structure()
	preferences.validate_loadout_index()

/datum/preference_middleware/loadout/New(datum/preferences)
	. = ..()
	action_delegations += list(
		"add_loadout_preset" = PROC_REF(add_loadout_preset),
		"remove_loadout_preset" = PROC_REF(remove_loadout_preset),
		"set_loadout_preset" = PROC_REF(set_loadout_preset),
		"rename_loadout_preset" = PROC_REF(rename_loadout_preset),
	)

/datum/preference_middleware/loadout/proc/add_loadout_preset(list/params, mob/user)
	PRIVATE_PROC(TRUE)
	ensure_loadout_preset_structure()

	var/list/loadout_entries = deep_copy_list(preferences.read_preference(/datum/preference/loadout))

	if (loadout_entries.len >= LOADOUT_MAX_PRESETS)
		return TRUE

	var/loadout_name = params["name"]
	if (!istext(loadout_name) || length(loadout_name) > LOADOUT_MAX_NAME_LENGTH || length(loadout_name) < 1)
		return TRUE

	if (!is_loadout_preset_name(loadout_name))
		return TRUE

	if (islist(loadout_entries[loadout_name]))
		return TRUE

	loadout_entries[loadout_name] = list()
	preferences.update_preference(GLOB.preference_entries[/datum/preference/loadout], loadout_entries)
	preferences.update_preference(GLOB.preference_entries[/datum/preference/loadout_index], loadout_name)
	return TRUE

/datum/preference_middleware/loadout/proc/remove_loadout_preset(list/params, mob/user)
	PRIVATE_PROC(TRUE)
	ensure_loadout_preset_structure()

	var/loadout_name = preferences.read_preference(/datum/preference/loadout_index)
	if(loadout_name == "Default")
		return TRUE

	var/list/loadout_entries = preferences.read_preference(/datum/preference/loadout)

	if (loadout_entries.len <= 1)
		return TRUE

	loadout_entries.Remove(loadout_name)
	preferences.update_preference(GLOB.preference_entries[/datum/preference/loadout], loadout_entries)
	preferences.update_preference(GLOB.preference_entries[/datum/preference/loadout_index], "Default")
	return TRUE

/datum/preference_middleware/loadout/proc/set_loadout_preset(list/params, mob/user)
	PRIVATE_PROC(TRUE)
	ensure_loadout_preset_structure()

	var/loadout_name = params["name"]
	if(!istext(loadout_name) || !is_loadout_preset_name(loadout_name))
		return TRUE

	var/list/loadout_entries = preferences.read_preference(/datum/preference/loadout)

	if(!(loadout_name in loadout_entries))
		if(loadout_name != "Default")
			return TRUE
		var/list/updated = deep_copy_list(loadout_entries)
		updated["Default"] = list()
		preferences.update_preference(GLOB.preference_entries[/datum/preference/loadout], updated)

	preferences.update_preference(GLOB.preference_entries[/datum/preference/loadout_index], loadout_name)
	return TRUE

/datum/preference_middleware/loadout/proc/rename_loadout_preset(list/params, mob/user)
	PRIVATE_PROC(TRUE)
	ensure_loadout_preset_structure()

	var/loadout_name = preferences.read_preference(/datum/preference/loadout_index)
	var/new_loadout_name = params["name"]
	if(!istext(new_loadout_name) || loadout_name == "Default" || !is_loadout_preset_name(new_loadout_name))
		return TRUE

	var/list/loadout_entries = preferences.read_preference(/datum/preference/loadout)

	if(new_loadout_name in loadout_entries)
		return TRUE

	var/datum/preference/loadout/loadout_pref = GLOB.preference_entries[/datum/preference/loadout]
	loadout_entries[new_loadout_name] = loadout_pref.sanitize_loadout_list(loadout_entries[loadout_name], preferences.parent?.mob, preferences.parent)
	loadout_entries.Remove(loadout_name)
	preferences.update_preference(GLOB.preference_entries[/datum/preference/loadout], loadout_entries)
	preferences.update_preference(GLOB.preference_entries[/datum/preference/loadout_index], new_loadout_name)
	return TRUE

/datum/preference_middleware/loadout/proc/get_current_loadout()
	ensure_loadout_preset_structure()
	var/list/loadout_entries = preferences.read_preference(/datum/preference/loadout)
	var/active_name = preferences.get_active_loadout_preset_name()
	var/list/current = loadout_entries[active_name]
	if(!islist(current))
		return list()
	var/datum/preference/loadout/loadout_pref = GLOB.preference_entries[/datum/preference/loadout]
	return loadout_pref.sanitize_loadout_list(current, preferences.parent?.mob, preferences.parent)

/datum/preference_middleware/loadout/proc/save_current_loadout(list/loadout)
	ensure_loadout_preset_structure()
	var/list/loadout_entries = deep_copy_list(preferences.read_preference(/datum/preference/loadout))
	var/active_name = preferences.get_active_loadout_preset_name()
	var/datum/preference/loadout/loadout_pref = GLOB.preference_entries[/datum/preference/loadout]
	loadout_entries[active_name] = loadout_pref.sanitize_loadout_list(loadout, preferences.parent?.mob, preferences.parent)
	var/datum/preference/loadout_index/index_pref = GLOB.preference_entries[/datum/preference/loadout_index]
	if(preferences.read_preference(/datum/preference/loadout_index) != active_name)
		preferences.update_preference(index_pref, active_name)
	preferences.update_preference(GLOB.preference_entries[/datum/preference/loadout], loadout_entries)

/datum/preference_middleware/loadout/proc/action_clear_all(list/params, mob/user)
	save_current_loadout(list())
	return TRUE
