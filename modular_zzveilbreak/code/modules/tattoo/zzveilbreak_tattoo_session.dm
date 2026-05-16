/mob/Login()
	if(!ishuman(src) || !client?.prefs)
		return ..()

	var/mob/living/carbon/human/H = src
	var/datum/preferences/prefs = client.prefs
	var/body_slot = H.mind?.original_character_slot_index || prefs.default_slot

	if(length(prefs.get_custom_tattoos_serialized_for_slot(body_slot)))
		prefs.apply_custom_tattoos_to_mob(H, body_slot)

	return ..()

/datum/preferences/proc/render_new_preview_appearance(mob/living/carbon/human/dummy/mannequin)
	. = ..()
	if(!istype(mannequin))
		return
	apply_custom_tattoos_to_mob(mannequin, default_slot)
	return mannequin.appearance
