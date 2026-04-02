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

/datum/portal_destination/veilbreak/proc/generation_complete(list/json_data)
	last_generation_data = json_data.Copy()
	var/dmm_content = json_data["dmm_content"]
	var/list/metadata = json_data["metadata"]

	if(!dmm_content || length(dmm_content) < 100)
		generation_failed("Invalid map data")
		return

	var/datum/space_level/S = SSmapping.add_new_zlevel("Veilbreak", list(ZTRAIT_RESERVED = TRUE, ZTRAIT_AWAY = TRUE, ZTRAIT_MINING = TRUE))
	if(!S)
		generation_failed("Z-Level allocation failed")
		return

	dungeon_z_level = S.z_value
	GLOB.portal_dungeon_z_level = dungeon_z_level
	SSmapping.update_plane_tracking(S)

	load_dmm_with_ticks(dmm_content, metadata)

/datum/portal_destination/veilbreak/proc/load_dmm_with_ticks(dmm_content, list/metadata)
	var/loader_source = "veilbreak_[dungeon_z_level]"
	SSatoms.map_loader_begin(loader_source)

	var/datum/parsed_map/PM = new(dmm_content)
	var/list/loaded_atoms = PM.load(1, 1, dungeon_z_level, no_changeturf = FALSE)

	var/z_offset = SSmapping.z_level_to_plane_offset[dungeon_z_level]
	for(var/i in 1 to length(loaded_atoms))
		var/atom/A = loaded_atoms[i]
		if(!A || QDELETED(A))
			continue
		A.plane = initial(A.plane) - (21 * z_offset)
		if(i % 200 == 0)
			CHECK_TICK

	addtimer(CALLBACK(src, .proc/finalize_dungeon_generation, metadata, loader_source), 1 SECONDS)

/datum/portal_destination/veilbreak/proc/finalize_dungeon_generation(list/metadata, loader_id)
	if(generated)
		return
	veilbreak_initialize_zlevel(dungeon_z_level, metadata)
	SSatoms.map_loader_stop(loader_id)
	generating = FALSE
	generated = TRUE
	if(connected_control_computer)
		connected_control_computer.on_generation_success()

	target_turf = get_target_turf()

/datum/portal_destination/veilbreak/proc/post_transfer(atom/movable/AM)
	if(ismob(AM))
		var/mob/M = AM
		if(M.client)
			M.client.move_delay = max(world.time + 5, M.client.move_delay)

/datum/portal_destination/veilbreak/proc/cleanup_z_level_completely(z_level, turf/ejection_turf)
	if(cleanup_in_progress)
		return
	cleanup_in_progress = TRUE
	//veilbreak_cleanup_zlevel(z_level, ejection_turf, src)

/datum/portal_destination/veilbreak/proc/generation_failed(reason)
	generating = FALSE
	generated = FALSE
	generation_progress = 0
	current_request_id = 0
	if(connected_control_computer)
		connected_control_computer.on_generation_failed(reason)


/datum/portal_destination/veilbreak/proc/get_target_turf()
	if(!dungeon_z_level)
		return null
	return locate(round(DUNGEON_WIDTH / 2), round(DUNGEON_HEIGHT / 2), dungeon_z_level)
