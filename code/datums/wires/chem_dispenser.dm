/datum/wires/chem_dispenser
	holder_type = /obj/machinery/chem_dispenser
	proper_name = "Reagent Dispenser"

/datum/wires/chem_dispenser/New(atom/holder)
	wires = list(
		WIRE_SAFETIES, WIRE_SHOCK,
		WIRE_ZAP,
	)
	add_duds(3)
	..()

/datum/wires/chem_dispenser/interactable(mob/user)
	if(!..())
		return FALSE
	var/obj/machinery/chem_dispenser/dispenser = holder
	if(dispenser.panel_open)
		return TRUE

/datum/wires/chem_dispenser/get_status()
	var/obj/machinery/chem_dispenser/dispenser = holder
	var/list/status = list()
	status += "The safety light is [dispenser.hacked ? "off" : "on"]."
	return status

/datum/wires/chem_dispenser/on_pulse(wire, mob/living/user)
	var/obj/machinery/chem_dispenser/dispenser = holder
	switch(wire)
		if(WIRE_SAFETIES)
			dispenser.adjust_hacked(!dispenser.hacked)
			addtimer(CALLBACK(dispenser, TYPE_PROC_REF(/obj/machinery/chem_dispenser, reset_hack), wire), 6 SECONDS)
		if(WIRE_SHOCK)
			dispenser.shock(user, 100)

/datum/wires/chem_dispenser/on_cut(wire, mend, source)
	var/obj/machinery/chem_dispenser/dispenser = holder
	switch(wire)
		if(WIRE_SAFETIES)
			dispenser.adjust_hacked(!mend)
		if(WIRE_ZAP)
			if(!mend && source)
				dispenser.shock(source, 100)
