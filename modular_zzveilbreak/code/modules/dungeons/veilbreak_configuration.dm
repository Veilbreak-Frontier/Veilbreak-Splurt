#define DUNGEON_WIDTH 100
#define DUNGEON_HEIGHT 100
#define DUNGEON_GENERATOR_URL "http://127.0.0.1:8000"
#define DUNGEON_GENERATOR_TIMEOUT 300
#define DUNGEON_GENERATE_ENDPOINT "/generate_dungeon"
#define PORTAL_TRAIT_DUNGEON list(ZTRAIT_AWAY, ZTRAIT_MINING)
#define PORTAL_ACTIVE_POWER_USAGE (BASE_MACHINE_ACTIVE_CONSUMPTION * 2)

GLOBAL_VAR(station_veilbreak_portal)
GLOBAL_VAR(portal_dungeon_z_level)
GLOBAL_LIST_EMPTY(basic_mobs)
GLOBAL_DATUM(dungeon_generator, /datum/http_dungeon_generator)

/proc/subsystems_ready_for_portals(feedback_target)
	if(!SSmapping?.initialized)
		if(feedback_target)
			to_chat(feedback_target, "Mapping Subsystem not ready.")
		return FALSE
	if(!SSatoms?.initialized)
		if(feedback_target)
			to_chat(feedback_target, "Atom Subsystem not ready.")
		return FALSE
	if(!SSair?.initialized)
		if(feedback_target)
			to_chat(feedback_target, "Atmospherics Subsystem not ready.")
		return FALSE
	if(world.time < 30 SECONDS)
		if(feedback_target)
			to_chat(feedback_target, "Dimensional stability initializing... [300 - world.time]ds remaining.")
		return FALSE
	return TRUE
