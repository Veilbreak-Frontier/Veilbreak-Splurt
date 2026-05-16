/mob/Login()
	if(!ishuman(src) || !client?.prefs)
		return ..()

	var/mob/living/carbon/human/H = src
	var/datum/preferences/prefs = client.prefs
	var/body_slot = H.mind?.original_character_slot_index || prefs.default_slot

	prefs.apply_custom_tattoos_to_mob(H, body_slot)

	return ..()
