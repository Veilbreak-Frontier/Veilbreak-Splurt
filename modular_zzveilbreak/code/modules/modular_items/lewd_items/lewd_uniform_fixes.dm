/obj/item/clothing/under/costume/lewdmaid
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/item/clothing/under/misc/latex_catsuit/equipped(mob/living/affected_mob, slot)
	. = ..()

	if(!ishuman(affected_mob))
		return

	var/mob/living/carbon/human/affected_human = affected_mob
	if(src != affected_human.w_uniform)
		return

	// Gender-specific state (matches upstream).
	icon_state = (affected_mob.gender == FEMALE) ? "latex_catsuit_female" : "latex_catsuit_male"

	// Taur fix: pick the correct taur DMI before rebuilding the worn icon.
	var/taur_mode = affected_human.get_taur_mode()
	if(taur_mode & STYLE_TAUR_ALL)
		if(taur_mode & STYLE_TAUR_SNAKE)
			worn_icon = worn_icon_taur_snake
		else if(taur_mode & STYLE_TAUR_PAW)
			worn_icon = worn_icon_taur_paw
		else if(taur_mode & STYLE_TAUR_HOOF)
			worn_icon = worn_icon_taur_hoof

	affected_mob.update_worn_undersuit()

	// Breast overlays (preserved from upstream).
	breasts_overlay = mutable_appearance(
		'modular_skyrat/modules/modular_items/lewd_items/icons/mob/lewd_clothing/lewd_uniform/lewd_uniform.dmi',
		"none")
	breasts_overlay.pixel_w = (taur_mode & STYLE_TAUR_ALL) ? 16 : 0

	var/obj/item/organ/genital/breasts/affected_breasts = affected_human.get_organ_slot(ORGAN_SLOT_BREASTS)
	if(affected_breasts && affected_breasts.genital_size >= 6)
		switch(affected_breasts.genital_type)
			if("pair")
				breasts_overlay.icon_state = "breasts_double"
				breasts_icon_overlay.icon_state = "iconbreasts_double"
				add_overlay(breasts_icon_overlay)
			if("quad")
				breasts_overlay.icon_state = "breasts_quad"
				breasts_icon_overlay.icon_state = "iconbreasts_quad"
				add_overlay(breasts_icon_overlay)
			if("sextuple")
				breasts_overlay.icon_state = "breasts_sextuple"
				breasts_icon_overlay.icon_state = "iconbreasts_sextuple"
				add_overlay(breasts_icon_overlay)

	update_overlays(UPDATE_OVERLAYS)
	affected_human.regenerate_icons()
