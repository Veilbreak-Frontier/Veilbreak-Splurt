/mob/Login()
    if(!ishuman(src) || !client?.prefs)
        return ..()
    var/mob/living/carbon/human/H = src
    var/datum/preferences/prefs = client.prefs

    // Check the correct variables
    var/has_tattoos = length(prefs.H_custom_tattoos_loaded) > 0

    if(has_tattoos)
        prefs.apply_custom_tattoos_to_mob(H)

    return ..()
