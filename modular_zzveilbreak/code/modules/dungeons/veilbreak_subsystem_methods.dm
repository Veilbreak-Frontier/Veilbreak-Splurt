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
		if(processed % 50 == 0)
			CHECK_TICK

/proc/veilbreak_init_smoothing(z_level)
	var/list/z_turfs = block(locate(1, 1, z_level), locate(world.maxx, world.maxy, z_level))
	var/i = 0
	for(var/turf/T in z_turfs)
		T.smooth_icon()
		i++
		if(i % 100 == 0)
			CHECK_TICK

/proc/veilbreak_final_ai_prep(z_level)
	var/verified_count = 0
	for(var/mob/living/L in world)
		if(L.z != z_level || !L.ai_controller)
			continue

		if(!(L in GLOB.basic_mobs))
			GLOB.basic_mobs += L

		L.ai_controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, null)

		L.ai_controller.set_ai_status(AI_STATUS_ON)

		verified_count++
		if(verified_count % 20 == 0)
			CHECK_TICK
