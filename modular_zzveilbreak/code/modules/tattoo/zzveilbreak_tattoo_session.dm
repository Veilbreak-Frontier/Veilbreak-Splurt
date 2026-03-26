/mob/Login()
	. = ..()

	if(!ishuman(src) || !client?.prefs)
		return .

	var/mob/living/carbon/human/H = src
	var/datum/preferences/prefs = client.prefs

	if(!prefs.features)
		prefs.features = list()

	if(!islist(prefs.features["custom_tattoos_loaded"]) || !length(prefs.features["custom_tattoos_loaded"]))
		prefs.load_custom_tattoo_data()

	if(LAZYLEN(prefs.features["custom_tattoos_loaded"]))
		prefs.apply_custom_tattoos_to_mob(H)

	return .
