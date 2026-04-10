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
	var/turf/T = get_step(get_step(src, EAST), NORTH)
	if(T)
		bumper = new /obj/effect/portal_bumper(T, src)

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
		var/datum/portal_destination/veilbreak/V = target
		home.gateway_location = V.gateway_location

	home.target_turf = get_step(P, SOUTH)
	home.spawn_station_portal = P
	target = home

	if(home.gateway_location)
		var/gx = home.gateway_location["x"]
		var/gy = home.gateway_location["y"]
		log_world("Veilbreak Debug: Dungeon portal at ([x],[y],[z]) linked to gateway at ([gx],[gy],[z])")
	else
		log_world("Veilbreak Warning: No gateway location found in metadata")

	if(P)
		if(!P.target || !istype(P.target, /datum/portal_destination/veilbreak))
			P.target = home
		P.transport_active = TRUE
		P.update_appearance()

	update_appearance()

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
			if(V.gateway_location && V.dungeon_z_level)
				var/gx = V.gateway_location["x"]
				var/gy = V.gateway_location["y"]
				destination_turf = locate(round(gx), round(gy), V.dungeon_z_level)
				if(!destination_turf)
					destination_turf = V.get_target_turf()
			else
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
	return ..()

/obj/machinery/portal/proc/emergency_ejection()
	if(!target || !target.dungeon_z_level)
		return
	var/turf/eject_to = get_step(src, SOUTH) || src.loc
	var/z_to_clear = target.dungeon_z_level

	for(var/mob/M in GLOB.mob_list)
		if(M.z == z_to_clear)
			if(istype(M, /mob/living))
				var/mob/living/L = M
				if(target.should_eject_mob(L))
					L.forceMove(eject_to)

	target.cleanup_z_level_completely(z_to_clear, eject_to)
	target = null
	transport_active = FALSE
	update_appearance()

/obj/effect/portal_bumper
	name = "portal energy field"
	icon = 'icons/obj/machines/gateway.dmi'
	icon_state = "portal_effect"
	density = TRUE
	invisibility = 101
	var/obj/machinery/portal/parent_portal

/obj/effect/portal_bumper/Initialize(loc, obj/machinery/portal/P)
	. = ..()
	parent_portal = P

/obj/effect/portal_bumper/Crossed(atom/movable/AM)
	if(parent_portal && parent_portal.transport_active)
		parent_portal.transfer(AM)
