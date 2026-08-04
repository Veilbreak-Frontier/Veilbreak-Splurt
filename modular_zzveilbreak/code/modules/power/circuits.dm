/obj/item/circuitboard/machine/am_control_unit
	name = "Antimatter Control Unit"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/power/am_control_unit
	req_components = list(
		/datum/stock_part/capacitor = 2,
		/datum/stock_part/micro_laser = 2,
		/obj/item/stack/cable_coil = 5,
	)

/obj/item/circuitboard/machine/particle_control
	name = "Particle Accelerator Control Console"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/particle_accelerator/control_box
	req_components = list(
		/datum/stock_part/micro_laser = 1,
		/datum/stock_part/matter_bin = 1,
		/obj/item/stack/cable_coil = 1,
	)

/obj/item/circuitboard/machine/rad_collector
	name = "Radiation Collector"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/power/rad_collector
	req_components = list(
		/datum/stock_part/capacitor = 2,
		/obj/item/stack/cable_coil = 5,
	)
