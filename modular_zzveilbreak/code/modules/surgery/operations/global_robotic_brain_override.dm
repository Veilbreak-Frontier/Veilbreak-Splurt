/datum/surgery_operation/New()
	. = ..()

	if(istype(src, /datum/surgery_operation/basic))
		var/datum/surgery_operation/basic/B = src
		if(B.required_biotype & MOB_ROBOTIC)
			if(B.type == /datum/surgery_operation/basic/revival/mechanic)
				B.target_zone = BODY_ZONE_CHEST

	else if(istype(src, /datum/surgery_operation/organ))
		var/datum/surgery_operation/organ/O = src
		if(O.target_type == /obj/item/organ/brain)
			if(findtext("[O.type]", "mechanic"))
				if("target_zone" in O.vars)
					O.vars["target_zone"] = BODY_ZONE_CHEST
