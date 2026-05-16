// Oh, I'm sorry, you were looking for GOOD code? Turn around and leave. - Rimi

/datum/preference/loadout_index
	savefile_key = "loadout_index"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE

/datum/preference/loadout_index/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return

/datum/preference/loadout_index/create_informed_default_value(datum/preferences/preferences)
	var/list/loadouts = preferences.read_preference(/datum/preference/loadout)
	if("Default" in loadouts)
		return "Default"
	for(var/name in loadouts)
		return name

/datum/preference/loadout_index/deserialize(input, datum/preferences/preferences)
	if (istext(input))
		var/list/loadouts = preferences.read_preference(/datum/preference/loadout)
		if(input in loadouts)
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
			return name
	return active_name

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
		else if(istext(name))
			has_preset_name = TRUE
	if(has_preset_name)
		return FALSE
	return has_item_path

/datum/preference/loadout/read(list/save_data, datum/preferences/preferences)
	var/value = save_data?[savefile_key]
	if(isnull(value) && islist(save_data))
		value = save_data["loadout_list"]
	if(isnull(value))
		return null
	return deserialize(value, preferences)

/datum/preference/loadout
	savefile_key = "loadout_lists" // Change the savefile key to avoid data corruption if this goes COMPLETELY WRONG during a test merge.

/datum/preference/loadout/deserialize(list/input, datum/preferences/preferences)
	if(!islist(input) || !length(input))
		return create_default_value(preferences)

	var/list/source = is_flat_loadout_structure(input) ? list("Default" = input) : input
	var/datum/preference/loadout/loadout_pref = GLOB.preference_entries[/datum/preference/loadout]
	var/list/output = list()

	for(var/preset_name in source)
		if(!istext(preset_name))
			continue
		var/list/preset_items = source[preset_name]
		if(!islist(preset_items) || is_flat_loadout_structure(preset_items))
			continue
		output[preset_name] = loadout_pref.sanitize_loadout_list(preset_items, preferences.parent?.mob, preferences.parent)

	if(!length(output))
		return create_default_value(preferences)

	return output

/datum/preference/loadout/create_default_value(datum/preferences/preferences)
	return list("Default" = list())

/datum/preference/loadout/compile_ui_data(mob/user, value)
	var/list/data = islist(value) ? value : list()
	var/list/loadout_list = list()
	for(var/key in data)
		loadout_list += key

	var/datum/preferences/prefs = user?.client?.prefs
	var/active_name = prefs?.get_active_loadout_preset_name() || "Default"
	if(!(active_name in data))
		active_name = "Default" in data ? "Default" : (length(loadout_list) ? loadout_list[1] : "Default")

	var/list/active_loadout = data[active_name]
	if (!islist(active_loadout))
		active_loadout = list()

	return list(
		"loadout" = active_loadout,
		"loadouts" = loadout_list,
	)
