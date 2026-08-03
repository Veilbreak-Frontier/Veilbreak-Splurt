/datum/wires/particle_accelerator/control_box
	holder_type = /obj/machinery/particle_accelerator/control_box
	proper_name = "Particle Accelerator"

/datum/wires/particle_accelerator/control_box/New(atom/holder)
	wires = list(
		WIRE_POWER, WIRE_STRENGTH, WIRE_LIMIT,
		WIRE_INTERFACE
	)
	add_duds(2)
	..()

/datum/wires/particle_accelerator/control_box/interactable(mob/user)
	var/obj/machinery/particle_accelerator/control_box/C = holder
	if(C.construction_state == 2)
		return TRUE
	return FALSE

/datum/wires/particle_accelerator/control_box/on_pulse(wire, user)
	var/obj/machinery/particle_accelerator/control_box/C = holder
	switch(wire)
		if(WIRE_POWER)
			C.toggle_power()
		if(WIRE_STRENGTH)
			C.add_strength()
		if(WIRE_INTERFACE)
			C.interface_control = !C.interface_control
		if(WIRE_LIMIT)
			C.visible_message(span_notice("[C] makes a large whirring noise."))
	..()

/datum/wires/particle_accelerator/control_box/on_cut(wire, mend, source)
	var/obj/machinery/particle_accelerator/control_box/C = holder
	switch(wire)
		if(WIRE_POWER)
			if(C.active == !mend)
				C.toggle_power()
		if(WIRE_STRENGTH)
			for(var/i in 1 to 2)
				C.remove_strength()
		if(WIRE_INTERFACE)
			if(!mend)
				C.interface_control = FALSE
		if(WIRE_LIMIT)
			C.strength_upper_limit = (mend ? 2 : 3)
			if(C.strength_upper_limit < C.strength)
				C.remove_strength()
	..()

/datum/wires/particle_accelerator/control_box/emp_pulse()
	return
