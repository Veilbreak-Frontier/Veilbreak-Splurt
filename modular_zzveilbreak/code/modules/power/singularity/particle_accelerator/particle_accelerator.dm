#ifndef PA_CONSTRUCTION_UNSECURED
#define PA_CONSTRUCTION_UNSECURED 0
#define PA_CONSTRUCTION_UNWIRED 1
#define PA_CONSTRUCTION_PANEL_OPEN 2
#define PA_CONSTRUCTION_COMPLETE 3
#endif

/obj/structure/particle_accelerator
	name = "Particle Accelerator"
	desc = "Part of a Particle Accelerator."
	icon = 'modular_zzveilbreak/icons/obj/machines/particle_accelerator.dmi'
	icon_state = "none"
	anchored = FALSE
	density = TRUE
	max_integrity = 500
	armor = list(MELEE = 30, BULLET = 20, LASER = 20, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 90, ACID = 80)
	var/obj/machinery/particle_accelerator/control_box/master = null
	var/construction_state = PA_CONSTRUCTION_UNSECURED
	var/reference = null
	var/powered = FALSE
	var/strength = null

/obj/structure/particle_accelerator/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_rotation)
	update_appearance()

/obj/structure/particle_accelerator/examine(mob/user)
	. = ..()
	switch(construction_state)
		if(PA_CONSTRUCTION_UNSECURED)
			. += "Looks like it's not attached to the flooring."
		if(PA_CONSTRUCTION_UNWIRED)
			. += "It is missing some cables."
		if(PA_CONSTRUCTION_PANEL_OPEN)
			. += "The panel is open."

/obj/structure/particle_accelerator/Destroy()
	construction_state = PA_CONSTRUCTION_UNSECURED
	if(master)
		master.connected_parts -= src
		master.assembled = FALSE
		master = null
	return ..()

/obj/structure/particle_accelerator/wrench_act(mob/living/user, obj/item/tool)
	var/did_something = FALSE
	if(construction_state == PA_CONSTRUCTION_UNSECURED && !isinspace())
		tool.play_tool_sound(src, 75)
		anchored = TRUE
		user.visible_message("[user.name] secures the [name] to the floor.", span_notice("You secure the external bolts."))
		construction_state = PA_CONSTRUCTION_UNWIRED
		did_something = TRUE
	else if(construction_state == PA_CONSTRUCTION_UNWIRED)
		tool.play_tool_sound(src, 75)
		anchored = FALSE
		user.visible_message("[user.name] detaches the [name] from the floor.", span_notice("You remove the external bolts."))
		construction_state = PA_CONSTRUCTION_UNSECURED
		did_something = TRUE

	if(did_something)
		update_state()
		update_appearance()
		return TRUE
	return ..()

/obj/structure/particle_accelerator/screwdriver_act(mob/living/user, obj/item/tool)
	var/did_something = FALSE
	if(construction_state == PA_CONSTRUCTION_PANEL_OPEN)
		user.visible_message("[user.name] closes the [name]'s access panel.", span_notice("You close the access panel."))
		construction_state = PA_CONSTRUCTION_COMPLETE
		did_something = TRUE
	else if(construction_state == PA_CONSTRUCTION_COMPLETE)
		user.visible_message("[user.name] opens the [name]'s access panel.", span_notice("You open the access panel."))
		construction_state = PA_CONSTRUCTION_PANEL_OPEN
		did_something = TRUE

	if(did_something)
		update_state()
		update_appearance()
		return TRUE
	return ..()

/obj/structure/particle_accelerator/wirecutter_act(mob/living/user, obj/item/tool)
	if(construction_state == PA_CONSTRUCTION_PANEL_OPEN)
		user.visible_message("[user.name] removes some wires from the [name].", span_notice("You remove some wires."))
		construction_state = PA_CONSTRUCTION_UNWIRED
		update_state()
		update_appearance()
		return TRUE
	return ..()

/obj/structure/particle_accelerator/attackby(obj/item/W, mob/user, params)
	var/did_something = FALSE

	if(construction_state == PA_CONSTRUCTION_UNWIRED && istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = W
		if(C.use(1))
			user.visible_message("[user.name] adds wires to the [name].", span_notice("You add some wires."))
			construction_state = PA_CONSTRUCTION_PANEL_OPEN
			did_something = TRUE

	if(did_something)
		update_state()
		update_appearance()
		return TRUE

	return ..()

/obj/structure/particle_accelerator/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/iron(loc, 5)
	qdel(src)

/obj/structure/particle_accelerator/Move()
	. = ..()
	if(master && master.active)
		master.toggle_power()
		investigate_log("was moved whilst active; it <font color='red'>powered down</font>.", INVESTIGATE_ENGINE)

/obj/structure/particle_accelerator/update_icon_state()
	if(!reference)
		return ..()
	switch(construction_state)
		if(PA_CONSTRUCTION_UNSECURED, PA_CONSTRUCTION_UNWIRED)
			icon_state = "[reference]"
		if(PA_CONSTRUCTION_PANEL_OPEN)
			icon_state = "[reference]w"
		if(PA_CONSTRUCTION_COMPLETE)
			if(powered)
				icon_state = "[reference]p[strength]"
			else
				icon_state = "[reference]c"
	return ..()

/obj/structure/particle_accelerator/proc/update_state()
	if(master)
		master.update_state()

/obj/structure/particle_accelerator/proc/connect_master(obj/O)
	if(O.dir == dir)
		master = O
		return TRUE
	return FALSE

/obj/structure/particle_accelerator/end_cap
	name = "Alpha Particle Generation Array"
	desc = "This is where Alpha particles are generated from REDACTED."
	icon_state = "end_cap"
	reference = "end_cap"

/obj/structure/particle_accelerator/power_box
	name = "Particle Focusing EM Lens"
	desc = "This uses electromagnetic waves to focus the Alpha particles."
	icon = 'modular_zzveilbreak/icons/obj/machines/particle_accelerator.dmi'
	icon_state = "power_box"
	reference = "power_box"

/obj/structure/particle_accelerator/fuel_chamber
	name = "EM Acceleration Chamber"
	desc = "This is where the Alpha particles are accelerated to <b><i>radical speeds</i></b>."
	icon = 'modular_zzveilbreak/icons/obj/machines/particle_accelerator.dmi'
	icon_state = "fuel_chamber"
	reference = "fuel_chamber"
