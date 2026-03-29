/datum/portal_destination/veilbreak/proc/veilbreak_initialize_zlevel(z_level)
	initialize_atoms_on_z_level(z_level)
	CHECK_TICK

	replace_map_mobs_with_placeholders(z_level)
	CHECK_TICK

	spawn_mobs_from_placeholders(z_level)
	CHECK_TICK

	force_ai_initialization_fixed(z_level)
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

	//ensure_portal_connection() Deal with this after things initialize

	generated = TRUE

	addtimer(CALLBACK(src, .proc/final_ai_verification, z_level), 2 SECONDS)

	addtimer(CALLBACK(src, .proc/final_ai_activation, z_level), 3 SECONDS)


/datum/portal_destination/veilbreak/proc/initialize_atoms_on_z_level(z_level)
	if(SSatoms.initialized)
		SSatoms.InitializeAtoms(Z_TURFS(z_level))

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

        if(!new_mob)
            continue

        if(placeholder.mob_faction)
            new_mob.faction = placeholder.mob_faction.Copy()

        if(placeholder.mob_name && placeholder.mob_name != "mob placeholder")
            new_mob.name = placeholder.mob_name

        qdel(placeholder)

        if(placeholders_processed % 50 == 0)
            CHECK_TICK

/datum/portal_destination/veilbreak/proc/force_ai_initialization_fixed(z_level)
	var/pawns_verified = 0
	var/global_added = 0

	for(var/mob/living/basic/mob in world)
		if(mob.z != z_level)
			continue

		if(mob.ai_controller)
			if(mob.ai_controller.pawn == mob)
				pawns_verified++
				mob.ai_controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET] = null
			else
				mob.ai_controller.pawn = mob

		if(!(mob in GLOB.basic_mobs))
			GLOB.basic_mobs += mob
			global_added++

		if((pawns_verified + global_added) % 50 == 0)
			CHECK_TICK

/datum/portal_destination/veilbreak/proc/initialize_areas_and_power(z_level)
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
		if(processed % 50 == 0)
			CHECK_TICK


/datum/portal_destination/veilbreak/proc/force_air_initialization(z_level)
	if(!SSair || !SSair.initialized)
		return

	addtimer(CALLBACK(src, .proc/actually_initialize_air, z_level), 2 SECONDS)

/datum/portal_destination/veilbreak/proc/actually_initialize_air(z_level)
	var/initialized_count = 0
	for(var/turf/open/T in block(locate(1, 1, z_level), locate(world.maxx, world.maxy, z_level)))
		var/datum/gas_mixture/air = T.return_air()
		if(!air)
			T.Initalize_Atmos(0)
			T.immediate_calculate_adjacent_turfs()
		initialized_count++

		if(initialized_count % 50 == 0)
			CHECK_TICK

	var/activated_count = 0
	for(var/turf/open/T in block(locate(1, 1, z_level), locate(world.maxx, world.maxy, z_level)))
		if(!T.excited && !T.blocks_air)
			SSair.add_to_active(T)
			activated_count++
			if(activated_count >= 100)
				break
		CHECK_TICK

/datum/portal_destination/veilbreak/proc/force_lighting_initialization(z_level)
	if(!SSlighting || !SSlighting.initialized)
		return

	var/objects_created = 0
	for(var/turf/T in block(locate(1, 1, z_level), locate(world.maxx, world.maxy, z_level)))
		if(!T.space_lit && !T.lighting_object)
			new /datum/lighting_object(T)
			objects_created++

		T.update_appearance()

		if(objects_created % 100 == 0)
			CHECK_TICK

	SSlighting.create_all_lighting_objects()


/datum/portal_destination/veilbreak/proc/initialize_enhanced_smoothing(z_level)
	if(!SSicon_smooth || !SSicon_smooth.initialized)
		return

	sleep(1)

	var/direct_count = 0
	for(var/turf/closed/wall/wall in world)
		if(wall.z == z_level)
			wall.smooth_icon()
			direct_count++
			if(direct_count % 100 == 0)
				CHECK_TICK

	var/queued_count = 0
	for(var/turf/closed/wall/wall in world)
		if(wall.z == z_level)
			QUEUE_SMOOTH(wall)
			queued_count++
			if(queued_count % 100 == 0)
				CHECK_TICK

	smooth_zlevel(z_level, TRUE)

	addtimer(CALLBACK(src, .proc/verify_and_finalize_smoothing, z_level), 2 SECONDS)


/datum/portal_destination/veilbreak/proc/final_ai_activation(z_level)
	var/ai_activated = 0

	for(var/mob/living/basic/mob in world)
		if(mob.z != z_level)
			continue

		if(mob.ai_controller && mob.ai_controller.pawn == mob)
			mob.ai_controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET] = null

			ai_activated++

		ai_activated++

		if(ai_activated % 25 == 0)
			CHECK_TICK


/datum/portal_destination/veilbreak/proc/final_ai_verification(z_level)
	for(var/mob/living/basic/void_creature/mob in world)
		if(mob.z != z_level)
			continue

		if(!mob.ai_controller)
			continue

		CHECK_TICK

/datum/portal_destination/veilbreak/proc/verify_and_finalize_smoothing(z_level)
	var/unsmoothed_count = 0

	for(var/turf/closed/wall/wall in world)
		if(wall.z == z_level)
			if(wall.icon_state == "wall-0")
				unsmoothed_count++

	if(unsmoothed_count > 0)
		emergency_wall_smoothing_fix(z_level)

/datum/portal_destination/veilbreak/proc/emergency_wall_smoothing_fix(z_level)
	var/fixed_count = 0
	for(var/turf/closed/wall/wall in world)
		if(wall.z == z_level && wall.icon_state == "wall-0")
			var/new_junction = NONE

			for(var/dir in list(NORTH, SOUTH, EAST, WEST))
				var/turf/neighbor = get_step(wall, dir)
				if(neighbor && istype(neighbor, /turf/closed/wall))
					new_junction |= dir

			if(new_junction != NONE)
				wall.smoothing_junction = new_junction
				wall.icon_state = "wall-[new_junction]"
				fixed_count++

			if(fixed_count % 50 == 0)
				CHECK_TICK
