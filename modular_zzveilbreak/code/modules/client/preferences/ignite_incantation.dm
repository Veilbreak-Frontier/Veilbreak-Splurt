/datum/preference/text/ignite_incantation
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "ignite_incantation"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/text/ignite_incantation/create_default_value()
	return "Burn!"

/datum/preference/text/ignite_incantation/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return