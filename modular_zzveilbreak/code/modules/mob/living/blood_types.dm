/// Metallo-organic blood driven by a Cuprous Heart: seals aggressively, does not renew like marrow-bound blood, and has no common chem "restoration" analogue.
/datum/blood_type/living_copper
	name = BLOOD_TYPE_LIVING_COPPER
	desc = "Living copper organized as a circulating lattice: it clots like intent, carries oxygen through impossible chemistry, and refuses the usual hemogenic shortcuts."
	dna_string = "Cuprous-Lattice DNA"
	reagent_type = /datum/reagent/copper
	color = BLOOD_COLOR_COPPER
	restoration_chem = null
	compatible_types = list(/datum/blood_type/living_copper)
