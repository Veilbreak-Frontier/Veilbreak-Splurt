/datum/job/proc/has_banned_species(datum/preferences/preferences)
	if(preferences)
		var/datum/species/selected_species = preferences.read_preference(/datum/preference/choiced/species)

		if(selected_species == /datum/species/protean)
			return FALSE

	return ..()
