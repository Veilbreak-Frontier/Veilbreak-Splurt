/datum/nifsoft/action_granter/shapeshifter
	// Keep this between shifts
	able_to_keep = TRUE

	// Disable use cost
	active_cost = 0
	activation_cost = 0

	// Allow on all NIF units
	compatible_nifs = list(/obj/item/organ/cyberimp/brain/nif)
	// SPLURT EDIT: Use preset-enabled alter_form/nif
	action_to_grant = /datum/action/innate/alter_form/nif/preset
