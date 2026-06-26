#define BLOOPER_CONFIG_PATH "[global.config.directory]/bloopers"
#define BLOOPER_SOUND_FALLBACK_PATH "modular_zzplurt/sound/voice/barks"

SUBSYSTEM_DEF(blooper)
	name = "Blooper"
	flags = SS_NO_FIRE | SS_NO_INIT

	var/list/blooper_list

/datum/controller/subsystem/blooper/OnConfigLoad()
	blooper_list = initialize_blooper_datums()
	var/datum/preference/choiced/blooper/blooper_pref = GLOB.preference_entries[/datum/preference/choiced/blooper]
	if(blooper_pref)
		blooper_pref.cached_values = null

/datum/controller/subsystem/blooper/proc/initialize_blooper_datums()
	var/list/blooper_datums = list()
	if(!rustg_file_exists("[BLOOPER_CONFIG_PATH]/blooper_config.json"))
		logger.Log(LOG_CATEGORY_DEBUG, "blooper_config.json not found.")
		return blooper_datums
	var/list/blooper_entries = safe_json_decode(rustg_file_read("[BLOOPER_CONFIG_PATH]/blooper_config.json"))
	if(isnull(blooper_entries))
		stack_trace("Blooper config is malformed!")
		return blooper_datums
	for(var/entry in blooper_entries)
		// These fields are required
		if(isnull(entry["name"]) || isnull(entry["id"]) || isnull(entry["files"]) || !length(entry["files"]))
			stack_trace("Blooper config entry was missing required field!")
			continue
		var/datum/blooper/new_blooper = new()
		new_blooper.name = entry["name"]
		new_blooper.id = entry["id"]
		for(var/file in entry["files"])
			var/sound_path = "[BLOOPER_CONFIG_PATH]/[file]"
			if(!rustg_file_exists(sound_path))
				sound_path = "[BLOOPER_SOUND_FALLBACK_PATH]/[file]"
				if(!rustg_file_exists(sound_path))
					continue
			new_blooper.soundpath_list += sound(sound_path)
		if(!length(new_blooper.soundpath_list))
			logger.Log(LOG_CATEGORY_DEBUG, "Blooper \"[entry["id"]]\" skipped: no sound files found.")
			continue
		new_blooper.min_pitch = entry["min_pitch"] || BLOOPER_DEFAULT_MINPITCH
		new_blooper.max_pitch = entry["max_pitch"] || BLOOPER_DEFAULT_MAXPITCH
		new_blooper.min_vary = entry["min_vary"] || BLOOPER_DEFAULT_MINVARY
		new_blooper.max_vary = entry["max_vary"] || BLOOPER_DEFAULT_MAXVARY
		new_blooper.min_speed = entry["min_speed"] || BLOOPER_DEFAULT_MINSPEED
		new_blooper.max_speed = entry["max_speed"] || BLOOPER_DEFAULT_MAXSPEED
		blooper_datums[new_blooper.id] = new_blooper
	return blooper_datums

#undef BLOOPER_CONFIG_PATH
#undef BLOOPER_SOUND_FALLBACK_PATH
