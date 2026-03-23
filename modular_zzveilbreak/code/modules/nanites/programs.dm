/datum/nanite_program/protocol/quantum
	name = "Quantum Replication"
	desc = "Borrows replication power while inside the void. Slows down the production on outside of the void. Increases replication speed by 3.5 per cycle"
	use_rate = 0.1
	rogue_types = list(/datum/nanite_program/necrotic)
	protocol_class = NANITE_PROTOCOL_REPLICATION
	var/in_void = FALSE

/datum/nanite_program/protocol/quantum/check_conditions()
	var/turf/T = get_turf(host_mob)
	in_void = istype(T, /turf/open/floor/void_tile)
	return ..()

/datum/nanite_program/protocol/quantum/active_effect()
	. = ..()
	if(in_void)
		nanites.adjust_nanites(null, 3.6)

/datum/nanite_program/regenerative/e_regen
	name = "Efficient Regeneration"
	desc = "Programs the nanites to regen slowly but very efficiently compared to other regenerations."
	use_rate = 0.2
	always_active = FALSE
	healing_rate = 0.4
	rogue_types = list(/datum/nanite_program/necrotic)


/datum/nanite_program/regenerative/f_regen
	name = "Fast Regeneration"
	desc = "Programs the nanites to regenerate the host's wounds at a fast pace, but at the cost of efficiency."
	use_rate = 6
	healing_rate = 5
	rogue_types = list(/datum/nanite_program/necrotic)
	always_active = FALSE


