/obj/machinery/power/entropic_converter
	name = "entropic converter"
	desc = "A machine that converts ambient entropy into usable electrical power. Only one may feed a grid per z-level."
	icon = 'modular_zzveilbreak/icons/obj/entropic_converter.dmi'
	icon_state = "default"
	anchored = TRUE
	density = TRUE

	circuit = /obj/item/circuitboard/machine/entropic_converter

	processing_flags = START_PROCESSING_ON_INIT

	/// Power supplied to the grid, in watts (see [/proc/power_to_energy]).
	var/power_output = 500 KILO WATTS

/obj/machinery/power/entropic_converter/Initialize(mapload)
	. = ..()
	connect_to_network()

/obj/machinery/power/entropic_converter/Destroy()
	disconnect_from_network()
	return ..()

/obj/machinery/power/entropic_converter/examine(mob/user)
	. = ..()
	var/turf/here = get_turf(src)
	if(here && powernet && !(machine_stat & (NOPOWER|BROKEN)) && anchored && !panel_open)
		var/obj/machinery/power/entropic_converter/dominant = get_dominant_entropic_converter_on_z(here.z)
		if(dominant && dominant != src)
			. += span_warning("Another entropic converter on this z-level is already feeding the grid; only one can operate per level.")

/obj/machinery/power/entropic_converter/proc/is_dominant_entropic_converter_on_z()
	var/turf/here = get_turf(src)
	if(!here)
		return FALSE
	return get_dominant_entropic_converter_on_z(here.z) == src

/obj/machinery/power/entropic_converter/process()
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if(!is_dominant_entropic_converter_on_z())
		return

	add_avail(power_to_energy(power_output))
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

/// Among eligible entropic converters on this z, only the one with the lowest ref() may supply the grid (stable for the round).
/proc/get_dominant_entropic_converter_on_z(z_level)
	var/obj/machinery/power/entropic_converter/best
	var/best_ref
	for(var/obj/machinery/power/entropic_converter/candidate as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/power/entropic_converter))
		var/turf/there = get_turf(candidate)
		if(!there || there.z != z_level)
			continue
		if(candidate.machine_stat & (NOPOWER|BROKEN))
			continue
		if(!candidate.anchored || candidate.panel_open)
			continue
		if(!candidate.powernet)
			continue
		var/candidate_ref = ref(candidate)
		if(!best || candidate_ref < best_ref)
			best = candidate
			best_ref = candidate_ref
	return best
