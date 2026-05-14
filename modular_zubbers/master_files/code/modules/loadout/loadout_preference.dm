// Oh, I'm sorry, you were looking for GOOD code? Turn around and leave. - Rimi

/datum/preference/loadout_index
	savefile_key = "loadout_index"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE

/datum/preference/loadout_index/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return

/datum/preference/loadout_index/create_informed_default_value(datum/preferences/preferences)
	var/list/loadouts = preferences.read_preference(/datum/preference/loadout)
	if (!length(loadouts))
		return "Default"
	// Assoc list of preset name -> item list; numeric [1] is not a preset name.
	for (var/preset_name in loadouts)
		if (istext(preset_name) && islist(loadouts[preset_name]))
			return preset_name
	return "Default"

/datum/preference/loadout_index/deserialize(input, datum/preferences/preferences)
	if (istext(input))
		return input

	return create_informed_default_value(preferences)

/datum/preference/loadout_index/is_valid(value)
	return istext(value)

/datum/preference/loadout
	savefile_key = "loadout_lists" // Change the savefile key to avoid data corruption if this goes COMPLETELY WRONG during a test merge.

// I'm going to flex my cursed modular knowledge now.
/datum/preference/loadout/deserialize(list/input, datum/preferences/preferences)
	for (var/name in input)
		input[name] = ..(input[name], preferences) // ULTIMATE MODULARITY BULLSHIT GO

	return input

/datum/preference/loadout/create_default_value(datum/preferences/preferences)
	return list("Default" = list())

/datum/preference/loadout/compile_ui_data(mob/user, value)
	var/list/data = ..()
	if (!islist(data))
		return list("loadout" = list(), "loadouts" = list())

	var/list/loadout_names = list()
	for (var/preset_name in data)
		UNTYPED_LIST_ADD(loadout_names, preset_name)

	var/datum/preferences/prefs = user?.client?.prefs
	var/index = prefs?.read_preference(/datum/preference/loadout_index)
	if (!istext(index) || !(index in data))
		if ("Default" in data)
			index = "Default"
		else if (length(loadout_names))
			index = loadout_names[1]
		else
			return list("loadout" = list(), "loadouts" = list())

	var/list/current = data[index]
	if (!islist(current))
		current = list()

	return list("loadout" = current, "loadouts" = loadout_names)
