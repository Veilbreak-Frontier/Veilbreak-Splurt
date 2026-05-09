/mob/Login()
	if(!ishuman(src) || !client?.prefs)
		return ..()

	var/mob/living/carbon/human/H = src
	var/datum/preferences/prefs = client.prefs

	if(!prefs.features)
		prefs.features = list()

	var/has_data = length(prefs.features["custom_tattoos"])
	var/has_loaded = length(prefs.features["custom_tattoos_loaded"])

	if(has_data || has_loaded)
		prefs.apply_custom_tattoos_to_mob(H)

	. = ..()
