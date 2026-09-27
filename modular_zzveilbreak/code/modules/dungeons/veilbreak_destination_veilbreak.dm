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
	var/obj/machinery/portal/spawn_station_portal
	var/list/last_generation_data
	var/temp_map_file
	var/list/gateway_location = null
	var/map_offset_x = 1
	var/map_offset_y = 1

/datum/portal_destination/veilbreak/proc/start_generation(mob/feedback_target)
	log_world("Veilbreak Debug: start_generation called")
	if(generating || generated || current_request_id)
		log_world("Veilbreak Debug: start_generation blocked - generating=[generating], generated=[generated], request_id=[current_request_id]")
		return FALSE
	if(!subsystems_ready_for_portals(feedback_target))
		log_world("Veilbreak Debug: subsystems not ready")
		return FALSE
	generating = TRUE
	generation_progress = 0
	spawn_station_portal = connected_control_computer?.linked_portal
	if(!GLOB.dungeon_generator)
		log_world("Veilbreak Debug: creating new dungeon_generator")
		GLOB.dungeon_generator = new /datum/http_dungeon_generator()
	current_request_id = GLOB.dungeon_generator.generate_dungeon(src, DUNGEON_WIDTH, DUNGEON_HEIGHT)
	log_world("Veilbreak Debug: generate_dungeon returned request_id=[current_request_id]")
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
	if(generated || cleanup_in_progress)
		return

	generating = FALSE
	current_request_id = 0
	last_generation_data = json_data.Copy()
	var/dmm_content = json_data["dmm_content"]
	var/list/metadata = json_data["metadata"]

	if(metadata && metadata["key_positions"] && metadata["key_positions"]["gateway"])
		var/list/gateway = metadata["key_positions"]["gateway"]
		gateway_location = list("x" = gateway["x"], "y" = gateway["y"])
	else
		gateway_location = null

	if(!dmm_content || length(dmm_content) < 100)
		generation_failed("Invalid map data")
		return

	var/newly_created_z = FALSE

	// Console deactivate deletes the destination datum; the next generate_new starts fresh with
	// dungeon_z_level 0. Re-bind the reserved pocket Z so we wipe and reload that level instead of add_new_zlevel().
	if(!dungeon_z_level || dungeon_z_level < 1 || dungeon_z_level > world.maxz)
		var/glob_z = GLOB.portal_dungeon_z_level
		if(isnum(glob_z) && glob_z >= 1 && glob_z <= world.maxz)
			dungeon_z_level = glob_z

	if(dungeon_z_level && dungeon_z_level <= world.maxz && dungeon_z_level > 0)
		// Detach the station portal from its target BEFORE cleanup. The cleanup
		// path calls veilbreak_shutdown_station_portal_after_z_wipe(), which
		// reads station.target, finds THIS in-flight destination, and resets its
		// generated / generating / current_request_id state mid-setup. That kills
		// the staggered init pipeline that follows (finalize_dungeon_generation ->
		// veilbreak_initialize_zlevel -> step 7). Detaching first makes the
		// shutdown proc's istype() guard reject us and early-return.
		if(spawn_station_portal)
			spawn_station_portal.target = null
			spawn_station_portal.transport_active = FALSE
			if(spawn_station_portal.bumper)
				qdel(spawn_station_portal.bumper)
				spawn_station_portal.bumper = null
			spawn_station_portal.update_appearance()
		// Also detach the global station portal if it's a different instance;
		// the shutdown proc reads GLOB.station_veilbreak_portal, not ours.
		// GLOBAL_VAR() is untyped, so narrow through a typed local first.
		var/obj/machinery/portal/global_station = GLOB.station_veilbreak_portal
		if(global_station && global_station != spawn_station_portal)
			global_station.target = null

		cleanup_z_level_completely(dungeon_z_level, null)
		newly_created_z = FALSE
		var/reuse_level_name = (metadata && metadata["map_name"]) ? metadata["map_name"] : "Veilbreak"
		name = reuse_level_name
	else
		newly_created_z = TRUE
		var/list/traits = list(
			ZTRAIT_RESERVED = TRUE,
			ZTRAIT_AWAY = TRUE,
			ZTRAIT_MINING = TRUE,
			ZTRAIT_NOPHASE = TRUE,
			ZTRAIT_NOXRAY = TRUE,
			ZTRAIT_GRAVITY = 1
		)
		var/level_name = (metadata && metadata["map_name"]) ? metadata["map_name"] : "Veilbreak"
		var/datum/space_level/S = SSmapping.add_new_zlevel(level_name, traits, contain_turfs = FALSE)
		if(!S)
			generation_failed("Z-Level allocation failed")
			return
		dungeon_z_level = S.z_value
		GLOB.portal_dungeon_z_level = dungeon_z_level
		SSmapping.update_plane_tracking(S)
		name = level_name

	veilbreak_init_runtime_space_turfs(dungeon_z_level)
	load_dmm_with_ticks(dmm_content, metadata, newly_created_z)

/datum/portal_destination/veilbreak/proc/load_dmm_with_ticks(dmm_content, list/metadata, newly_created_z)
	log_world("Veilbreak Debug: load_dmm_with_ticks started (parsed_map + initTemplateBounds)")

	var/normalized = veilbreak_normalize_dmm_for_parsed_map(dmm_content)
	if(isnull(normalized))
		generation_failed("Dungeon DMM rejected: tile keys must all be the same length (BYOND parsed_map). Regenerate with tools.veilbreak_mapgen.api service (fixed-width keys) or reduce unique tile types.")
		return

	var/static/regex/regex_has_map_grid = new(@'\(\d+,\d+,\d+\)\s*=\s*\{\"')
	if(!regex_has_map_grid.Find(normalized))
		var/grid_w = DUNGEON_WIDTH
		var/grid_h = DUNGEON_HEIGHT
		if(metadata)
			if(metadata["width"])
				grid_w = clamp(text2num(metadata["width"]) || grid_w, 1, world.maxx)
			if(metadata["height"])
				grid_h = clamp(text2num(metadata["height"]) || grid_h, 1, world.maxy)
		log_world("Veilbreak Warning: API sent no map grid; appending [grid_w]x[grid_h] placeholder (first tile key). Add a real (1,1,1)={\"...\"} section in the service for real layouts.")
		normalized = veilbreak_dmm_append_placeholder_grid(normalized, grid_w, grid_h)
		if(!regex_has_map_grid.Find(normalized))
			generation_failed("Dungeon map still invalid after placeholder grid")
			return

	var/datum/parsed_map/parsed = new(normalized)
	if(!parsed?.bounds)
		log_world("Veilbreak Debug: parsed_map could not parse DMM (missing bounds); first ~500 chars after normalize:")
		log_world(copytext(normalized, 1, 500))
		generation_failed("Dungeon map parse failed")
		return

	if(parsed.map_format == "tgm" && parsed.key_len && parsed.line_len > parsed.key_len)
		log_world("Veilbreak Debug: grid rows are DMM-style (line_len=[parsed.line_len] > key_len=[parsed.key_len]); forcing DMM loader (TGM would mis-read rows)")
		parsed.map_format = "dmm"

	var/placement_x = 1
	var/placement_y = 1

	map_offset_x = placement_x
	map_offset_y = placement_y
	log_world("Veilbreak Debug: Map placement offset set to ([map_offset_x],[map_offset_y])")

	if(gateway_location && gateway_location["local_x"] && gateway_location["local_y"])
		var/local_gx = gateway_location["local_x"]
		var/local_gy = gateway_location["local_y"]
		gateway_location["world_x"] = local_gx + map_offset_x - 1
		gateway_location["world_y"] = local_gy + map_offset_y - 1
		log_world("Veilbreak Debug: Gateway adjusted from local ([local_gx],[local_gy]) to world ([gateway_location["world_x"]],[gateway_location["world_y"]])")

	var/load_ok = parsed.load(
		placement_x,
		placement_y,
		dungeon_z_level,
		crop_map = FALSE,
		no_changeturf = FALSE,
		new_z = newly_created_z,
	)
	if(!load_ok)
		log_world("Veilbreak Debug: parsed_map.load failed")
		generation_failed("Dungeon map load failed")
		return

	require_area_resort()
	var/datum/map_template/init_bounds = new(null, (metadata && metadata["map_name"]) ? metadata["map_name"] : name)
	init_bounds.initTemplateBounds(parsed.bounds)
	smooth_zlevel(dungeon_z_level)

	veilbreak_init_runtime_space_turfs(dungeon_z_level)

	log_world("Veilbreak Debug: map load finished; bounds [parsed.bounds[MAP_MINX]],[parsed.bounds[MAP_MINY]],[parsed.bounds[MAP_MINZ]] -> [parsed.bounds[MAP_MAXX]],[parsed.bounds[MAP_MAXY]],[parsed.bounds[MAP_MAXZ]]")

	var/turf/verify_turf = locate(1, 1, dungeon_z_level)
	if(verify_turf)
		log_world("Veilbreak Debug: verification - turf exists at (1,1,[dungeon_z_level])")
	else
		log_world("Veilbreak Debug: verification FAILED - no turf at (1,1,[dungeon_z_level])")

	addtimer(CALLBACK(src, .proc/finalize_dungeon_generation, metadata), 1 SECONDS)

/datum/portal_destination/veilbreak/proc/find_and_update_gateway_location()
	for(var/turf/T in Z_TURFS(dungeon_z_level))
		for(var/obj/machinery/portal/dungeon_portal in T)
			if(!QDELETED(dungeon_portal) && dungeon_portal.is_dungeon_portal)
				if(gateway_location)
					gateway_location["world_x"] = dungeon_portal.x
					gateway_location["world_y"] = dungeon_portal.y
					log_world("Veilbreak Debug: Updated gateway world coordinates to actual portal position at ([dungeon_portal.x],[dungeon_portal.y],[dungeon_portal.z])")
				else
					gateway_location = list("world_x" = dungeon_portal.x, "world_y" = dungeon_portal.y)
					log_world("Veilbreak Debug: Set gateway world coordinates from portal at ([dungeon_portal.x],[dungeon_portal.y],[dungeon_portal.z])")
				return

/datum/portal_destination/veilbreak/proc/finalize_dungeon_generation(list/metadata)
	if(generating || generated)
		return

	generating = TRUE
	log_world("Veilbreak: Starting staggered initialization for Z [dungeon_z_level]")

	addtimer(CALLBACK(src, .proc/find_and_update_gateway_location), 1)

	veilbreak_initialize_zlevel(dungeon_z_level, metadata, 1)

/datum/portal_destination/veilbreak/proc/post_transfer(atom/movable/AM)
	if(ismob(AM))
		var/mob/M = AM
		if(M.client)
			M.client.move_delay = max(world.time + 5, M.client.move_delay)

/datum/portal_destination/veilbreak/proc/clear_z_level_atoms(z_level)
	for(var/turf/T in Z_TURFS(z_level))
		for(var/atom/movable/AM in T)
			if(istype(AM, /mob/dead/observer))
				continue
			qdel(AM)
		if(T.x % 100 == 0)
			CHECK_TICK

/// After a Z wipe, remove any areas that previously hosted turfs on that Z
/// and now have no contents. Prevents GLOB.areas from accumulating orphaned
/// dungeon-defined area instances across regenerations.
/datum/portal_destination/veilbreak/proc/prune_orphaned_areas_on_z(z_level, list/dungeon_areas)
	if(!length(dungeon_areas))
		return

	// NOTE: on forks where ChangeTurf preserves the turf's area (including
	// recent /tg/), dungeon areas still hold the replacement space turfs, so
	// this loop finds them populated and skips. Pruning a populated area would
	// orphan its turfs, so we leave them alone. The areas persist across
	// regenerations but are bounded by the number of distinct DMM area paths,
	// not by the number of regenerations — the same instance gets reused.
	for(var/area/A as anything in dungeon_areas)
		if(QDELETED(A))
			continue
		if(A.type == /area/space)
			continue
		if(length(A.contents))
			continue
		GLOB.areas -= A
		qdel(A)

/// After the dungeon Z is wiped, the station gateway must go dark (paired dungeon portals are gone).
/// If delete_station_destination_datum, the main /datum/portal_destination/veilbreak (console target) is queued for deletion.
/proc/veilbreak_shutdown_station_portal_after_z_wipe(z_level, delete_station_destination_datum = FALSE)
	var/obj/machinery/portal/station = GLOB.station_veilbreak_portal
	if(!station || QDELETED(station))
		return
	var/datum/portal_destination/veilbreak/V = station.target
	if(!istype(V) || V.dungeon_z_level != z_level)
		return
	if(V.connected_control_computer)
		V.connected_control_computer.generation_in_progress = FALSE
	station.target = null
	station.transport_active = FALSE
	if(station.bumper)
		qdel(station.bumper)
		station.bumper = null
	station.update_appearance()
	V.spawn_station_portal = null
	V.generated = FALSE
	V.generating = FALSE
	V.current_request_id = 0
	if(delete_station_destination_datum)
		QDEL_IN(V, 0)

/datum/portal_destination/veilbreak/proc/cleanup_z_level_completely(z_level, turf/ejection_turf, delete_station_destination_datum = FALSE)
	if(cleanup_in_progress)
		log_world("Veilbreak: cleanup already in progress for Z [z_level], skipping")
		return FALSE
	if(!z_level || z_level < 1 || z_level > world.maxz)
		return FALSE

	cleanup_in_progress = TRUE

	// Resolve a fallback ejection turf up front so players are never stranded
	// when the caller passes null (e.g. the generate_new reuse path).
	if(!ejection_turf)
		var/obj/machinery/portal/station = GLOB.station_veilbreak_portal
		if(station && !QDELETED(station))
			ejection_turf = get_step(station, SOUTH) || get_turf(station)

	// 1. Snapshot every movable on the Z. Iterating world directly while qdel()
	//    detaches contents skips entries and loses atoms inside containers.
	var/list/movables = list()
	for(var/atom/movable/AM as anything in world)
		if(AM.z == z_level)
			movables += AM

	var/list/to_eject = list()
	var/list/to_delete = list()
	for(var/atom/movable/AM as anything in movables)
		// Observers are completely ignored: never ejected, never deleted.
		if(isobserver(AM))
			continue
		if(is_player(AM))
			to_eject += AM
		else
			to_delete += AM

	// 2. Eject players (to the passed turf, or the station fallback above).
	var/processed = 0
	for(var/atom/movable/AM as anything in to_eject)
		if(QDELETED(AM))
			continue
		if(ejection_turf)
			AM.forceMove(ejection_turf)
		processed++
		if(processed % VEILBREAK_CLEANUP_BATCH_SIZE == 0)
			CHECK_TICK

	// 3. Unlink dungeon portals before deleting them so paired aux datums die
	//    cleanly instead of being orphaned by the qdel cascade.
	processed = 0
	for(var/atom/movable/AM as anything in to_delete)
		if(QDELETED(AM))
			continue
		if(istype(AM, /obj/machinery/portal))
			var/obj/machinery/portal/port = AM
			if(port.is_dungeon_portal && istype(port.target, /datum/portal_destination/veilbreak))
				var/datum/portal_destination/veilbreak/aux = port.target
				port.target = null
				if(aux != src)
					qdel(aux)
		processed++
		if(processed % VEILBREAK_CLEANUP_BATCH_SIZE == 0)
			CHECK_TICK

	// 4. Delete everything else.
	processed = 0
	for(var/atom/movable/AM as anything in to_delete)
		if(QDELETED(AM))
			continue
		// Prune global references before deleting so we don't leak basic_mobs refs.
		if(istype(AM, /mob/living/basic))
			GLOB.basic_mobs -= AM
		qdel(AM)
		processed++
		if(processed % VEILBREAK_CLEANUP_BATCH_SIZE == 0)
			CHECK_TICK

	// 5. Snapshot areas hosting turfs on this Z so we can prune orphans after.
	var/list/dungeon_areas = list()
	for(var/turf/T as anything in Z_TURFS(z_level))
		if(T && T.loc)
			dungeon_areas[T.loc] = TRUE

	// 6. Wipe EVERY turf on the Z, not just the DUNGEON_WIDTH x DUNGEON_HEIGHT block.
	//    CHANGETURF_IGNORE_AIR so the fresh turfs get default air, not the old mix.
	processed = 0
	for(var/turf/T as anything in Z_TURFS(z_level))
		if(QDELETED(T))
			continue
		if(T.type != /turf/open/space/basic)
			T.ChangeTurf(/turf/open/space/basic, null, CHANGETURF_IGNORE_AIR)
		processed++
		if(processed % VEILBREAK_TURF_PROCESS_BATCH_SIZE == 0)
			CHECK_TICK

	// 7. Prune areas that were orphaned by the wipe.
	prune_orphaned_areas_on_z(z_level, dungeon_areas)

	// 8. Atmos clean slate: deregister every turf on the Z from SSair and kill
	//    the excited groups that span it.
	atmos_wipe_z_level(z_level)

	generated = FALSE
	cleanup_in_progress = FALSE

	veilbreak_shutdown_station_portal_after_z_wipe(z_level, delete_station_destination_datum)
	return TRUE

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
	if(dungeon_z_level)
		cleanup_z_level_completely(dungeon_z_level, null, TRUE)
	if(connected_control_computer)
		connected_control_computer.on_generation_failed(reason)
	spawn_station_portal = null

/datum/portal_destination/veilbreak/proc/veilbreak_sync_portal_pair()
	var/obj/machinery/portal/station = spawn_station_portal
	if(QDELETED(station))
		station = connected_control_computer?.linked_portal
	if(QDELETED(station))
		station = GLOB.station_veilbreak_portal

	if(!station || QDELETED(station))
		log_world("Veilbreak Warning: No valid station portal found.")
		return

	GLOB.station_veilbreak_portal = station
	station.target = src
	station.transport_active = TRUE
	station.update_appearance()

	station.activate_bumpers()
	log_world("Veilbreak Debug: Station portal at ([station.x],[station.y],[station.z]) bumpers activated")

	var/linked = 0
	var/actual_portal_x = null
	var/actual_portal_y = null

	for(var/turf/T in Z_TURFS(dungeon_z_level))
		for(var/obj/machinery/portal/dungeon_portal in T)
			if(QDELETED(dungeon_portal))
				continue

			dungeon_portal.setup_as_return_portal(station)
			dungeon_portal.is_dungeon_portal = TRUE

			if(dungeon_portal.target && istype(dungeon_portal.target, /datum/portal_destination/veilbreak))
				var/datum/portal_destination/veilbreak/dest = dungeon_portal.target
				dest.gateway_location = list("world_x" = dungeon_portal.x, "world_y" = dungeon_portal.y)
				dest.spawn_station_portal = station
				dest.dungeon_z_level = dungeon_z_level

				actual_portal_x = dungeon_portal.x
				actual_portal_y = dungeon_portal.y

			linked++

		if(T.x % 100 == 0 && T.y == 1)
			CHECK_TICK

	if(linked)
		log_world("Veilbreak Debug: linked [linked] dungeon portal(s) to station portal at [station.x],[station.y],[station.z]")
		if(actual_portal_x && actual_portal_y)
			log_world("Veilbreak Debug: Gateway set to ACTUAL portal position ([actual_portal_x],[actual_portal_y]) on Z-level [dungeon_z_level]")
	else
		log_world("Veilbreak Warning: No /obj/machinery/portal found on dungeon Z [dungeon_z_level]")

/datum/portal_destination/veilbreak/proc/get_target_turf()
	if(gateway_location && dungeon_z_level)
		var/gx = gateway_location["world_x"]
		var/gy = gateway_location["world_y"]
		if(isnum(gx) && isnum(gy))
			var/turf/G = locate(gx, gy, dungeon_z_level)
			if(G)
				return G
		var/local_x = gateway_location["x"]
		var/local_y = gateway_location["y"]
		if(isnum(local_x) && isnum(local_y))
			var/world_x = local_x + map_offset_x - 1
			var/world_y = local_y + map_offset_y - 1
			var/turf/G = locate(world_x, world_y, dungeon_z_level)
			if(G)
				return G

	var/list/meta = last_generation_data?["metadata"]
	if(istype(meta))
		var/list/kp = meta["key_positions"]
		if(istype(kp))
			var/list/gw = kp["gateway"]
			if(istype(gw))
				var/gx = gw["x"]
				var/gy = gw["y"]
				if(map_offset_x > 1 || map_offset_y > 1)
					gx = gx + map_offset_x - 1
					gy = gy + map_offset_y - 1
				if(isnum(gx) && isnum(gy))
					var/turf/G = locate(round(gx), round(gy), dungeon_z_level)
					if(G)
						log_world("Veilbreak Debug: get_target_turf returning metadata gateway at ([gx],[gy],[dungeon_z_level])")
						return G

	var/center_x = round(DUNGEON_WIDTH / 2) + map_offset_x - 1
	var/center_y = round(DUNGEON_HEIGHT / 2) + map_offset_y - 1
	var/turf/T = locate(center_x, center_y, dungeon_z_level)
	log_world("Veilbreak Debug: get_target_turf returning fallback center at [T ? "[T.x],[T.y],[T.z]" : "null"]")
	return T

/proc/is_player(datum/D)
	if(!D || istype(D, /datum/weakref))
		return FALSE

	// Observers are ignored entirely by cleanup: not ejected, not deleted.
	if(isobserver(D))
		return FALSE

	var/mob/living/L
	if(isliving(D))
		L = D
	else if(istype(D, /obj/item/mmi))
		var/obj/item/mmi/I = D
		L = I.brainmob
	else if(istype(D, /obj/item/organ/brain))
		var/obj/item/organ/brain/O = D
		L = O.brainmob
	else if(istype(D, /obj/item/mob_holder))
		var/obj/item/mob_holder/H = D
		L = H.held_mob

	if(!L || !istype(L))
		return FALSE

	// Void creatures are dungeon content, never players.
	if(LAZYFIND(L.faction, "FACTION_VOID"))
		return FALSE

	// Any mob with a ckey or an attached mind is a player, whether or not the
	// client is currently connected. Truly mindless NPCs fall through.
	if(L.ckey || L.client || L.mind)
		return TRUE

	return FALSE

