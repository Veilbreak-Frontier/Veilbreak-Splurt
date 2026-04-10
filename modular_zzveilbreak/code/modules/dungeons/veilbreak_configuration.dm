#define DUNGEON_WIDTH 100
#define DUNGEON_HEIGHT 100
#define DUNGEON_GENERATOR_URL "http://127.0.0.1:8000"
#define DUNGEON_GENERATOR_TIMEOUT 300
#define DUNGEON_GENERATE_ENDPOINT "/generate_dungeon"
#define PORTAL_TRAIT_DUNGEON list(ZTRAIT_AWAY, ZTRAIT_MINING)
#define PORTAL_ACTIVE_POWER_USAGE (BASE_MACHINE_ACTIVE_CONSUMPTION * 2)
#define VEILBREAK_TEMP_MAP_PREFIX "data/veilbreak_temp_"
#define VEILBREAK_CLEANUP_BATCH_SIZE 50
#define VEILBREAK_MOB_SPAWN_BATCH_SIZE 25
#define VEILBREAK_TURF_PROCESS_BATCH_SIZE 50

/// Dungeon pocket Z must satisfy BOTH traits. Use level_has_all_traits(z, PORTAL_TRAIT_DUNGEON) — not level_trait(z, list).
GLOBAL_VAR(station_veilbreak_portal)
GLOBAL_VAR(portal_dungeon_z_level)
GLOBAL_LIST_EMPTY(basic_mobs)
GLOBAL_DATUM(dungeon_generator, /datum/http_dungeon_generator)

/proc/is_veilbreak_portal_dungeon_z(z)
	if(!isnum(z) || z < 1 || z > world.maxz || !SSmapping?.z_list || z > length(SSmapping.z_list))
		return FALSE
	return SSmapping.level_has_all_traits(z, PORTAL_TRAIT_DUNGEON)

/proc/subsystems_ready_for_portals(feedback_target)
	if(!SSmapping?.initialized)
		if(feedback_target)
			to_chat(feedback_target, span_warning("Orbital stabilization systems are still spooling..."))
		return FALSE
	if(!SSatoms?.initialized)
		if(feedback_target)
			to_chat(feedback_target, span_warning("Matter fabricators are not yet online..."))
		return FALSE
	if(!SSair?.initialized)
		if(feedback_target)
			to_chat(feedback_target, span_warning("Atmospheric regulators are still calibrating..."))
		return FALSE
	if(!SSlighting?.initialized)
		if(feedback_target)
			to_chat(feedback_target, span_warning("Lighting arrays are still initializing..."))
		return FALSE
	if(!SSicon_smooth?.initialized)
		if(feedback_target)
			to_chat(feedback_target, span_warning("Visual rendering systems are still spooling..."))
		return FALSE
	return TRUE
