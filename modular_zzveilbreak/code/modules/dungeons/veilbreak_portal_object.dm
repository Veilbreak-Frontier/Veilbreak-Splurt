/obj/machinery/portal
	name = "Dimensional Portal"
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
		home.dungeon_z_level = P.z

		target = home
		update_appearance()

/obj/machinery/portal/process(seconds_per_tick)
	if(!anchored || !powered())
		if(transport_active)
			transport_active = FALSE
			emergency_ejection()
			update_appearance()
		return
	if(target?.generated && !transport_active)
		transport_active = TRUE
		update_appearance()
	if(transport_active)
		use_energy(active_power_usage * seconds_per_tick)
	else
		use_energy(idle_power_usage * seconds_per_tick)

/obj/machinery/portal/proc/emergency_ejection()
	if(!target || !target.dungeon_z_level)
		return
	var/turf/eject_to = get_step(src, dir) || src.loc
	var/z_to_clear = target.dungeon_z_level
	for(var/mob/M in GLOB.mob_list)
		if(M.z != z_to_clear)
			continue
		if(M.client || M.mind)
			if(isobserver(M))
				continue
			M.forceMove(eject_to)
			var/turf/target_turf = get_edge_target_turf(eject_to, dir)
			M.throw_at(target_turf, 10, 3)
			if(istype(M, /mob/living/silicon))
				playsound(eject_to, 'sound/effects/sparks/sparks1.ogg', 50, TRUE)
			else
				playsound(eject_to, 'sound/effects/sparks/sparks4.ogg', 50, TRUE)
		CHECK_TICK
	target.cleanup_z_level_completely(z_to_clear, eject_to)


/obj/machinery/portal/update_overlays()
	. = ..()
	if(transport_active)
		. += "portal_light"

/obj/machinery/portal/proc/transfer(atom/movable/AM)
	if(!target || !transport_active)
		return

	var/turf/destination_turf
	if(SSmapping.level_trait(src.z, PORTAL_TRAIT_DUNGEON))
		destination_turf = get_step(GLOB.station_veilbreak_portal, SOUTH)
	else
		destination_turf = target.get_target_turf()

	if(destination_turf)
		AM.forceMove(destination_turf)
		target.post_transfer(AM)

/obj/effect/portal_bumper
	name = "portal energy field"
	icon = 'icons/obj/machines/gateway.dmi'
	icon_state = "portal_effect"
	density = TRUE
	invisibility = 101
	var/obj/machinery/portal/parent_portal

/obj/effect/portal_bumper/New(loc, obj/machinery/portal/P)
	..()
	parent_portal = P

/obj/effect/portal_bumper/Crossed(atom/movable/AM)
	if(parent_portal && parent_portal.transport_active)
		parent_portal.transfer(AM)

/obj/machinery/portal/Destroy()
	emergency_ejection()
	if(bumper)
		qdel(bumper)
	return ..()

/datum/design/board/portal_control
	name = "Portal Control Console Board"
	desc = "Allows for the construction of circuit boards used to build a Portal Control Console."
	id = "portal_control"
	build_path = /obj/item/circuitboard/computer/portal_control
	category = list(RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_ENGINEERING)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/portal_machine
	name = "Dimensional Portal Machine Board"
	desc = "Allows for the construction of circuit boards used to build a Dimensional Portal."
	id = "portal_machine"
	build_path = /obj/item/circuitboard/machine/portal
	category = list(RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING
