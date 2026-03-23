//This file is for nanite program designs that are unique to veilbreak

/datum/design/nanites/quantum
	name = "Quantum Replication"
	desc = "A nanite program that takes advantage of the void to replicate faster."
	id = "quantum_nanites"
	program_type = /datum/nanite_program/protocol/quantum
	category = list("Protocols_Nanites")


/datum/design/nanites/e_regen
	name = "Efficient Regeneration"
	desc = "A nanite program that provides slow but highly efficient healing."
	id = "e_regen_nanites"
	program_type = /datum/nanite_program/regenerative/e_regen
	category = list("Medical Nanites")

/datum/design/nanites/f_regen
	name = "Fast Regeneration"
	desc = "A nanite program that provides rapid healing at a high energy cost."
	id = "f_regen_nanites"
	program_type = /datum/nanite_program/regenerative/f_regen
	category = list("Medical Nanites")

