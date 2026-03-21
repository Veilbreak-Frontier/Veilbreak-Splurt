/**
 * SPLURT Edit: NIF Polymorph with Presets
 * 
 * Extends the skyramodular /datum/action/innate/alter_form/nif with preset support.
 * This is used by the NIFSoft Polymorph program.
 */

/datum/action/innate/alter_form/nif/preset
	name = "Polymorph"
	slime_restricted = FALSE
	background_icon = 'modular_skyrat/master_files/icons/mob/actions/action_backgrounds.dmi'
	background_icon_state = "android"
	button_icon = 'modular_skyrat/master_files/icons/mob/actions/actions_nif.dmi'
	button_icon_state = "slime"
	shapeshift_text = "closes their eyes to focus, their body subtly shifting and contorting."

/datum/action/innate/alter_form/nif/preset/change_form(mob/living/carbon/human/alterer)
	var/selected_alteration = show_radial_menu(
		alterer,
		alterer,
		list(
			"Body Colours" = image(icon = 'modular_skyrat/master_files/icons/mob/actions/actions_slime.dmi', icon_state = "slime_rainbow"),
			"DNA" = image(icon = 'modular_skyrat/master_files/icons/mob/actions/actions_slime.dmi', icon_state = "dna"),
			"Hair" = image(icon = 'modular_skyrat/master_files/icons/mob/actions/actions_slime.dmi', icon_state = "scissors"),
			"Markings" = image(icon = 'modular_skyrat/master_files/icons/mob/actions/actions_slime.dmi', icon_state = "rainbow_spraycan"),
			"Presets" = image(icon = 'modular_skyrat/master_files/icons/mob/actions/actions_slime.dmi', icon_state = "dna"),
		),
		tooltips = TRUE,
	)
	if(!selected_alteration)
		return
	switch(selected_alteration)
		if("Body Colours")
			alter_colours(alterer)
		if("DNA")
			alter_dna(alterer)
		if("Hair")
			alter_hair(alterer)
		if("Markings")
			alter_markings(alterer)
		if("Presets")
			alter_presets(alterer)

// NIF preset inherits alter_presets and preset management from /datum/action/innate/alter_form/preset
// since /datum/action/innate/alter_form/nif/preset extends /datum/action/innate/alter_form/nif
// which extends /datum/action/innate/alter_form, and our preset procs are defined on
// /datum/action/innate/alter_form/preset which is a subtype of /datum/action/innate/alter_form
// The alter_presets proc and its children (load_preset, save_preset, delete_preset)
// are accessible because they're defined on /datum/action/innate/alter_form/preset
// which shares the same parent chain with /datum/action/innate/alter_form/nif/preset
