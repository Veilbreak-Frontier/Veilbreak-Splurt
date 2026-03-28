/proc/veilbreak_init_areas_power(z_level)
	for(var/area/A in world)
		if(A.z != z_level)
			continue

		A.power_equip = TRUE
		A.power_light = TRUE
		A.power_environ = TRUE
		A.always_unpowered = FALSE

		if(A.apc)
			var/obj/machinery/power/apc/APC = A.apc
			APC.operating = TRUE
			APC.equipment = 3
			APC.lighting = 3
			APC.environ = 3
			APC.chargemode = FALSE
			if(APC.cell)
				APC.cell.charge = APC.cell.maxcharge
			APC.update_appearance()

		A.power_change()

/proc/veilbreak_init_machinery(z_level)
	var/processed = 0
	for(var/obj/machinery/M in world)
		if(M.z != z_level)
			continue
		M.power_change()
		if(istype(M, /obj/machinery/door))
			var/obj/machinery/door/D = M
			D.update_appearance()
		processed++
		if(processed % 100 == 0)
			CHECK_TICK

/proc/veilbreak_init_smoothing(z_level)
	var/list/z_turfs = block(locate(1, 1, z_level), locate(world.maxx, world.maxy, z_level))
	for(var/i in 1 to length(z_turfs))
		var/turf/T = z_turfs[i]

		if(T.smoothing_flags & USES_SMOOTHING)
			SSicon_smooth.add_to_queue(T)

		for(var/obj/O in T)
			if(O.smoothing_flags & USES_SMOOTHING)
				SSicon_smooth.add_to_queue(O)

		if(i % 500 == 0)
			CHECK_TICK

/proc/veilbreak_final_ai_prep(z_level)
	for(var/mob/living/basic/M in GLOB.basic_mobs)
		if(M.z != z_level || QDELETED(M))
			continue
		if(M.ai_controller)
			M.ai_controller.set_ai_status(AI_STATUS_ON)
