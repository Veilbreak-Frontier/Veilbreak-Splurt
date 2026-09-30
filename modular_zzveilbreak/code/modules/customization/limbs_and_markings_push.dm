/*
This file makes mid-round marking edits take effect on the live player mob instead of only on the character-setup preview dummy.
It wraps every mutating proc in the limbs_and_markings preference middleware and pushes the updated data plus a bodypart re-render after each successful change.
*/

/datum/preference_middleware/limbs_and_markings/proc/push_markings_to_live_mob(mob/user)
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		return
	H.dna.species.body_markings = LAZYCOPY(preferences.body_markings)
	H.update_body_parts(update_limb_data = TRUE)

/datum/preference_middleware/limbs_and_markings/get_ui_data(mob/user)
	. = ..()
	if(!.[ "limbs_data" ])
		return

	var/datum/species/species_type = preferences.read_preference(/datum/preference/choiced/species)
	var/allow_mismatched_parts = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)

	for(var/list/limb_entry in .[ "limbs_data" ])
		var/limb_slot = limb_entry["slot"]
		var/list/choices = GLOB.body_markings_per_limb[limb_slot] ? GLOB.body_markings_per_limb[limb_slot].Copy() : list()

		if(!allow_mismatched_parts && choices.len)
			for(var/name in choices)
				var/datum/body_marking/marking = GLOB.body_markings[name]
				if(!marking)
					choices -= name
					continue

				var/list/rec_species = initial(marking.recommended_species)
				if(rec_species && !(initial(species_type.id) in rec_species))
					choices -= name

		if(limb_entry["markings"])
			limb_entry["markings"]["marking_choices"] = choices

/datum/preference_middleware/limbs_and_markings/add_marking(list/params, mob/user)
	. = ..()
	if(.)
		push_markings_to_live_mob(user)

/datum/preference_middleware/limbs_and_markings/change_marking(list/params, mob/user)
	. = ..()
	if(.)
		push_markings_to_live_mob(user)

/datum/preference_middleware/limbs_and_markings/color_marking(list/params, mob/user)
	. = ..()
	if(.)
		push_markings_to_live_mob(user)

/datum/preference_middleware/limbs_and_markings/change_emissive_marking(list/params, mob/user)
	. = ..()
	if(.)
		push_markings_to_live_mob(user)

/datum/preference_middleware/limbs_and_markings/remove_marking(list/params, mob/user)
	. = ..()
	if(.)
		push_markings_to_live_mob(user)

/datum/preference_middleware/limbs_and_markings/set_preset(list/params, mob/user)
	. = ..()
	if(.)
		push_markings_to_live_mob(user)
