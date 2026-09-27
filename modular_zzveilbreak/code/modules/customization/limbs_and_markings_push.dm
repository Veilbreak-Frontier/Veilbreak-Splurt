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
