/obj/machinery/power/entropic_converter
	name = "entropic converter"
	desc = "A machine that converts ambient entropy into usable electrical power."
	icon = 'modular_zzveilbreak/icons/obj/entropic_converter.dmi'
	icon_state = "default"
	anchored = TRUE
	density = TRUE

	circuit = /obj/item/circuitboard/machine/entropic_converter

	processing_flags = START_PROCESSING_ON_INIT

	var/power_output = 200000 // 150 kW

/obj/machinery/power/entropic_converter/Initialize(mapload)
	. = ..()
	connect_to_network()
	RefreshParts()

/obj/machinery/power/entropic_converter/Destroy()
	disconnect_from_network()
	return ..()

/obj/machinery/power/entropic_converter/RefreshParts()
	. = ..()

	var/bonus_power = 0
	for(var/datum/stock_part/capacitor/C in component_parts)
		bonus_power += (C.tier - 1) * 15000
	for(var/datum/stock_part/servo/S in component_parts)
		bonus_power += (S.tier - 1) * 15000
	for(var/datum/stock_part/micro_laser/L in component_parts)
		bonus_power += (L.tier - 1) * 15000

	power_output = 350000 + bonus_power

/obj/machinery/power/entropic_converter/process()
	if(machine_stat & (NOPOWER|BROKEN))
		return

	add_avail(power_output)
	update_appearance()

/obj/item/circuitboard/machine/entropic_converter
	name = "Entropic Converter"
	desc = "The circuit board for an entropic converter."
	greyscale_colors = CIRCUIT_COLOR_GENERIC
	build_path = /obj/machinery/power/entropic_converter
	req_components = list(
		/datum/stock_part/capacitor = 3,
		/datum/stock_part/servo = 3,
		/datum/stock_part/micro_laser = 3
	)
	needs_anchored = TRUE

/datum/design/board/entropic_converter
	name = "Machine Design (Entropic Converter)"
	desc = "Allows for the construction of circuit boards used to build an entropic converter."
	id = "entropic_converter"
	build_path = /obj/item/circuitboard/machine/entropic_converter
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_ENGINEERING
