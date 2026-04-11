/obj/machinery/portal
	name = "Dimensional Portal"
	desc = "A massive ring of superconducting magnets and exotic matter emitters."
	icon = 'icons/obj/machines/gateway.dmi'
	icon_state = "portal_frame"
	density = FALSE
	anchored = TRUE
	pixel_x = -32
	pixel_y = -32
	use_power = IDLE_POWER_USE
	idle_power_usage = 100
	active_power_usage = PORTAL_ACTIVE_POWER_USAGE
	var/transport_active = FALSE
	var/datum/portal_destination/veilbreak/target
	var/obj/machinery/computer/portal_control/linked_console
	var/obj/effect/portal_bumper/bumper
	var/is_dungeon_portal = FALSE

/obj/machinery/portal/Initialize(mapload)
	. = ..()
	var/turf/curr_turf = get_turf(src)
	if(curr_turf && is_veilbreak_portal_dungeon_z(curr_turf.z))
		is_dungeon_portal = TRUE
		transport_active = FALSE
		return

	if(!GLOB.station_veilbreak_portal)
		GLOB.station_veilbreak_portal = src
	is_dungeon_portal = FALSE

/obj/machinery/portal/proc/setup_as_return_portal(obj/machinery/portal/station_portal)
	transport_active = TRUE
	is_dungeon_portal = TRUE
	use_power = NO_POWER_USE

	var/obj/machinery/portal/P = station_portal
	if(!P)
		P = GLOB.station_veilbreak_portal
		if(!P)
			return

	var/datum/portal_destination/veilbreak/home = new()
	home.generated = TRUE
	home.dungeon_z_level = z

	if(target && istype(target, /datum/portal_destination/veilbreak))
		var/datum/portal_destination/veilbreak/source = target
		if(source.gateway_location)
			home.gateway_location = source.gateway_location.Copy()

	home.target_turf = get_step(P, SOUTH)
	home.spawn_station_portal = P
	target = home

	if(P)
		if(!P.target || !istype(P.target, /datum/portal_destination/veilbreak))
			P.target = home
		P.transport_active = TRUE
		P.update_appearance()

	activate_bumpers()
	update_appearance()
	log_world("Veilbreak Debug: Dungeon portal at ([x],[y],[z]) fully configured and bumpers activated")

/obj/machinery/portal/update_overlays()
	. = ..()
	if(transport_active)
		. += "portal_light"

/obj/machinery/portal/proc/transfer(atom/movable/AM)
	if(!target || !transport_active || !target.generated)
		return

	var/turf/destination_turf

	if(is_dungeon_portal)
		var/obj/machinery/portal/station_portal = null
		if(target && istype(target, /datum/portal_destination/veilbreak))
			var/datum/portal_destination/veilbreak/V = target
			if(V.spawn_station_portal)
				station_portal = V.spawn_station_portal

		if(!station_portal)
			station_portal = GLOB.station_veilbreak_portal

		if(station_portal)
			destination_turf = get_step(station_portal, SOUTH)
		else
			destination_turf = get_step(src, SOUTH)
	else
		var/datum/portal_destination/veilbreak/V = target
		if(V)
			if(V.gateway_location)
				var/gx = V.gateway_location["world_x"]
				var/gy = V.gateway_location["world_y"]
				if(isnum(gx) && isnum(gy))
					destination_turf = locate(gx, gy, V.dungeon_z_level)
			if(!destination_turf)
				destination_turf = V.get_target_turf()

	if(destination_turf)
		AM.forceMove(destination_turf)
		if(target)
			target.post_transfer(AM)

/obj/machinery/portal/Destroy()
	if(linked_console)
		linked_console.linked_portal = null
		linked_console = null
	emergency_ejection()
	if(bumper)
		qdel(bumper)
		bumper = null
	return ..()

/obj/machinery/portal/proc/emergency_ejection()
	if(!target || !target.dungeon_z_level)
		log_world("Veilbreak Error: emergency_ejection called with no target or dungeon_z_level")
		return

	var/turf/eject_to = get_step(src, SOUTH)
	if(!eject_to)
		eject_to = get_turf(src)
		log_world("Veilbreak Warning: Could not find turf south of station portal, using portal turf")

	var/z_to_clear = target.dungeon_z_level
	log_world("Veilbreak: Emergency ejecting players from Z-level [z_to_clear] to [eject_to ? "[eject_to.x],[eject_to.y],[eject_to.z]" : "null"]")

	var/ejected_count = 0
	for(var/mob/M in GLOB.mob_list)
		if(M.z == z_to_clear)
			if(M.client || (M.mind && M.mind.active))
				log_world("Veilbreak: Ejecting [M.name] ([M.key]) from [M.x],[M.y],[M.z] to [eject_to.x],[eject_to.y],[eject_to.z]")
				M.forceMove(eject_to)
				ejected_count++
			else if(istype(M, /mob/living/carbon/human) && M.stat == DEAD)
				var/mob/living/carbon/human/H = M
				if(H.mind || H.client)
					log_world("Veilbreak: Ejecting corpse of [H.name] from [H.x],[H.y],[H.z]")
					H.forceMove(eject_to)
					ejected_count++
			else if(istype(M, /mob/living/silicon/robot))
				log_world("Veilbreak: Ejecting borg [M.name] from [M.x],[M.y],[M.z]")
				M.forceMove(eject_to)
				ejected_count++

	log_world("Veilbreak: Ejected [ejected_count] mobs from dungeon Z-level")

	target.cleanup_z_level_completely(z_to_clear, eject_to)
	target = null
	transport_active = FALSE
	update_appearance()

/obj/machinery/portal/proc/activate_bumpers()
	if(bumper)
		qdel(bumper)
		bumper = null

	var/turf/portal_turf = get_turf(src)
	if(!portal_turf)
		log_world("Veilbreak Error: Could not create bumper for portal at [x],[y],[z] - no turf found")
		return FALSE

	var/turf/center_turf = portal_turf

	bumper = new /obj/effect/portal_bumper(center_turf, src)
	log_world("Veilbreak Debug: Activated bumper at visual center [center_turf.x],[center_turf.y],[center_turf.z]")
	return TRUE


/obj/effect/portal_bumper
	name = "portal energy field"
	icon = 'icons/obj/machines/gateway.dmi'
	icon_state = "portal_effect"
	density = TRUE
	invisibility = 0
	/// Match /obj/machinery/portal so portal_effect aligns with the shifted gateway art.
	pixel_x = -32
	pixel_y = -32
	var/obj/machinery/portal/parent_portal

/obj/effect/portal_bumper/Initialize(loc, obj/machinery/portal/P)
	. = ..()
	parent_portal = P

/obj/effect/portal_bumper/Bumped(atom/movable/AM)
	. = ..()
	if(parent_portal && parent_portal.transport_active)
		if(ismob(AM) && !isobserver(AM))
			parent_portal.transfer(AM)

/obj/effect/portal_bumper/Crossed(atom/movable/AM)
	. = ..()
	if(parent_portal && parent_portal.transport_active)
		if(ismob(AM) && !isobserver(AM))
			parent_portal.transfer(AM)
