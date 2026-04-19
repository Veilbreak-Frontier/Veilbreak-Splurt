/obj/item/circuitboard/machine/portal
	name = "Circuit board (Dimensional Portal)"
	build_path = /obj/machinery/portal
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/capacitor/adv = 2,
		/obj/item/stock_parts/servo/pico = 1,
		/obj/item/stock_parts/micro_laser/ultra = 1
	)

/obj/item/circuitboard/computer/portal_control
	name = "Circuit board (Portal Control Console)"
	build_path = /obj/machinery/computer/portal_control

/datum/design/board/portal_machine
	name = "Dimensional Portal Machine Board"
	desc = "Allows for the construction of circuit boards used to build a Dimensional Portal."
	id = "portal_machine"
	build_type = IMPRINTER
	materials = list(/datum/material/glass = 1000)
	build_path = /obj/item/circuitboard/machine/portal
	category = list(RND_CATEGORY_MACHINE, RND_SUBCATEGORY_MACHINE_ENGINEERING)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/portal_control
	name = "Portal Control Console Board"
	desc = "Allows for the construction of circuit boards used to build a Portal Control Console."
	id = "portal_control"
	build_type = IMPRINTER
	materials = list(/datum/material/glass = 1000)
	build_path = /obj/item/circuitboard/computer/portal_control
	category = list(RND_CATEGORY_COMPUTER, RND_SUBCATEGORY_COMPUTER_ENGINEERING)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/portal_anchor
	name = "Dimensional Anchor"
	desc = "A localized stabilization frame for dimensional travel."
	id = "portal_anchor"
	build_type = PROTOLATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/uranium = SHEET_MATERIAL_AMOUNT * 1
	)
	construction_time = 20 SECONDS
	build_path = /obj/structure/gateway_exit
	category = list(RND_CATEGORY_MACHINE, RND_SUBCATEGORY_MACHINE_ENGINEERING)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/techweb_node/portal_tech
	id = "portal_tech"
	display_name = "Dimensional Folding"
	description = "Advanced bluespace research into the stabilization of long-distance portals."
	prereq_ids = list(TECHWEB_NODE_BLUESPACE_TRAVEL)
	design_ids = list(
		"portal_machine",
		"portal_control",
		"portal_anchor"
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)
