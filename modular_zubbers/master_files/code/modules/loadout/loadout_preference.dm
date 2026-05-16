// Oh, I'm sorry, you were looking for GOOD code? Turn around and leave. - Rimi

/datum/preference/loadout_index
	savefile_key = "loadout_index"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE
	// Must load after /datum/preference/loadout so deserialize does not read an empty default.
	priority = PREFERENCE_PRIORITY_LOADOUT + 1

/datum/preference/loadout_index/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return

/datum/preference/loadout_index/create_informed_default_value(datum/preferences/preferences)
	var/list/loadouts = preferences.read_preference(/datum/preference/loadout)
	if("Default" in loadouts)
		return "Default"
	for(var/name in loadouts)
		return name

/datum/preference/loadout_index/deserialize(input, datum/preferences/preferences)
	if(istext(input) && length(input))
		return input
	return create_informed_default_value(preferences)

/datum/preference/loadout_index/is_valid(value)
	return istext(value)

/// Resolves which named loadout preset is active, with the same fallback rules as the prefs UI.
/datum/preferences/proc/get_active_loadout_preset_name()
	var/list/loadout_entries = read_preference(/datum/preference/loadout)
	var/active_name = read_preference(/datum/preference/loadout_index)
	if(!istext(active_name) || !(active_name in loadout_entries))
		if("Default" in loadout_entries)
			return "Default"
		for(var/name in loadout_entries)
			if(!is_loadout_preset_name(name))
				continue
			return name
	return active_name

/// Valid preset names are plain text keys that are not item typepaths.
/proc/is_loadout_preset_name(name)
	if(!istext(name))
		return FALSE
	var/path = text2path(name)
	return !ispath(path, /obj/item)

/// True when the list is a single-preset item map (legacy flat save) rather than preset names -> item maps.
/datum/preference/loadout/proc/is_flat_loadout_structure(list/input)
	if(!islist(input) || !length(input))
		return FALSE
	var/has_preset_name = FALSE
	var/has_item_path = FALSE
	for(var/name in input)
		var/path = istext(name) ? text2path(name) : name
		if(ispath(path, /obj/item))
			has_item_path = TRUE
		else if(is_loadout_preset_name(name))
			has_preset_name = TRUE
	if(has_preset_name)
		return FALSE
	return has_item_path

/// TRUE when item paths sit beside preset keys and need merging into Default.
/datum/preference/loadout/proc/loadout_needs_normalization(list/input)
	if(!islist(input) || !length(input))
		return FALSE
	if(is_flat_loadout_structure(input))
		return TRUE
	for(var/name in input)
		var/path = istext(name) ? text2path(name) : name
		if(ispath(path, /obj/item))
			return TRUE
	if(!("Default" in input))
		return TRUE
	return FALSE

/datum/preference/loadout/proc/normalize_loadout_presets(list/input, datum/preferences/preferences)
	var/datum/preference/loadout/loadout_pref = GLOB.preference_entries[/datum/preference/loadout]
	if(!islist(input) || !length(input))
		return list("Default" = list())

	if(is_flat_loadout_structure(input))
		return list("Default" = loadout_pref.sanitize_loadout_list(input, preferences.parent?.mob, preferences.parent))

	var/list/orphaned_items = list()
	var/list/output = list()

	for(var/key in input)
		if(!istext(key))
			continue
		var/list/preset_items = input[key]
		if(!islist(preset_items))
			continue
		var/path = text2path(key)
		if(ispath(path, /obj/item))
			orphaned_items[path] = preset_items
			continue
		if(!is_loadout_preset_name(key))
			continue
		if(is_flat_loadout_structure(preset_items))
			continue
		output[key] = loadout_pref.sanitize_loadout_list(preset_items, preferences.parent?.mob, preferences.parent)

	if(length(orphaned_items))
		var/list/default_items = islist(output["Default"]) ? output["Default"] : list()
		for(var/item_path in orphaned_items)
			default_items[item_path] = orphaned_items[item_path]
		output["Default"] = loadout_pref.sanitize_loadout_list(default_items, preferences.parent?.mob, preferences.parent)

	if(!islist(output["Default"]))
		output["Default"] = list()

	if(!length(output))
		return list("Default" = list())

	return output

/datum/preference/loadout/read(list/save_data, datum/preferences/preferences)
	var/value = save_data?[savefile_key]
	if(isnull(value) && islist(save_data))
		value = save_data["loadout_list"]
	if(isnull(value))
		return null
	return deserialize(value, preferences)

/datum/preference/loadout
	savefile_key = "loadout_lists" // Change the savefile key to avoid data corruption if this goes COMPLETELY WRONG during a test merge.
	priority = PREFERENCE_PRIORITY_LOADOUT

/datum/preference/loadout/deserialize(list/input, datum/preferences/preferences)
	return normalize_loadout_presets(input, preferences)

/datum/preference/loadout/create_default_value(datum/preferences/preferences)
	return list("Default" = list())

/datum/preference/loadout/compile_ui_data(mob/user, value)
	var/list/data = islist(value) ? value : list()
	var/list/loadout_list = list()
	for(var/key in data)
		if(is_loadout_preset_name(key))
			loadout_list += key

	var/datum/preferences/prefs = user?.client?.prefs
	var/active_name = prefs?.get_active_loadout_preset_name() || "Default"
	if(!(active_name in data))
		active_name = "Default"

	var/list/active_loadout = data[active_name]
	if(!islist(active_loadout))
		active_loadout = list()

	return list(
		"loadout" = active_loadout,
		"loadouts" = loadout_list,
	)

/// After both loadout prefs are in cache, fix a stale index from older saves.
/datum/preferences/proc/validate_loadout_index()
	var/list/loadout_entries = read_preference(/datum/preference/loadout)
	var/datum/preference/loadout/loadout_pref = GLOB.preference_entries[/datum/preference/loadout]
	if(loadout_pref.loadout_needs_normalization(loadout_entries))
		loadout_entries = loadout_pref.normalize_loadout_presets(loadout_entries, src)
		update_preference(loadout_pref, loadout_entries)

	var/active_name = read_preference(/datum/preference/loadout_index)
	if(!istext(active_name) || !(active_name in loadout_entries))
		update_preference(GLOB.preference_entries[/datum/preference/loadout_index], get_active_loadout_preset_name())
