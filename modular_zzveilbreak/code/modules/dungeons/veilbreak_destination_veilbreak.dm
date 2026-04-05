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

	if(dungeon_z_level && dungeon_z_level <= world.maxz)
		cleanup_z_level_completely(dungeon_z_level, null)
	else
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
			level_name = "Veilbreak"
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
	var/temp_file = "data/veilbreak_temp_[dungeon_z_level].dmm"
	text2file(dmm_content, temp_file)

	var/file_content = file2text(temp_file)
	var/list/lines = splittext(file_content, "\n")
	var/list/grid_lines = list()
	var/list/key_values = list()
	var/in_grid = FALSE

	for(var/line in lines)
		if(findtext(line, "(1,1,1) = {"))
			in_grid = TRUE
			continue
		if(in_grid && findtext(line, "}"))
			break
		if(in_grid)
			var/trimmed = trim(line)
			if(length(trimmed) >= 2)
				var/first_char = copytext(trimmed, 1, 2)
				var/last_char = copytext(trimmed, length(trimmed))
				if(first_char == "\"" && last_char == "\"")
					grid_lines += copytext(trimmed, 2, -1)
		else if(findtext(line, "\"") && findtext(line, " = ("))
			var/quote_start = findtext(line, "\"")
			var/quote_end = findtext(line, "\"", quote_start + 1)
			if(quote_start && quote_end)
				var/key = copytext(line, quote_start + 1, quote_end)
				var/paren_start = findtext(line, "(", quote_end)
				if(paren_start)
					var/value = copytext(line, paren_start + 1)
					var/paren_end = findtext(value, ")")
					if(paren_end)
						value = copytext(value, 1, paren_end)
						key_values[key] = value

	fdel(temp_file)

	var/height = length(grid_lines)
	if(height == 0)
		generation_failed("No grid data found")
		return

	var/width = length(grid_lines[1])
	var/loaded = 0

	for(var/y in 1 to height)
		var/row = grid_lines[y]
		for(var/x in 1 to width)
			var/key = copytext(row, x, x + 1)
			var/value = key_values[key]
			if(!value)
				continue

			var/list/path_parts = splittext(value, ",")
			var/turf_path = null
			var/area_path = null
			var/obj_paths = list()

			for(var/part in path_parts)
				var/trimmed_path = trim(part)
				if(findtext(trimmed_path, "/turf/"))
					turf_path = text2path(trimmed_path)
				else if(findtext(trimmed_path, "/area/"))
					area_path = text2path(trimmed_path)
				else
					var/obj_path = text2path(trimmed_path)
					if(obj_path && ispath(obj_path, /obj))
						obj_paths += obj_path

			if(!turf_path)
				continue

			var/turf/T = locate(x, y, dungeon_z_level)
			if(!T)
				T = new turf_path(locate(x, y, dungeon_z_level))
			else if(T.type != turf_path)
				T.ChangeTurf(turf_path)

			if(area_path)
				var/area/A = new area_path()
				A.contents += T

			for(var/obj_path in obj_paths)
				new obj_path(T)

			loaded++
			if(loaded % 100 == 0)
				CHECK_TICK

	addtimer(CALLBACK(src, .proc/finalize_dungeon_generation, metadata), 1 SECONDS)

/datum/portal_destination/veilbreak/proc/finalize_dungeon_generation(list/metadata)
	if(generated)
		return
	if(!dungeon_z_level)
		generating = FALSE
		generation_failed("No dungeon Z-level assigned")
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
			if(cleaned % 50 == 0)
				CHECK_TICK
	cleaned = 0
	for(var/obj/O in world)
		if(O.z == z_level && O != src)
			qdel(O)
			cleaned++
			if(cleaned % 100 == 0)
				CHECK_TICK
	cleaned = 0
	for(var/turf/T in block(locate(1, 1, z_level), locate(world.maxx, world.maxy, z_level)))
		if(T && T.z == z_level)
			qdel(T)
			cleaned++
			if(cleaned % 200 == 0)
				CHECK_TICK
	cleanup_in_progress = FALSE

/datum/portal_destination/veilbreak/proc/generation_failed(reason)
	generating = FALSE
	generated = FALSE
	generation_progress = 0
	current_request_id = 0
	if(temp_map_file && fexists(temp_map_file))
		fdel(temp_map_file)
		temp_map_file = null
	if(connected_control_computer)
		connected_control_computer.on_generation_failed(reason)

/datum/portal_destination/veilbreak/proc/get_target_turf()
	if(!dungeon_z_level)
		return null
	return locate(round(DUNGEON_WIDTH / 2), round(DUNGEON_HEIGHT / 2), dungeon_z_level)
