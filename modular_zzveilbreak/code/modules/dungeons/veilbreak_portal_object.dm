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

/obj/machinery/portal/Initialize(mapload)
	. = ..()
	var/turf/T = get_step(get_step(src, EAST), NORTH)
	bumper = new /obj/effect/portal_bumper(T, src)
	var/turf/curr_turf = get_turf(src)
	if(curr_turf && (SSmapping.level_trait(curr_turf.z, PORTAL_TRAIT_DUNGEON)))
		setup_as_return_portal()
	else
		GLOB.station_veilbreak_portal = src

/obj/machinery/portal/proc/setup_as_return_portal()
	transport_active = TRUE
	use_power = NO_POWER_USE
	if(GLOB.station_veilbreak_portal)
		var/obj/machinery/portal/P = GLOB.station_veilbreak_portal
		var/datum/portal_destination/veilbreak/home = new()
		home.generated = TRUE
		home.dungeon_z_level = z
		home.target_turf = get_turf(P)
		target = home
		update_appearance()

/obj/machinery/portal/update_overlays()
	. = ..()
	if(transport_active)
		. += "portal_light"

/obj/machinery/portal/proc/transfer(atom/movable/AM)
	if(!target || !transport_active || !target.generated)
		return
	var/turf/destination_turf
	if(SSmapping.level_trait(src.z, PORTAL_TRAIT_DUNGEON))
		if(GLOB.station_veilbreak_portal)
			destination_turf = get_step(GLOB.station_veilbreak_portal, SOUTH)
		else
			destination_turf = get_step(src, SOUTH)
	else
		var/datum/portal_destination/veilbreak/V = target
		destination_turf = V.get_target_turf()
	if(destination_turf)
		AM.forceMove(destination_turf)
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
		if(M.z == z_to_clear && !isobserver(M))
			M.forceMove(eject_to)
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
