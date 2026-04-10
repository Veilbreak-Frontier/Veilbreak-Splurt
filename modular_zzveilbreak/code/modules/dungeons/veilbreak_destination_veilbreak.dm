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
		log_world("Veilbreak Debug: generation_complete skipped - generated=[generated], cleanup=[cleanup_in_progress]")
		return

	log_world("Veilbreak Debug: generation_complete called")
	generating = FALSE
	current_request_id = 0
	last_generation_data = json_data.Copy()
	var/dmm_content = json_data["dmm_content"]
	var/list/metadata = json_data["metadata"]

	if(metadata && metadata["key_positions"] && metadata["key_positions"]["gateway"])
		var/list/gateway = metadata["key_positions"]["gateway"]
		gateway_location = list("x" = gateway["x"], "y" = gateway["y"])
		log_world("Veilbreak Debug: Gateway location stored at ([gateway_location["x"]],[gateway_location["y"]])")
	else
		gateway_location = null
		log_world("Veilbreak Debug: No gateway location found in metadata")

	log_world("Veilbreak Debug: dmm_content length = [length(dmm_content)]")

	if(!dmm_content || length(dmm_content) < 100)
		log_world("Veilbreak Debug: dmm_content too short")
		generation_failed("Invalid map data")
		return

	var/newly_created_z = FALSE
	if(dungeon_z_level && dungeon_z_level <= world.maxz)
		log_world("Veilbreak Debug: reusing existing Z-level [dungeon_z_level]")
		cleanup_z_level_completely(dungeon_z_level, null)
	else
		log_world("Veilbreak Debug: creating new Z-level")
		newly_created_z = TRUE
		var/list/traits = list(
			ZTRAIT_RESERVED = TRUE,
			ZTRAIT_AWAY = TRUE,
			ZTRAIT_MINING = TRUE,
			ZTRAIT_NOPHASE = TRUE,
			ZTRAIT_NOXRAY = TRUE,
			ZTRAIT_GRAVITY = 1
		)
		var/level_name = (metadata && metadata["map_name"]) ? metadata["map_name"] : null
		if(!level_name)
			level_name = "Veilbreak"
		var/datum/space_level/S = SSmapping.add_new_zlevel(level_name, traits, contain_turfs = FALSE)
		if(!S)
			log_world("Veilbreak Debug: failed to create new Z-level")
			generation_failed("Z-Level allocation failed")
			return
		dungeon_z_level = S.z_value
		GLOB.portal_dungeon_z_level = dungeon_z_level
		SSmapping.update_plane_tracking(S)
		name = level_name
		log_world("Veilbreak Debug: created Z-level [dungeon_z_level] with name [level_name]")

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

/datum/portal_destination/veilbreak/proc/cleanup_z_level_completely(z_level, turf/ejection_turf)
	if(cleanup_in_progress)
		return
	cleanup_in_progress = TRUE

	for(var/turf/T in Z_TURFS(z_level))
		for(var/atom/movable/AM in T)
			if(QDELETED(AM))
				continue

			var/should_eject = FALSE
			var/atom/movable/to_eject = null

			if(istype(AM, /mob/living))
				var/mob/living/L = AM
				if(should_eject_mob(L))
					should_eject = TRUE
					to_eject = L

			if(istype(AM, /obj/item/organ/brain))
				var/obj/item/organ/brain/brain_organ = AM
				if(brain_organ.brainmob && (brain_organ.brainmob.client || brain_organ.brainmob.mind))
					should_eject = TRUE
					to_eject = brain_organ

			if(istype(AM, /obj/item/mmi))
				var/obj/item/mmi/mmi = AM
				if(mmi.brainmob && (mmi.brainmob.client || mmi.brainmob.mind))
					should_eject = TRUE
					to_eject = mmi

			if(should_eject && ejection_turf && to_eject)
				to_eject.forceMove(ejection_turf)
				continue

			if(istype(AM, /mob/living))
				var/mob/living/L = AM
				if(L.ai_controller)
					var/datum/ai_controller/AC = L.ai_controller
					L.ai_controller = null
					qdel(AC)

			qdel(AM)
			if(AM && !QDELETED(AM))
				AM.moveToNullspace()

		T.ChangeTurf(/turf/open/space/basic, flags = CHANGETURF_INHERIT_AIR)

		if(T.x == world.maxx && T.y % 10 == 0)
			CHECK_TICK

	cleanup_in_progress = FALSE

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
		cleanup_z_level_completely(dungeon_z_level, null)
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

	var/linked = 0

	for(var/turf/T in Z_TURFS(dungeon_z_level))
		for(var/obj/machinery/portal/dungeon_portal in T)
			if(QDELETED(dungeon_portal))
				continue

			dungeon_portal.setup_as_return_portal(station)
			dungeon_portal.is_dungeon_portal = TRUE

			if(dungeon_portal.target && istype(dungeon_portal.target, /datum/portal_destination/veilbreak))
				var/datum/portal_destination/veilbreak/dest = dungeon_portal.target
				dest.gateway_location = gateway_location
				dest.spawn_station_portal = station

			linked++

		if(T.x % 100 == 0 && T.y == 1)
			CHECK_TICK

	if(linked)
		log_world("Veilbreak Debug: linked [linked] dungeon portal(s) to station portal at [station.x],[station.y],[station.z]")
		if(gateway_location)
			log_world("Veilbreak Debug: Gateway location set to ([gateway_location["x"]],[gateway_location["y"]]) on Z-level [dungeon_z_level]")
	else
		log_world("Veilbreak Warning: No /obj/machinery/portal found on dungeon Z [dungeon_z_level]")

/datum/portal_destination/veilbreak/proc/get_target_turf()
	log_world("Veilbreak Debug: get_target_turf called - dungeon_z_level=[dungeon_z_level]")

	if(gateway_location && dungeon_z_level)
		var/gx = gateway_location["world_x"]
		var/gy = gateway_location["world_y"]

		if(isnull(gx) || isnull(gy))
			gx = gateway_location["local_x"]
			gy = gateway_location["local_y"]
			if(map_offset_x > 1 || map_offset_y > 1)
				gx = gx + map_offset_x - 1
				gy = gy + map_offset_y - 1
				log_world("Veilbreak Debug: Applied offset to gateway: local([gateway_location["local_x"]],[gateway_location["local_y"]]) -> world([gx],[gy])")

		if(isnum(gx) && isnum(gy))
			var/turf/G = locate(round(gx), round(gy), dungeon_z_level)
			if(G)
				log_world("Veilbreak Debug: get_target_turf (gateway) [G.x],[G.y],[G.z]")
				return G
			else
				log_world("Veilbreak Debug: Gateway turf not found at world ([gx],[gy],[dungeon_z_level])")

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
						log_world("Veilbreak Debug: get_target_turf (metadata gateway) [G.x],[G.y],[G.z]")
						return G

	var/center_x = round(DUNGEON_WIDTH / 2) + map_offset_x - 1
	var/center_y = round(DUNGEON_HEIGHT / 2) + map_offset_y - 1
	var/turf/T = locate(center_x, center_y, dungeon_z_level)
	log_world("Veilbreak Debug: get_target_turf (fallback center) [T ? "[T.x],[T.y],[T.z]" : "null"]")
	return T

/datum/portal_destination/veilbreak/proc/should_eject_mob(mob/living/L)
	if(!istype(L))
		return FALSE

	if(istype(L, /mob/living/carbon/human))
		if(L.client || (L.mind && L.mind.active))
			return TRUE
		if(L.stat == DEAD && (L.mind || L.client))
			return TRUE

	if(istype(L, /mob/living/silicon/robot))
		return TRUE

	if(istype(L, /mob/living/silicon/ai))
		return TRUE

	if(istype(L, /mob/living/brain))
		var/mob/living/brain/brain_mob = L
		if(brain_mob.client || (brain_mob.mind && brain_mob.mind.active))
			return TRUE

	if(L.client)
		return TRUE

	if(L.mind && L.mind.active)
		return TRUE

	return FALSE


/datum/portal_destination/veilbreak/proc/is_player_corpse(mob/living/L)
	if(!istype(L))
		return FALSE

	if(L.stat != DEAD)
		return FALSE

	if(istype(L, /mob/living/carbon/human))
		return TRUE

	if(istype(L, /mob/living/silicon/robot))
		return TRUE

	if(istype(L, /mob/living/brain))
		return TRUE

	return FALSE


/datum/portal_destination/veilbreak/proc/is_debrained(mob/living/carbon/human/H)
	if(!istype(H))
		return FALSE

	var/obj/item/organ/brain/brain = H.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(!brain)
		return TRUE

	if(brain.organ_flags & ORGAN_FAILING)
		return TRUE

	if(brain.organ_flags & ORGAN_FROZEN)
		return TRUE

	return FALSE
