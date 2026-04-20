/**
 * Powers savefile migration.
 * Hooks into the base savefile load/save to persist the `all_powers` list on /datum/preferences.
 * The `all_powers` var itself is declared in powers_prefs.dm.
 */

#define DOPPLER_SAVEFILE_VERSION_MAX 1
#define VERSION_NEW_POWERS 1
#define SHOULD_UPDATE_DOPPLER_DATA(version) (version < DOPPLER_SAVEFILE_VERSION_MAX)

/datum/preferences/proc/get_doppler_savefile_version(list/save_data)
	return save_data?["doppler_version"]

/// Called during load_character() to migrate old savefile data if needed.
/datum/preferences/proc/check_doppler_character_savefile(list/save_data)
	if(isnull(save_data))
		save_data = list()
	var/current_version = get_doppler_savefile_version(save_data)
	if(!SHOULD_UPDATE_DOPPLER_DATA(current_version))
		return
	update_character_doppler(current_version, save_data)

/datum/preferences/proc/update_character_doppler(current_version, list/save_data)
	if(current_version < VERSION_NEW_POWERS)
		nuke_old_powers(save_data)

/// Removes the old powers entry from old savefiles. The new list is keyed under `all_powers` instead.
/datum/preferences/proc/nuke_old_powers(list/save_data)
	if(save_data && ("powers" in save_data))
		save_data -= "powers"
		var/ckey_to_log = parent?.ckey || "unknown"
		log_game("[ckey_to_log]'s powers were migrated over from the old powers system.")

/// Called during save_character() to persist powers data.
/datum/preferences/proc/save_character_doppler(list/save_data)
	save_data["all_powers"] = all_powers
	save_data["doppler_version"] = DOPPLER_SAVEFILE_VERSION_MAX

/// Called during load_character() to read the powers data back.
/datum/preferences/proc/load_character_doppler(list/save_data)
	all_powers = SANITIZE_LIST(save_data?["all_powers"])

#undef DOPPLER_SAVEFILE_VERSION_MAX
#undef VERSION_NEW_POWERS
#undef SHOULD_UPDATE_DOPPLER_DATA
