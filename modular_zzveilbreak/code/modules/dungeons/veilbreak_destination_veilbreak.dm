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
	var/temp_map_file

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
	var/list/traits = list(
		ZTRAIT_RESERVED = TRUE,
		ZTRAIT_AWAY = TRUE,
		ZTRAIT_MINING = TRUE,
		ZTRAIT_NOPHASE = TRUE,
		ZTRAIT_NOXRAY = TRUE,
		ZTRAIT_GRAVITY = 1
	)
	var/level_name = metadata["map_name"]
	if(!level_name)
		level_name = "Veilbreak - [world.timeofday]"
	var/datum/space_level/S = SSmapping.add_new_zlevel(level_name, traits)
	if(!S)
		generation_failed("Z-Level allocation failed")
		return
	dungeon_z_level = S.z_value
	GLOB.portal_dungeon_z_level = dungeon_z_level
	SSmapping.update_plane_tracking(S)
	name = level_name
	load_dmm_with_ticks(dmm_content, metadata)

/datum/portal_destination/veilbreak/proc/load_dmm_with_ticks(dmm_content, list/metadata)
	var/temp_file = "data/veilbreak_[dungeon_z_level]_[world.timeofday].dmm"
	text2file(dmm_content, temp_file)

	var/datum/parsed_map/map_loader = new()
	map_loader.original_path = temp_file
	map_loader.map_format = "tgm"
	map_loader.key_len = 2

	var/file_content = file2text(temp_file)
	map_loader.grid_models = list()
	map_loader.gridSets = list()

	var/list/lines = splittext(file_content, "\n")
	var/in_key = FALSE
	var/current_key = ""
	var/current_value = ""

	for(var/line in lines)
		if(!in_key && findtext(line, "\"") && findtext(line, " = ("))
			var/quote_start = findtext(line, "\"")
			var/quote_end = findtext(line, "\"", quote_start + 1)
			if(quote_start && quote_end)
				current_key = copytext(line, quote_start + 1, quote_end)
				current_value = ""
				in_key = TRUE
				var/paren_start = findtext(line, "(", quote_end)
				if(paren_start)
					current_value += copytext(line, paren_start + 1)
		else if(in_key && findtext(line, ")"))
			current_value += line
			map_loader.grid_models[current_key] = current_value
			in_key = FALSE
			current_key = ""
			current_value = ""
		else if(in_key)
			current_value += line + "\n"
		else if(findtext(line, "(1,1,1) = {"))
			var/brace_pos = findtext(line, "{")
			if(brace_pos)
				var/grid_start = findtext(line, "\"", brace_pos)
				if(grid_start)
					var/grid_content = copytext(line, grid_start + 1)
					var/list/grid_lines = splittext(grid_content, "\"")
					var/datum/grid_set/gset = new()
					gset.xcrd = 1
					gset.ycrd = 1
					gset.zcrd = 1
					gset.gridLines = list()
					for(var/i in 1 to length(grid_lines) step 2)
						if(i <= length(grid_lines))
							gset.gridLines += grid_lines[i]
					map_loader.gridSets += gset
					map_loader.line_len = length(gset.gridLines[1])
					map_loader.bounds = list(1, 1, 1, map_loader.line_len, length(gset.gridLines), 1)
					map_loader.parsed_bounds = map_loader.bounds.Copy()

	if(!map_loader.bounds)
		fdel(temp_file)
		generation_failed("Invalid map file structure - no bounds")
		return

	var/list/bounds = map_loader.load(
		x_offset = 1,
		y_offset = 1,
		z_offset = dungeon_z_level,
		crop_map = FALSE,
		no_changeturf = FALSE,
		x_lower = -INFINITY,
		x_upper = INFINITY,
		y_lower = -INFINITY,
		y_upper = INFINITY,
		z_lower = -INFINITY,
		z_upper = INFINITY,
		place_on_top = FALSE,
		new_z = TRUE
	)

	fdel(temp_file)

	if(!bounds)
		generation_failed("Map loading failed - no bounds returned")
		return

	addtimer(CALLBACK(src, .proc/finalize_dungeon_generation, metadata), 1 SECONDS)

/datum/portal_destination/veilbreak/proc/generation_failed(reason)
	log_world("Veilbreak Generation Failed: [reason]")
	log_world("Veilbreak Debug State: generating=[generating], generated=[generated], z_level=[dungeon_z_level]")

	generating = FALSE
	generated = FALSE
	generation_progress = 0
	current_request_id = 0

	if(temp_map_file && fexists(temp_map_file))
		fdel(temp_map_file)
		temp_map_file = null

	if(connected_control_computer)
		connected_control_computer.on_generation_failed(reason)

/world/New()
	. = ..()
	for(var/file in flist("data/"))
		if(findtext(file, "veilbreak_") && findtext(file, ".dmm"))
			fdel("data/[file]")

/datum/portal_destination/veilbreak/proc/finalize_dungeon_generation(list/metadata)
	if(generated)
		return

	if(!dungeon_z_level)
		generating = FALSE
		generation_failed("No dungeon Z-level assigned")
		return

	var/turf/validation_turf = locate(1, 1, dungeon_z_level)
	if(!validation_turf)
		generating = FALSE
		generation_failed("Z-level has no turfs")
		return

	veilbreak_initialize_zlevel(dungeon_z_level, metadata)
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
	var/cleaned = 0
	for(var/mob/M in GLOB.mob_list)
		if(M.z == z_level && !isobserver(M))
			if(ejection_turf)
				M.forceMove(ejection_turf)
			else
				qdel(M)
			cleaned++
			if(cleaned % VEILBREAK_CLEANUP_BATCH_SIZE == 0)
				CHECK_TICK
	cleaned = 0
	for(var/obj/O in world)
		if(O.z == z_level && O != src && !istype(O, /obj/effect/landmark))
			qdel(O)
			cleaned++
			if(cleaned % VEILBREAK_CLEANUP_BATCH_SIZE == 0)
				CHECK_TICK
	cleaned = 0
	for(var/turf/T in block(locate(1, 1, z_level), locate(world.maxx, world.maxy, z_level)))
		if(T && T.z == z_level)
			qdel(T)
			cleaned++
			if(cleaned % VEILBREAK_TURF_PROCESS_BATCH_SIZE == 0)
				CHECK_TICK
	var/datum/space_level/level_to_remove = SSmapping.z_list[z_level]
	if(level_to_remove)
		level_to_remove.traits[ZTRAIT_RESERVED] = FALSE
		level_to_remove.traits[ZTRAIT_AWAY] = FALSE
		level_to_remove.traits[ZTRAIT_MINING] = FALSE
	if(GLOB.portal_dungeon_z_level == z_level)
		GLOB.portal_dungeon_z_level = null
	cleanup_in_progress = FALSE

/datum/portal_destination/veilbreak/proc/get_target_turf()
	if(!dungeon_z_level)
		return null
	return locate(round(DUNGEON_WIDTH / 2), round(DUNGEON_HEIGHT / 2), dungeon_z_level)
