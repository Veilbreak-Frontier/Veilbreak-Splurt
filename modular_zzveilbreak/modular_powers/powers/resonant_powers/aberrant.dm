/datum/power/cuprous_heart
	name = "Cuprous Heart"
	desc = "Your heart and blood are Living Copper. Your wounds and injuries naturally seal themselves, and you're resistant \
	to Resonant effects, but your blood does not replenish naturally and is hard to synthesize."
	cost = 5
	root_power = /datum/power/cuprous_heart
	power_type = TRAIT_PATH_SUBTYPE_ABERRANT
	power_traits = list(TRAIT_POWER_CUPROUS_HEART)

/obj/item/organ/heart/resonant/copper
	name = "cuprous heart"
	desc = "A fist-sized knot of living copper that beats with patient, metallic purpose. Whatever runs through the owner's veins is no longer quite blood."
	/// Blood type before this organ replaced circulation; restored if the heart is removed.
	var/datum/blood_type/stored_circulation_type

/datum/power/cuprous_heart/add(mob/living/carbon/human/target)
	var/obj/item/organ/heart/old_heart = target.get_organ_slot(ORGAN_SLOT_HEART)
	if(old_heart && IS_ORGANIC_ORGAN(old_heart))
		qdel(old_heart)
	var/obj/item/organ/heart/resonant/copper/copper_heart = new
	copper_heart.Insert(target, special = TRUE)

/datum/power/muscly
	name = "Condensed Musculature"
	desc = "You're far more athletic than the average person."
	cost = 5
	root_power = /datum/power/muscly
	power_type = TRAIT_PATH_SUBTYPE_ABERRANT
	power_traits = list(TRAIT_POWER_MUSCLY)

/datum/power/bestial
	name = "Latent Bestial Traits"
	desc = "Your hearing is sharper than normal, but loud noises hurt your ears much more."
	root_power = /datum/power/bestial
	power_type = TRAIT_PATH_SUBTYPE_ABERRANT
	cost = 5
	power_traits = list(TRAIT_POWER_BESTIAL, TRAIT_GOOD_HEARING)
