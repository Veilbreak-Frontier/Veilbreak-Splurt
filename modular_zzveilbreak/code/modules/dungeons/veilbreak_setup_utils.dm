/proc/veilbreak_initialize_zlevel(z_level, list/metadata)
	SSatoms.InitializeAtoms(Z_TURFS(z_level))

	addtimer(CALLBACK(GLOBAL_PROC, .proc/veilbreak_spawn_mobs, z_level), 5)

	addtimer(CALLBACK(GLOBAL_PROC, .proc/veilbreak_init_areas_power, z_level), 10)
	addtimer(CALLBACK(GLOBAL_PROC, .proc/veilbreak_init_air, z_level), 12)

	addtimer(CALLBACK(GLOBAL_PROC, .proc/veilbreak_init_machinery, z_level), 15)
	addtimer(CALLBACK(GLOBAL_PROC, .proc/veilbreak_init_smoothing, z_level), 20)

	addtimer(CALLBACK(GLOBAL_PROC, .proc/veilbreak_activate_return_portal, z_level, metadata), 25)
	addtimer(CALLBACK(GLOBAL_PROC, .proc/veilbreak_final_ai_prep, z_level), 30)

/proc/veilbreak_spawn_mobs(z_level)
	var/processed = 0
	for(var/obj/effect/mob_placeholder/P in world)
		if(P.z != z_level)
			continue

		processed++
		var/turf/T = get_turf(P)
		if(!T)
			qdel(P)
			continue

		if(!P.mob_type)
			P.determine_mob_type_from_self()

		var/mob/living/new_mob = new P.mob_type(T)
		if(new_mob)
			if(P.mob_faction)
				new_mob.faction = P.mob_faction.Copy()
			if(P.mob_name && P.mob_name != "mob placeholder")
				new_mob.name = P.mob_name
			var/datum/ai_controller/controller_path = initial(new_mob.ai_controller)
			if(ispath(controller_path))
				new_mob.ai_controller = new controller_path(new_mob)
			if(!(new_mob in GLOB.basic_mobs))
				GLOB.basic_mobs += new_mob
		qdel(P)
		if(processed % 50 == 0)
			CHECK_TICK

/proc/veilbreak_init_ai(z_level)
	var/processed = 0
	for(var/mob/living/basic/M in world)
		if(M.z != z_level)
			continue
		if(!M.ai_controller)
			var/datum/ai_controller/controller_path = initial(M.ai_controller)
			if(ispath(controller_path))
				M.ai_controller = new controller_path(M)
		if(M.ai_controller)
			M.ai_controller.pawn = M
			M.ai_controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET] = null
		processed++
		if(processed % 25 == 0)
			CHECK_TICK

/proc/veilbreak_init_air(z_level)
	var/list/z_turfs = block(locate(1, 1, z_level), locate(world.maxx, world.maxy, z_level))
	var/i = 0
	for(var/turf/open/T in z_turfs)
		T.Initalize_Atmos(0)
		i++
		if(i % 50 == 0)
			CHECK_TICK

/proc/veilbreak_init_lighting(z_level)
	var/list/z_turfs = block(locate(1, 1, z_level), locate(world.maxx, world.maxy, z_level))
	var/i = 0
	for(var/turf/T in z_turfs)
		if(!T.lighting_object)
			new /datum/lighting_object(T)
		i++
		if(i % 100 == 0)
			CHECK_TICK
	SSlighting.create_all_lighting_objects()

/proc/veilbreak_activate_return_portal(z_level, list/metadata)
	var/obj/machinery/portal/exit_portal
	var/list/p_loc = metadata?["portal_location"]

	if(p_loc && p_loc["x"] && p_loc["y"])
		var/turf/origin = locate(p_loc["x"], p_loc["y"], z_level)
		exit_portal = locate(/obj/machinery/portal) in range(2, origin)

	if(!exit_portal)
		for(var/turf/T in block(locate(1,1,z_level), locate(world.maxx, world.maxy, z_level)))
			exit_portal = locate(/obj/machinery/portal) in T
			if(exit_portal) break

	var/obj/machinery/portal/S = GLOB.station_veilbreak_portal
	if(exit_portal && istype(S))
		var/datum/portal_destination/veilbreak/back_home = new()
		back_home.target_turf = get_turf(S)
		back_home.generated = TRUE
		exit_portal.target = back_home
		exit_portal.transport_active = TRUE
		exit_portal.update_appearance()

/proc/veilbreak_cleanup_zlevel(z_level, turf/ejection_turf, datum/portal_destination/veilbreak/dest_datum)
	var/obj/machinery/portal/S = GLOB.station_veilbreak_portal
	if(istype(S))
		S.transport_active = FALSE
		S.update_appearance()

	var/list/z_turfs = block(locate(1, 1, z_level), locate(world.maxx, world.maxy, z_level))
	for(var/i in 1 to length(z_turfs))
		var/turf/T = z_turfs[i]
		for(var/atom/movable/AM in T)
			if(ismob(AM))
				if(!isobserver(AM))
					AM.forceMove(ejection_turf)
			else
				qdel(AM)

		T.ChangeTurf(/turf/open/space)
		if(i % 500 == 0)
			CHECK_TICK

	qdel(dest_datum)
