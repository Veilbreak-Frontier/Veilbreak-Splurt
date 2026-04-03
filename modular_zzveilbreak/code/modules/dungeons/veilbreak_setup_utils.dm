/datum/portal_destination/veilbreak/proc/veilbreak_initialize_zlevel(z_level, list/metadata)
	replace_map_mobs_with_placeholders(z_level)
	CHECK_TICK
	spawn_mobs_from_placeholders(z_level)
	CHECK_TICK
	force_ai_registration(z_level)
	CHECK_TICK
	initialize_areas_and_power(z_level)
	CHECK_TICK
	initialize_machinery(z_level)
	CHECK_TICK
	force_air_initialization(z_level)
	CHECK_TICK
	force_lighting_initialization(z_level)
	CHECK_TICK
	initialize_enhanced_smoothing(z_level)
	CHECK_TICK
	generated = TRUE
	addtimer(CALLBACK(src, .proc/final_ai_activation, z_level), 3 SECONDS)

/datum/portal_destination/veilbreak/proc/replace_map_mobs_with_placeholders(z_level)
	for(var/obj/effect/mob_placeholder/placeholder in world)
		if(placeholder.z != z_level)
			continue
		CHECK_TICK

/datum/portal_destination/veilbreak/proc/spawn_mobs_from_placeholders(z_level)
	var/placeholders_processed = 0
	for(var/obj/effect/mob_placeholder/placeholder in world)
		if(placeholder.z != z_level)
			continue
		placeholders_processed++
		var/turf/spawn_turf = get_turf(placeholder)
		if(!spawn_turf)
			continue
		if(!placeholder.mob_type)
			placeholder.determine_mob_type_from_self()
		var/mob/living/new_mob = new placeholder.mob_type(spawn_turf)
		if(new_mob)
			if(placeholder.mob_faction)
				new_mob.faction = placeholder.mob_faction.Copy()
			if(placeholder.mob_name && placeholder.mob_name != "mob placeholder")
				new_mob.name = placeholder.mob_name
		qdel(placeholder)
		if(placeholders_processed % VEILBREAK_MOB_SPAWN_BATCH_SIZE == 0)
			CHECK_TICK

/datum/portal_destination/veilbreak/proc/force_ai_registration(z_level)
	var/registered = 0
	for(var/mob/living/basic/mob in world)
		if(mob.z != z_level)
			continue
		if(!(mob in GLOB.basic_mobs))
			GLOB.basic_mobs += mob
			registered++
		if(registered % VEILBREAK_MOB_SPAWN_BATCH_SIZE == 0)
			CHECK_TICK

/datum/portal_destination/veilbreak/proc/initialize_areas_and_power(z_level)
	var/processed = 0
	for(var/area/area as anything in GLOB.areas)
		var/has_turfs_on_z = FALSE
		for(var/turf/T in area.contents)
			if(T.z == z_level)
				has_turfs_on_z = TRUE
				break
		if(has_turfs_on_z)
			area.power_equip = initial(area.power_equip)
			area.power_light = initial(area.power_light)
			area.power_environ = initial(area.power_environ)
			area.always_unpowered = initial(area.always_unpowered)
			area.power_change()
			area.update_icon()
			processed++
			if(processed % VEILBREAK_TURF_PROCESS_BATCH_SIZE == 0)
				CHECK_TICK

/datum/portal_destination/veilbreak/proc/initialize_machinery(z_level)
	var/processed = 0
	for(var/obj/machinery/machine in world)
		if(machine.z != z_level)
			continue
		if(machine.use_power)
			machine.power_change()
		machine.update_icon()
		machine.update_appearance()
		processed++
		if(processed % VEILBREAK_TURF_PROCESS_BATCH_SIZE == 0)
			CHECK_TICK

/datum/portal_destination/veilbreak/proc/force_air_initialization(z_level)
	if(!SSair || !SSair.initialized)
		return
	var/list/turfs_to_init = block(locate(1, 1, z_level), locate(DUNGEON_WIDTH, DUNGEON_HEIGHT, z_level))
	var/count = 0
	for(var/turf/open/T in turfs_to_init)
		if(T && T.air)
			SSair.add_to_active(T)
			for(var/turf/adjacent in T.atmos_adjacent_turfs)
				if(adjacent && adjacent.z == z_level)
					T.atmos_adjacent_turfs |= adjacent
					adjacent.atmos_adjacent_turfs |= T
		count++
		if(count % VEILBREAK_TURF_PROCESS_BATCH_SIZE == 0)
			CHECK_TICK

/datum/portal_destination/veilbreak/proc/force_lighting_initialization(z_level)
	if(!SSlighting)
		return
	var/list/turfs_to_init = block(locate(1, 1, z_level), locate(DUNGEON_WIDTH, DUNGEON_HEIGHT, z_level))
	var/count = 0
	for(var/turf/T in turfs_to_init)
		if(!T)
			continue
		var/area/A = T.loc
		if(A && A.static_lighting && !T.space_lit && !T.lighting_object)
			var/datum/lighting_object/LO = new(T)
			if(LO)
				LO.needs_update = TRUE
				SSlighting.objects_queue |= LO
		count++
		if(count % VEILBREAK_TURF_PROCESS_BATCH_SIZE == 0)
			CHECK_TICK
	if(length(SSlighting.objects_queue) && SSlighting.can_fire)
		SSlighting.can_fire = TRUE

/datum/portal_destination/veilbreak/proc/initialize_enhanced_smoothing(z_level)
	if(!SSicon_smooth || !SSicon_smooth.initialized)
		return
	var/count = 0
	for(var/turf/closed/wall/wall in world)
		if(wall && wall.z == z_level)
			SSicon_smooth.add_to_queue(wall)
			count++
			if(count % VEILBREAK_TURF_PROCESS_BATCH_SIZE == 0)
				CHECK_TICK
	if(length(SSicon_smooth.smooth_queue) && !SSicon_smooth.can_fire)
		SSicon_smooth.can_fire = TRUE

/datum/portal_destination/veilbreak/proc/final_ai_activation(z_level)
	var/activated = 0
	for(var/mob/living/basic/mob in world)
		if(mob && mob.z == z_level)
			if(mob.ai_controller && mob.ai_controller.pawn == mob)
				mob.ai_controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET] = null
				activated++
		if(activated % VEILBREAK_MOB_SPAWN_BATCH_SIZE == 0)
			CHECK_TICK
