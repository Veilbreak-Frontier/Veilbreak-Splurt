/datum/portal_destination/veilbreak
	var/name = "Quantum Pocket Space"
	var/generating = FALSE
	var/generated = FALSE
	var/cleanup_in_progress = FALSE
	var/generation_progress = 0
	var/dungeon_z_level = 0
	var/current_request_id = 0
	var/turf/target_turf
	var/last_progress_update = 0
	var/obj/machinery/computer/portal_control/connected_control_computer
	var/list/last_generation_data

/datum/portal_destination/veilbreak/proc/start_generation(mob/feedback_target)
	if(generating || generated || current_request_id)
		return FALSE
	if(!subsystems_ready_for_portals(feedback_target))
		return FALSE
	generating = TRUE
	generation_progress = 0
	if(!GLOB.dungeon_generator)
		GLOB.dungeon_generator = new /datum/http_dungeon_generator()
	current_request_id = GLOB.dungeon_generator.generate_dungeon(src, DUNGEON_WIDTH, DUNGEON_HEIGHT)
	if(!current_request_id)
		generating = FALSE
		return FALSE
	last_progress_update = world.time
	START_PROCESSING(SSobj, src)
	return TRUE

/datum/portal_destination/veilbreak/process(seconds_per_tick)
	if(!generating)
		STOP_PROCESSING(SSobj, src)
		return
	if(world.time - last_progress_update > 1 SECONDS)
		generation_progress = min(generation_progress + rand(5, 12), 95)
		last_progress_update = world.time
	if(current_request_id)
		var/still_processing = GLOB.dungeon_generator.check_request(current_request_id)
		if(!still_processing)
			current_request_id = 0
			STOP_PROCESSING(SSobj, src)
			return

/datum/portal_destination/veilbreak/proc/generation_complete(list/json_data)
	generating = FALSE
	last_generation_data = json_data.Copy()
	var/dmm_content = json_data["dmm_content"]
	var/list/metadata = json_data["metadata"]
	if(!dmm_content || length(dmm_content) < 10)
		generation_failed("DMM content is empty or too short")
		return
	var/datum/space_level/S = SSmapping.add_new_zlevel("Veilbreak Dungeon", list(ZTRAIT_RESERVED = TRUE))
	if(!S)
		generation_failed("Mapping Subsystem failed to allocate Z-level")
		return
	dungeon_z_level = S.z_value
	SSmapping.update_plane_tracking(S)
	load_dmm_with_ticks(dmm_content, metadata)

/datum/portal_destination/veilbreak/proc/load_dmm_with_ticks(dmm_content, list/metadata)
	SSatoms.map_loader_begin("veilbreak_[dungeon_z_level]")
	if(SSair.initialized)
		SSair.StartLoadingMap()

	var/datum/parsed_map/PM = new(dmm_content)
	SSatoms.initialized_state += list(list(src, INITIALIZATION_INNEW_MAPLOAD))

	var/list/loaded_atoms = PM.load(1, 1, dungeon_z_level, no_changeturf = FALSE)

	if(SSair.initialized)
		SSair.StopLoadingMap()
	SSatoms.map_loader_stop("veilbreak_[dungeon_z_level]")

	if(!islist(loaded_atoms))
		if(loaded_atoms == 1)
			loaded_atoms = list()
			for(var/atom/A in world)
				if(A.z == dungeon_z_level)
					loaded_atoms += A
		else
			SSatoms.initialized_state.Cut(length(SSatoms.initialized_state))
			generation_failed("Map loader returned invalid data type: [loaded_atoms]")
			return

	if(SSatoms.initialized && length(loaded_atoms))
		var/list/to_init = list()
//		for(var/i in 1 to length(loaded_atoms))
//			var/atom/A = loaded_atoms[i]
			//if(A && A.atom_initialized == INITIALIZATION_INNEW_MAPLOAD)
			//	to_init += A

		if(length(to_init))
			SSatoms.InitializeAtoms(to_init)

	SSatoms.initialized_state.Cut(length(SSatoms.initialized_state))

	var/z_offset = SSmapping.z_level_to_plane_offset[dungeon_z_level]
	for(var/i in 1 to length(loaded_atoms))
		var/atom/A = loaded_atoms[i]
		if(!A || QDELETED(A))
			continue
		if(!SSmapping.plane_offset_blacklist["[initial(A.plane)]"])
			A.plane = initial(A.plane) - (PLANE_RANGE * z_offset)
		if(i % 500 == 0)
			CHECK_TICK

	addtimer(CALLBACK(src, .proc/finalize_dungeon_generation, metadata), 1 SECONDS)

/datum/portal_destination/veilbreak/proc/finalize_dungeon_generation(list/metadata)
	if(generated)
		return
	spawn_mobs_from_placeholders()
	force_ai_initialization_fixed()
	initialize_areas_and_power()
	initialize_machinery()
	force_air_initialization()
	force_lighting_initialization()
	initialize_enhanced_smoothing()
	activate_return_portal(metadata)
	generated = TRUE
	generation_progress = 100
	if(connected_control_computer)
		connected_control_computer.on_generation_success()
	addtimer(CALLBACK(src, .proc/final_ai_verification), 2 SECONDS)
	addtimer(CALLBACK(src, .proc/final_ai_activation), 3 SECONDS)

/datum/portal_destination/veilbreak/proc/spawn_mobs_from_placeholders()
	var/processed = 0
	for(var/obj/effect/mob_placeholder/P in world)
		if(P.z != dungeon_z_level)
			continue
		processed++
		var/turf/T = get_turf(P)
		if(T)
			var/mob/living/basic/new_mob
			if(P.mob_type)
				new_mob = new P.mob_type(T)
			else
				new_mob = spawn_random_void_mob(T)
			if(new_mob)
				if(P.mob_faction)
					new_mob.faction = P.mob_faction.Copy()
				if(P.mob_name && P.mob_name != "mob placeholder")
					new_mob.name = P.mob_name
		qdel(P)
		if(processed % 50 == 0)
			CHECK_TICK

/datum/portal_destination/veilbreak/proc/spawn_random_void_mob(turf/T)
	var/static/list/void_types = list(
		/mob/living/basic/void_creature/void_healer = 1,
		/mob/living/basic/void_creature/voidbug = 2,
		/mob/living/basic/void_creature/consumed_pathfinder = 1,
		/mob/living/basic/void_creature/voidling = 3
	)
	var/picked = pick_weight(void_types)
	return new picked(T)

/datum/portal_destination/veilbreak/proc/force_ai_initialization_fixed()
	var/processed = 0
	for(var/mob/living/basic/M in world)
		if(M.z != dungeon_z_level)
			continue
		if(M.ai_controller)
			M.ai_controller.pawn = M
			M.ai_controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET] = null
		if(!(M in GLOB.basic_mobs))
			GLOB.basic_mobs += M
		processed++
		if(processed % 50 == 0)
			CHECK_TICK

/datum/portal_destination/veilbreak/proc/force_air_initialization()
	if(!SSair || !SSair.initialized)
		return
	addtimer(CALLBACK(src, .proc/actually_initialize_air), 2 SECONDS)

/datum/portal_destination/veilbreak/proc/actually_initialize_air()
	var/count = 0
	var/list/z_turfs = block(locate(1, 1, dungeon_z_level), locate(world.maxx, world.maxy, dungeon_z_level))
	for(var/turf/open/T in z_turfs)
		if(!T.return_air())
			T.Initalize_Atmos(0)
			T.immediate_calculate_adjacent_turfs()
		count++
		if(count % 100 == 0)
			CHECK_TICK
	var/activated = 0
	for(var/turf/open/T in z_turfs)
		if(!T.excited && !T.blocks_air)
			SSair.add_to_active(T)
			activated++
			if(activated >= 100)
				break
		CHECK_TICK

/datum/portal_destination/veilbreak/proc/force_lighting_initialization()
	if(!SSlighting || !SSlighting.initialized)
		return
	var/count = 0
	for(var/turf/T in block(locate(1, 1, dungeon_z_level), locate(world.maxx, world.maxy, dungeon_z_level)))
		if(T.space_lit || T.lighting_object)
			continue

		new /datum/lighting_object(T)
		count++
		T.update_appearance()

		if(count % 200 == 0)
			CHECK_TICK

	SSlighting.create_all_lighting_objects()

/datum/portal_destination/veilbreak/proc/initialize_enhanced_smoothing()
	if(!SSicon_smooth || !SSicon_smooth.initialized)
		return
	sleep(1)
	for(var/turf/closed/wall/W in world)
		if(W.z == dungeon_z_level)
			W.smooth_icon()
			QUEUE_SMOOTH(W)
	smooth_zlevel(dungeon_z_level, TRUE)

/datum/portal_destination/veilbreak/proc/initialize_areas_and_power()
	for(var/area/A as anything in GLOB.areas)
		var/on_z = FALSE
		for(var/turf/T in A.contents)
			if(T.z == dungeon_z_level)
				on_z = TRUE
				break
		if(on_z)
			A.power_equip = initial(A.power_equip)
			A.power_light = initial(A.power_light)
			A.power_environ = initial(A.power_environ)
			A.power_change()
			A.update_appearance()
		CHECK_TICK

/datum/portal_destination/veilbreak/proc/initialize_machinery()
	var/processed = 0
	for(var/obj/machinery/M in world)
		if(M.z != dungeon_z_level)
			continue
		if(M.use_power)
			M.power_change()
		M.update_appearance()
		processed++
		if(processed % 50 == 0)
			CHECK_TICK

/datum/portal_destination/veilbreak/proc/final_ai_verification()
	for(var/mob/living/basic/M in world)
		if(M.z == dungeon_z_level && !M.ai_controller)
			continue
		CHECK_TICK

/datum/portal_destination/veilbreak/proc/final_ai_activation()
	for(var/mob/living/basic/M in world)
		if(M.z == dungeon_z_level && M.ai_controller)
			M.ai_controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET] = null
		CHECK_TICK

/datum/portal_destination/veilbreak/proc/activate_return_portal(list/metadata)
	var/obj/machinery/portal/exit_portal
	var/list/p_loc = metadata?["portal_location"]
	if(p_loc && p_loc["x"] && p_loc["y"])
		var/turf/origin = locate(p_loc["x"], p_loc["y"], dungeon_z_level)
		exit_portal = locate(/obj/machinery/portal) in range(2, origin)
	if(!exit_portal)
		for(var/turf/T in block(locate(1,1,dungeon_z_level), locate(world.maxx, world.maxy, dungeon_z_level)))
			exit_portal = locate(/obj/machinery/portal) in T
			if(exit_portal) break
	if(exit_portal && GLOB.station_veilbreak_portal)
		var/datum/portal_destination/veilbreak/back_home = new()
		back_home.target_turf = get_turf(GLOB.station_veilbreak_portal)
		back_home.generated = TRUE
		exit_portal.target = back_home
		exit_portal.transport_active = TRUE
		exit_portal.update_appearance()
	target_turf = get_target_turf()

/datum/portal_destination/veilbreak/proc/get_target_turf()
	if(!dungeon_z_level)
		return null
	return locate(round(DUNGEON_WIDTH / 2), round(DUNGEON_HEIGHT / 2), dungeon_z_level)

/datum/portal_destination/veilbreak/proc/post_transfer(atom/movable/AM)
	if(ismob(AM))
		var/mob/M = AM
		if(M.client)
			M.client.move_delay = max(world.time + 5, M.client.move_delay)

/datum/portal_destination/veilbreak/proc/cleanup_z_level_completely(z_level, turf/ejection_turf)
	if(cleanup_in_progress)
		return
	cleanup_in_progress = TRUE
	var/list/z_turfs = block(locate(1, 1, z_level), locate(world.maxx, world.maxy, z_level))
	var/obj/machinery/portal/station_portal = GLOB.station_veilbreak_portal
	if(istype(station_portal))
		station_portal.transport_active = FALSE
		station_portal.update_appearance()
	for(var/i in 1 to length(z_turfs))
		var/turf/T = z_turfs[i]
		for(var/atom/movable/AM as anything in T)
			if(isobserver(AM))
				continue
			if(isliving(AM))
				var/mob/living/L = AM
				if(L.client || L.mind)
					if(ejection_turf)
						L.forceMove(ejection_turf)
					continue
			qdel(AM)
		T.ChangeTurf(/turf/open/space/basic, CHANGETURF_INHERIT_AIR)
		if(i % 100 == 0)
			CHECK_TICK
	generated = FALSE
	cleanup_in_progress = FALSE
	qdel(src)

/datum/portal_destination/veilbreak/proc/generation_failed(reason)
	generating = FALSE
	generated = FALSE
	generation_progress = 0
	current_request_id = 0
	if(connected_control_computer)
		connected_control_computer.on_generation_failed(reason)
