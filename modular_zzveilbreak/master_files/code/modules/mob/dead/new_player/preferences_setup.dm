/datum/preferences/render_new_preview_appearance(mob/living/carbon/human/dummy/mannequin)
	var/mutable_appearance/final_appearance = new(..())

	var/raw_height = read_preference(/datum/preference/choiced/height_scaling)
	var/chosen_height = text2num(raw_height)

	if(isnull(chosen_height))
		chosen_height = HUMAN_HEIGHT_MEDIUM

	mannequin.mob_height = chosen_height
	if("base_mob_height" in mannequin.vars)
		mannequin.vars["base_mob_height"] = chosen_height

	if(chosen_height != HUMAN_HEIGHT_MEDIUM)
		mannequin.apply_height(final_appearance, ENTIRE_BODY, TRUE)

	return final_appearance
