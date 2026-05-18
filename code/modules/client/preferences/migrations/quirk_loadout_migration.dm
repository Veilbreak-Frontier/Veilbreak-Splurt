/**
 * Move quirk items into loadout items
 *
 * If this is accompanied with removal of a quirk,
 * you don't need to worry about handling that here -
 * quirk sanitization happens AFTER migration
 */
/datum/preferences/proc/migrate_quirk_to_loadout(quirk_to_migrate, new_typepath, list/data_to_migrate)
	ASSERT(istext(quirk_to_migrate) && ispath(new_typepath, /obj/item))
	if(quirk_to_migrate in all_quirks)
		add_loadout_item(new_typepath, data_to_migrate)

/// Helper for slotting in a new loadout item
/datum/preferences/proc/add_loadout_item(typepath, list/data = list())
	PRIVATE_PROC(TRUE)

	var/list/loadout_entries = read_preference(/datum/preference/loadout) || list("Default" = list())
	var/active_name = get_active_loadout_preset_name()

	var/list/loadout_list = loadout_entries[active_name]
	if(!islist(loadout_list))
		loadout_list = list()

	loadout_list[typepath] = islist(data) ? data : list()
	loadout_entries[active_name] = loadout_list
	write_preference(GLOB.preference_entries[/datum/preference/loadout], loadout_entries)

/// Helper for removing a loadout item
/datum/preferences/proc/remove_loadout_item(typepath)
	PRIVATE_PROC(TRUE)

	var/list/loadout_entries = read_preference(/datum/preference/loadout)
	if(!islist(loadout_entries))
		return

	var/active_name = get_active_loadout_preset_name()

	var/list/loadout_list = loadout_entries[active_name]
	if(loadout_list?.Remove(typepath))
		write_preference(GLOB.preference_entries[/datum/preference/loadout], loadout_entries)
