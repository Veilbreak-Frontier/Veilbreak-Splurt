/datum/preference/text/ignite_incantation
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "ignite_incantation"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE
	should_update_preview = FALSE
	maximum_value_length = 64

/datum/preference/text/ignite_incantation/create_default_value()
	return "Burn!"

/datum/preference/text/ignite_incantation/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return /datum/quirk/ignite::name in preferences.all_quirks

/datum/preference/text/ignite_incantation/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return
