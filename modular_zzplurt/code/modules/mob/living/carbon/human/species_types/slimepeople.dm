/**
 * SPLURT Edit: Override slimepeople to use preset-enabled Alter Form
 * 
 * Overrides the zubbers slimepeople species to grant the preset-enabled
 * /datum/action/innate/alter_form/preset instead of the base alter_form.
 * 
 * The base /datum/species/jelly (main codebase) grants the base alter_form
 * in its on_species_gain. We override roundstartslime's on_species_gain to:
 * 1. Remove the base alter_form granted by the parent species
 * 2. Grant the preset-enabled alter_form/preset instead
 */

/datum/species/jelly/roundstartslime/on_species_gain(mob/living/carbon/new_jellyperson, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	var/mob/living/carbon/human/H = new_jellyperson
	if(!istype(H))
		return

	// Remove the base alter_form granted by /datum/species/jelly (main codebase)
	var/datum/action/innate/alter_form/base_alter_form = locate() in H.actions
	if(base_alter_form)
		base_alter_form.Remove(H)

	// Grant preset-enabled alter_form
	var/datum/action/innate/alter_form/preset/alter_form_action = new
	alter_form_action.Grant(H)

/datum/species/jelly/roundstartslime/on_species_loss(mob/living/carbon/former_jellyperson, datum/species/new_species, pref_load)
	var/mob/living/carbon/human/H = former_jellyperson
	if(istype(H))
		// Remove preset-enabled alter_form
		var/datum/action/innate/alter_form/preset/alter_form_action = locate() in H.actions
		if(alter_form_action)
			alter_form_action.Remove(H)
	. = ..()
