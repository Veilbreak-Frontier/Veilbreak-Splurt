/obj/item/circuitboard/machine/portal
	name = "Circuit board (Dimensional Portal)"
	build_path = /obj/machinery/portal
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/capacitor/adv = 2,
		/obj/item/stock_parts/servo/pico = 1,
		/obj/item/stock_parts/micro_laser/ultra = 1
	)

/datum/design/board/portal_machine
	name = "Dimensional Portal Machine Board"
	desc = "Allows for the construction of circuit boards used to build a Dimensional Portal."
	id = "portal_machine"
	build_path = /obj/item/circuitboard/machine/portal
	category = list(RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/obj/item/circuitboard/computer/portal_control
	name = "Circuit board (Portal Control Console)"
	build_path = /obj/machinery/computer/portal_control

/datum/design/board/portal_control
	name = "Portal Control Console Board"
	desc = "Allows for the construction of circuit boards used to build a Portal Control Console."
	id = "portal_control"
	build_path = /obj/item/circuitboard/computer/portal_control
	category = list(RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_ENGINEERING)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/turf/open/floor/veilbreak
	name = "void-touched floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "floor"

/turf/closed/wall/veilbreak
	name = "void-compressed wall"
	icon = 'icons/turf/walls.dmi'
	icon_state = "wall"

/obj/structure/gateway_exit
	name = "dimensional anchor"
	desc = "Returns travelers to their origin point."
	icon = 'icons/obj/machines/gateway.dmi'
	icon_state = "portal_frame"
	anchored = TRUE
	density = TRUE

/obj/structure/gateway_exit/Initialize(mapload)
	. = ..()
	add_overlay("portal_effect")

/obj/structure/gateway_exit/attack_hand(mob/user)
	. = ..()
	var/obj/machinery/computer/portal_control/C = locate() in world
	if(C)
		user.forceMove(get_turf(C))
		to_chat(user, "The anchor pulls you back through the void.")
