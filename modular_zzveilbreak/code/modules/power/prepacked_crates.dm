/obj/structure/closet/crate/engineering/antimatter
	name = "antimatter engine crate"
	desc = "A crate containing everything required to assemble a functional Antimatter Engine."
	icon_state = "engi_e_crate"
	base_icon_state = "engi_e_crate"

/obj/structure/closet/crate/engineering/antimatter/PopulateContents()
	. = ..()
	new /obj/machinery/power/am_control_unit(src)
	new /obj/item/am_containment(src)
	new /obj/item/am_containment(src)
	for(var/i in 1 to 9)
		new /obj/item/am_shielding_container(src)

/obj/structure/closet/crate/engineering/particle_accelerator
	name = "particle accelerator crate"
	desc = "A crate containing all 7 components required to construct a Particle Accelerator."
	icon_state = "engi_e_crate"
	base_icon_state = "engi_e_crate"

/obj/structure/closet/crate/engineering/particle_accelerator/PopulateContents()
	. = ..()
	new /obj/structure/particle_accelerator/fuel_chamber(src)
	new /obj/machinery/particle_accelerator/control_box(src)
	new /obj/structure/particle_accelerator/particle_emitter/center(src)
	new /obj/structure/particle_accelerator/particle_emitter/left(src)
	new /obj/structure/particle_accelerator/particle_emitter/right(src)
	new /obj/structure/particle_accelerator/power_box(src)
	new /obj/structure/particle_accelerator/end_cap(src)
