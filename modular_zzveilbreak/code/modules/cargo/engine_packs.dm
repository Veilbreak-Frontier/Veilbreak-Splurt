/datum/supply_pack/engineering/particle_accelerator
	name = "Particle Accelerator Crate"
	desc = "A supermassive black hole or hyper-powered teslaball are the perfect way to spice up any party! Contains all 7 components required to build a Particle Accelerator."
	cost = CARGO_CRATE_VALUE * 7.5
	access_view = ACCESS_ENGINE_EQUIP
	contains = list(
		/obj/structure/particle_accelerator/fuel_chamber,
		/obj/machinery/particle_accelerator/control_box,
		/obj/structure/particle_accelerator/particle_emitter/center,
		/obj/structure/particle_accelerator/particle_emitter/left,
		/obj/structure/particle_accelerator/particle_emitter/right,
		/obj/structure/particle_accelerator/power_box,
		/obj/structure/particle_accelerator/end_cap,
	)
	crate_name = "particle accelerator crate"

/datum/supply_pack/engineering/rad_collector
	name = "Radiation Collector Crate"
	desc = "Contains three radiation collectors. Useful for collecting energy off nearby Supermatter Crystals, Singularities or Teslas!"
	cost = CARGO_CRATE_VALUE * 5.5
	access_view = ACCESS_ENGINE_EQUIP
	contains = list(/obj/machinery/power/rad_collector = 3)
	crate_name = "collector crate"

/datum/supply_pack/engineering/singularity_gen
	name = "Singularity Generator Crate"
	desc = "The key to unlocking the power of a Gravitational Singularity. Particle Accelerator not included."
	cost = CARGO_CRATE_VALUE * 12
	access_view = ACCESS_ENGINE_EQUIP
	contains = list(/obj/machinery/the_singularitygen)
	crate_name = "singularity generator crate"

/datum/supply_pack/engineering/tesla_gen
	name = "Tesla Generator Crate"
	desc = "The key to unlocking the power of the Tesla energy ball. Particle Accelerator not included."
	cost = CARGO_CRATE_VALUE * 14
	access_view = ACCESS_ENGINE_EQUIP
	contains = list(/obj/machinery/the_singularitygen/tesla)
	crate_name = "tesla generator crate"
