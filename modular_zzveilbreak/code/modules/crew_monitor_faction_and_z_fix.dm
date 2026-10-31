// This patch expands medical monitoring globally across all non-contiguous Z-levels for offstation operations.
// It enforces absolute privacy boundaries via strict faction isolation verification loops across consoles.
#define OVERRIDE_ALARM_PERIOD 45 SECONDS
#define LOCAL_UNKNOWN_JOB_ID 998

/obj/machinery/computer/crew/tarkon
	name = "Tarkon Crew Monitoring Console"
	desc = "Used to monitor active health sensors built into Tarkon military uniforms."
	icon_state = "crew_tarkon"

/obj/machinery/computer/crew/admin
	name = "Master Crew Monitoring Console"
	desc = "An unrestricted, high-clearance terminal that aggregates all medical sensor signatures across all networks."
	icon_state = "crew_admin"

/obj/machinery/computer/crew/proc/is_faction_authorized(mob/living/M)
	if(!istype(M))
		return FALSE

	var/console_faction = src.get_console_faction()

	if(console_faction == "admin")
		return TRUE

	if(console_faction == "tarkon")
		if(M.faction && (("tarkon" in M.faction) || ("Port Tarkon Survivor" in M.faction)))
			return TRUE
		return FALSE

	if(console_faction == "nanotrasen")
		if(M.faction)
			if(("tarkon" in M.faction) || ("Port Tarkon Survivor" in M.faction) || ("void" in M.faction) || ("syndicate" in M.faction) || ("pirate" in M.faction) || ("Abductor" in M.faction) || ("cult" in M.faction) || ("ashwalker" in M.faction))
				return FALSE
		return TRUE

	return FALSE

/obj/machinery/computer/crew/proc/get_console_faction()
	if(src.type == /obj/machinery/computer/crew/tarkon || initial(src.icon_state) == "crew_tarkon")
		return "tarkon"
	if(src.type == /obj/machinery/computer/crew/admin || initial(src.icon_state) == "crew_admin")
		return "admin"
	return "nanotrasen"

/obj/machinery/computer/crew/alarm()
	if(machine_stat & (NOPOWER|BROKEN))
		return

	canalarm = FALSE

	for(var/mob/living/carbon/human/mob in GLOB.suit_sensors_list)
		if(!istype(mob))
			GLOB.suit_sensors_list -= mob
			continue

		if(!is_faction_authorized(mob))
			continue

		var/turf/pos = get_turf(mob)
		if(!pos)
			continue

		var/obj/item/clothing/under/uniform = mob.w_uniform
		if(!istype(uniform) || uniform.has_sensor <= NO_SENSORS || !uniform.sensor_mode)
			GLOB.suit_sensors_list -= mob
			continue

		if(uniform.sensor_mode == SENSOR_COORDS && (uniform.has_sensor != BROKEN_SENSORS) && IS_CRITICAL(mob) || mob.stat == DEAD || isprotean(mob))
			if(mob.get_dnr())
				continue
			if(isprotean(mob))
				if(mob.mind && (mob.mind.assigned_role.title == "Janitor" || mob.mind.assigned_role.title == "Assistant"))
					continue
			canalarm = TRUE
			break

	if(canalarm && COOLDOWN_FINISHED(src, alarm_cooldown))
		COOLDOWN_START(src, alarm_cooldown, OVERRIDE_ALARM_PERIOD)
		playsound(src.loc, 'sound/machines/beep/twobeep.ogg', 50, FALSE)

	alarm_timer = addtimer(CALLBACK(src, PROC_REF(alarm)), SENSORS_UPDATE_PERIOD)

/datum/crewmonitor/update_data(z)
	var/list/results = list()

	var/obj/machinery/computer/crew/console = ui_host(usr)
	var/has_console = istype(console)

	for(var/tracked_mob in GLOB.suit_sensors_list | GLOB.nanite_sensors_list)
		if(!tracked_mob)
			continue

		var/mob/living/tracked_living_mob = tracked_mob
		var/turf/pos = get_turf(tracked_living_mob)
		if(!pos)
			continue

		if(has_console && !console.is_faction_authorized(tracked_living_mob))
			continue

		var/sensor_mode = 0
		var/has_monitoring_nanites = FALSE
		var/mob/living/carbon/human/tracked_human = tracked_living_mob

		if(tracked_living_mob in GLOB.nanite_sensors_list)
			sensor_mode = SENSOR_COORDS
			has_monitoring_nanites = TRUE
		else if(!ishuman(tracked_human))
			continue
		else
			var/obj/item/clothing/under/uniform = tracked_human.w_uniform
			if(!has_monitoring_nanites)
				if(!istype(uniform) || uniform.has_sensor == NO_SENSORS || !uniform.sensor_mode)
					continue
				sensor_mode = uniform.sensor_mode

		var/list/entry = list(
			"ref"         = REF(tracked_living_mob),
			"name"        = "Unknown",
			"ijob"        = LOCAL_UNKNOWN_JOB_ID,
			"life_status" = 0
		)

		var/obj/item/card/id/id_card = tracked_living_mob.get_idcard(hand_first = FALSE)
		if(id_card)
			entry["name"] = id_card.registered_name
			entry["assignment"] = id_card.assignment
			var/trim_assignment = id_card.get_trim_assignment()
			if(jobs[trim_assignment] != null)
				entry["ijob"] = jobs[trim_assignment]

		if(issynthetic(tracked_human) || isprotean(tracked_human))
			entry["is_robot"] = TRUE

		if(tracked_living_mob.stat == DEAD)
			entry["life_status"] = 3
		else if(tracked_living_mob.health <= 0)
			entry["life_status"] = 1
		else
			entry["life_status"] = 0

		if(sensor_mode >= 1)
			entry["area"] = get_area_name(tracked_living_mob, format_text = TRUE)

		if(sensor_mode >= 2)
			entry["is_dnr"]   = tracked_human.get_dnr()
			entry["health"]   = tracked_living_mob.health
			entry["oxydam"]   = tracked_living_mob.getOxyLoss()
			entry["toxdam"]   = tracked_living_mob.getToxLoss()
			entry["burndam"]  = tracked_living_mob.getFireLoss()
			entry["brutedam"] = tracked_living_mob.getBruteLoss()

		if(sensor_mode >= 3)
			entry["x"] = pos.x
			entry["y"] = pos.y
			entry["z"] = pos.z

		results += list(entry)

	return results

#undef LOCAL_UNKNOWN_JOB_ID
