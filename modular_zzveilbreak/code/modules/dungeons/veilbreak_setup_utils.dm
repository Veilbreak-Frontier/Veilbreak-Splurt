/proc/veilbreak_initialize_zlevel(z_level, list/metadata)
	var/list/turfs = Z_TURFS(z_level)

	SSatoms.InitializeAtoms(turfs)
	CHECK_TICK

	veilbreak_init_atmos_local(turfs)
	CHECK_TICK

	veilbreak_init_lighting_local(turfs)
	CHECK_TICK

	veilbreak_init_smoothing_local(turfs)
	CHECK_TICK

	veilbreak_init_power_local(z_level)
	CHECK_TICK

	veilbreak_init_ai_local(turfs)
	CHECK_TICK

	veilbreak_activate_return_portal(z_level, metadata)

	for(var/turf/T in turfs)
		T.update_appearance(UPDATE_ICON)

	return TRUE

/proc/veilbreak_init_atmos_local(list/turfs)
	var/i = 0
	for(var/turf/open/OT in turfs)
		i++
		if(!istype(OT))
			continue

		if(!OT.air)
			OT.air = new /datum/gas_mixture()

		if(OT.initial_gas_mix)
			var/datum/gas_mixture/parsed = SSair.parse_gas_string(OT.initial_gas_mix)
			if(parsed)
				OT.air.copy_from(parsed)
				qdel(parsed)

		OT.air.archive()

		if(!(OT in SSair.active_turfs))
			SSair.active_turfs += OT

		if(i % 100 == 0)
			CHECK_TICK

/proc/veilbreak_init_lighting_local(list/turfs)
	var/i = 0
	for(var/turf/T in turfs)
		i++
		if(T.lighting_object)
			continue

		var/area/A = T.loc
		if(!A || !A.static_lighting)
			continue

		new /datum/lighting_object(T)

		if(i % 200 == 0)
			CHECK_TICK

	SSlighting.fire(resumed = FALSE, init_tick_checks = FALSE)

/proc/veilbreak_init_smoothing_local(list/turfs)
	var/i = 0
	for(var/turf/T in turfs)
		i++
		if(T.smoothing_groups || T.canSmoothWith)
			SSicon_smooth.add_to_queue(T)

		for(var/obj/O in T)
			if(O.smoothing_groups)
				SSicon_smooth.add_to_queue(O)

		if(i % 150 == 0)
			CHECK_TICK

/proc/veilbreak_init_power_local(z_level)
	var/list/cables = list()
	for(var/obj/structure/cable/C in world)
		if(C.z == z_level)
			cables += C

	if(length(cables))
		SSmachines.setup_template_powernets(cables)

/proc/veilbreak_init_ai_local(list/turfs)
	var/i = 0
	for(var/turf/T in turfs)
		for(var/mob/living/L in T)
			i++
			if(L.ai_controller)
				L.ai_controller.set_ai_status(AI_STATUS_ON)

		if(i >= 20)
			i = 0
			CHECK_TICK

/proc/veilbreak_activate_return_portal(z_level, list/metadata)
	var/obj/machinery/portal/exit_portal
	var/list/p_loc = metadata?["portal_location"]

	if(p_loc && p_loc["x"] && p_loc["y"])
		var/turf/origin = locate(p_loc["x"], p_loc["y"], z_level)
		exit_portal = locate(/obj/machinery/portal) in range(2, origin)

	if(!exit_portal)
		for(var/turf/T in Z_TURFS(z_level))
			exit_portal = locate(/obj/machinery/portal) in T
			if(exit_portal)
				break

	var/obj/machinery/portal/S = GLOB.station_veilbreak_portal
	if(exit_portal && istype(S))
		var/datum/portal_destination/veilbreak/back_home = new()
		back_home.target_turf = get_turf(S)
		back_home.generated = TRUE
		exit_portal.target = back_home
		exit_portal.transport_active = TRUE
		exit_portal.update_appearance(UPDATE_ICON)

/proc/veilbreak_cleanup_zlevel(z_level, turf/ejection_turf, datum/portal_destination/veilbreak/dest_datum)
	var/obj/machinery/portal/S = GLOB.station_veilbreak_portal
	if(istype(S))
		S.transport_active = FALSE
		S.update_appearance(UPDATE_ICON)

	var/list/z_turfs = Z_TURFS(z_level)
	for(var/i in 1 to length(z_turfs))
		var/turf/T = z_turfs[i]
		for(var/atom/movable/AM as anything in T.contents)
			if(ismob(AM))
				if(!isobserver(AM))
					AM.forceMove(ejection_turf)
				continue
			qdel(AM)

		T.ChangeTurf(/turf/open/space)
		if(i % 100 == 0)
			CHECK_TICK

	if(dest_datum)
		qdel(dest_datum)
