#define OVERRIDE_ALARM_PERIOD 45 SECONDS

// Define the custom Tarkon terminal path for map tracking
/obj/machinery/computer/crew/tarkon
	name = "Tarkon Crew Monitoring Console"
	desc = "Used to monitor active health sensors built into Tarkon military uniforms."
	icon_state = "crew_tarkon"

// Define the administrative omni-monitoring console type
/obj/machinery/computer/crew/admin
	name = "Master Crew Monitoring Console"
	desc = "An unrestricted, high-clearance terminal that aggregates all medical sensor signatures across all networks."
	icon_state = "crew_admin"

/**
 * STRICT FACTION MATCH MATRIX:
 * Ensures absolute network isolation. Consoles will only ever scan and display
 * tracking signatures that match their native faction properties.
 */
/obj/machinery/computer/crew/proc/is_faction_authorized(mob/living/M)
	if(!istype(M))
		return FALSE

	var/console_faction = src.get_console_faction()

	// 1. Handle Admin Omni-Monitoring Clearance
	if(console_faction == "admin")
		return TRUE // Bypasses all faction blocks and maps everything globally!

	// 2. Handle Tarkon network isolation
	if(console_faction == "tarkon")
		if(M.faction && (("tarkon" in M.faction) || ("Port Tarkon Survivor" in M.faction)))
			return TRUE
		return FALSE

	// 3. Handle Nanotrasen / Main Station network isolation
	if(console_faction == "nanotrasen")
		// If they belong to an external or hostile faction group, filter them out completely
		if(M.faction)
			if(("tarkon" in M.faction) || ("Port Tarkon Survivor" in M.faction) || ("void" in M.faction) || ("syndicate" in M.faction) || ("pirate" in M.faction) || ("Abductor" in M.faction) || ("cult" in M.faction) || ("ashwalker" in M.faction))
				return FALSE
		return TRUE

	return FALSE

/**
 * Helper to determine console faction safely from type variations or icon overrides
 */
/obj/machinery/computer/crew/proc/get_console_faction()
	if(src.type == /obj/machinery/computer/crew/tarkon || initial(src.icon_state) == "crew_tarkon")
		return "tarkon"
	if(src.type == /obj/machinery/computer/crew/admin || initial(src.icon_state) == "crew_admin")
		return "admin"
	return "nanotrasen"

/**
 * GLOBAL OVERRIDE: Refactor the alarm beep logic to process cross-Z checks globally
 * while respecting the strict faction isolation rule and verified sound paths.
 */
/obj/machinery/computer/crew/alarm()
	if(machine_stat & (NOPOWER|BROKEN))
		return

	canalarm = FALSE

	for(var/mob/living/carbon/human/mob in GLOB.suit_sensors_list)
		if(!istype(mob))
			GLOB.suit_sensors_list -= mob
			continue

		// Apply strict faction check
		if(!is_faction_authorized(mob))
			continue

		// Removed the old station_level check block entirely to support all Z levels globally
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
		// Fixed sound pathway asset to point to the exact verified subdirectory path
		playsound(src.loc, 'sound/machines/beep/twobeep.ogg', 50, FALSE)

	alarm_timer = addtimer(CALLBACK(src, PROC_REF(alarm)), SENSORS_UPDATE_PERIOD)

/**
 * GLOBAL OVERRIDE: Re-engineer the telemetry compiler to fetch cross-Z sensor records
 * and hide any signatures that do not match the terminal's home faction.
 */
/datum/crewmonitor/update_data(z)
	var/list/results = list()

	// Dynamically acquire the physical console host driving this UI instance
	var/obj/machinery/computer/crew/console = ui_host(usr)
	var/has_console = istype(console)

	for(var/tracked_mob in GLOB.suit_sensors_list | GLOB.nanite_sensors_list)
		if(!tracked_mob)
			continue

		var/mob/living/tracked_living_mob = tracked_mob
		var/turf/pos = get_turf(tracked_living_mob)
		if(!pos)
			continue

		// Strict Faction Isolation Validation
		if(has_console && !console.is_faction_authorized(tracked_living_mob))
			continue

		var/sensor_mode
		var/has_monitoring_nanites = FALSE
		var/mob/living/carbon/human/tracked_human = tracked_living_mob

		if(tracked_living_mob in GLOB.nanite_sensors_list)
			sensor_mode = SENSOR_COORDS
			has_monitoring_nanites = TRUE
		else if(!istype(tracked_human))
			continue
		else
			var/obj/item/clothing/under/uniform = tracked_human.w_uniform
			if(!istype(uniform))
				continue
			if(uniform.has_sensor <= NO_SENSORS)
				continue
			if(!uniform.sensor_mode)
				continue
			sensor_mode = uniform.sensor_mode

		var/list/entry = list()
		entry["name"] = tracked_living_mob.real_name

		// Map global position tracking coordinates directly across all Z levels
		entry["x"] = pos.x
		entry["y"] = pos.y
		entry["z"] = pos.z

		// Assign clear interface labels for custom ghost roles
		var/assignment = "Unknown"
		if(has_monitoring_nanites)
			assignment = tracked_living_mob.mind?.assigned_role?.title || "Unassigned"
		else if(tracked_human.mind?.assigned_role)
			assignment = tracked_human.mind.assigned_role.title
		else if(tracked_living_mob.faction)
			if("tarkon" in tracked_living_mob.faction)
				assignment = "Tarkon Operative"
			else if("vitezstvi" in tracked_living_mob.faction)
				assignment = "Vitezstvi Mercenary"

		entry["assignment"] = assignment

		// Calculate health telemetry metrics
		var/dam_brute = tracked_living_mob.getBruteLoss()
		var/dam_fire  = tracked_living_mob.getFireLoss()
		var/dam_tox   = tracked_living_mob.getToxLoss()
		var/dam_oxy   = tracked_living_mob.getOxyLoss()

		entry["ijam"] = sensor_mode

		if(tracked_living_mob.stat == DEAD)
			entry["life_status"] = 0
		else if(tracked_living_mob.health <= 0)
			entry["life_status"] = 2
		else
			entry["life_status"] = 1

		if(sensor_mode >= SENSOR_VITALS)
			entry["vitals"] = list(
				"brute" = dam_brute,
				"burn"  = dam_fire,
				"tox"   = dam_tox,
				"oxy"   = dam_oxy,
				"health"= tracked_living_mob.health
			)

		results += list(entry)

	return results
