/mob/living/carbon/proc/has_functional_tail()

	if(iscyborg(src))
		return TRUE

	if(get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL))
		return TRUE

	if(get_organ_slot(ORGAN_SLOT_TAIL))
		return TRUE

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(H.get_taur_mode() == STYLE_TAUR_SNAKE)
			return TRUE

	return FALSE
