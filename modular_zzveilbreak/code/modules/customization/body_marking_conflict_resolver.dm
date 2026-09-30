/*
This file resolves duplicate body_marking names across upstream modules by renaming conflicting entries to Name (ModuleTag) at runtime.
It also rebuilds GLOB.body_markings_per_limb and remaps GLOB.body_marking_sets so every definition stays reachable and correctly attributed.
*/

#define MARKING_MODULE_VEILBREAK "Veilbreak"
#define MARKING_MODULE_SPLURT    "Splurt"
#define MARKING_MODULE_BUBBER    "Bubber"
#define MARKING_MODULE_SKYRAT    "Skyrat"
#define MARKING_MODULE_CORE      "Core"

GLOBAL_VAR_INIT(body_marking_conflicts_resolved, FALSE)

/// Force execution at world boot to guarantee global lists are rebuilt before clients connect
/world/New()
	. = ..()
	resolve_body_marking_name_conflicts()

/proc/body_marking_module_tag(typepath)
	var/p = "[typepath]"
	if(findtext(p, "modular_zzveilbreak"))
		return MARKING_MODULE_VEILBREAK
	if(findtext(p, "modular_zzplurt"))
		return MARKING_MODULE_SPLURT
	if(findtext(p, "modular_zubbers"))
		return MARKING_MODULE_BUBBER
	if(findtext(p, "modular_skyrat"))
		return MARKING_MODULE_SKYRAT
	if(findtext(p, "modular_"))
		var/regex/R = regex(@"modular_([a-z]+)/")
		if(R.Find(p))
			return capitalize(R.group[1])
		return "Modular"
	return MARKING_MODULE_CORE

/proc/resolve_body_marking_name_conflicts()
	if(GLOB.body_marking_conflicts_resolved)
		return
	GLOB.body_marking_conflicts_resolved = TRUE

	// Build initial references first if Skyrat hasn't populated them yet
	if(!length(GLOB.body_markings))
		for(var/path in subtypesof(/datum/body_marking))
			var/datum/body_marking/BM = new path()
			if(!BM.name)
				continue
			GLOB.body_markings[BM.name] = BM

	var/list/name_to_paths = list()
	for(var/key in GLOB.body_markings)
		var/datum/body_marking/BM = GLOB.body_markings[key]
		if(!BM)
			continue
		LAZYADDASSOCLIST(name_to_paths, initial(BM.name), BM.type)

	for(var/marking_name in name_to_paths)
		var/list/paths = name_to_paths[marking_name]
		if(paths.len <= 1)
			continue

		// Remove original un-tagged key from global registry
		var/datum/body_marking/old_BM = GLOB.body_markings[marking_name]
		GLOB.body_markings -= marking_name

		for(var/typepath in paths)
			var/module_tag = body_marking_module_tag(typepath)
			var/new_name = "[marking_name] ([module_tag])"

			var/datum/body_marking/target_BM
			if(old_BM && old_BM.type == typepath)
				target_BM = old_BM
			else
				target_BM = new typepath()

			target_BM.name = new_name

			if(GLOB.body_markings[new_name])
				stack_trace("Body marking conflict resolver: two definitions of '[marking_name]' share module '[module_tag]'. Offending path: [typepath]")
				GLOB.body_markings[marking_name] = target_BM
				continue

			GLOB.body_markings[new_name] = target_BM

	// Rebuild per-limb association mapping using the newly tagged unique keys
	for(var/zone in GLOB.body_markings_per_limb)
		GLOB.body_markings_per_limb[zone] = list()

	for(var/key in GLOB.body_markings)
		var/datum/body_marking/BM_inst = GLOB.body_markings[key]
		if(!BM_inst)
			continue
		var/datum/body_marking/BM_path = BM_inst.type
		var/affected = initial(BM_path.affected_bodyparts)
		if(!affected)
			continue
		for(var/marking_zone in GLOB.marking_zones)
			var/bitflag = GLOB.marking_zone_to_bitflag[marking_zone]
			if(affected & bitflag)
				LAZYADD(GLOB.body_markings_per_limb[marking_zone], key)

	// Remap body marking sets to point to tagged names
	for(var/set_typepath in subtypesof(/datum/body_marking_set))
		var/datum/body_marking_set/BMS_template = set_typepath
		var/set_key = initial(BMS_template.name)
		var/datum/body_marking_set/BMS = GLOB.body_marking_sets[set_key]
		if(!BMS || !length(BMS.body_marking_list))
			continue

		var/set_module = body_marking_module_tag(set_typepath)
		var/list/remapped = list()

		for(var/entry in BMS.body_marking_list)
			var/list/paths = name_to_paths[entry]
			if(!paths || paths.len <= 1)
				remapped += entry
				continue

			var/picked_path = null
			for(var/candidate in paths)
				if(body_marking_module_tag(candidate) == set_module)
					picked_path = candidate
					break
			if(!picked_path)
				picked_path = paths[1]

			remapped += "[entry] ([body_marking_module_tag(picked_path)])"

		BMS.body_marking_list = remapped

#undef MARKING_MODULE_VEILBREAK
#undef MARKING_MODULE_SPLURT
#undef MARKING_MODULE_BUBBER
#undef MARKING_MODULE_SKYRAT
#undef MARKING_MODULE_CORE
