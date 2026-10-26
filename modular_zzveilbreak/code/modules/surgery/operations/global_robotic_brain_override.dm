/datum/surgery_operation/New()
	. = ..()
	if(required_biotype & MOB_ROBOTIC)
		if(target_type == /obj/item/organ/brain || findtext("[type]", "brainwash") || type == /datum/surgery_operation/basic/revival/mechanic)
			target_zone = BODY_ZONE_CHEST
