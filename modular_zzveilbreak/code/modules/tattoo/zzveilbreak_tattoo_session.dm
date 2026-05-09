/mob/Login()
	if(!ishuman(src) || !client?.prefs)
		return ..()

	var/mob/living/carbon/human/H = src
	var/datum/preferences/prefs = client.prefs

	if(!prefs.features)
		prefs.features = list()

	if(length(prefs.features["custom_tattoos"]))
		prefs.apply_custom_tattoos_to_mob(H)

	. = ..()
