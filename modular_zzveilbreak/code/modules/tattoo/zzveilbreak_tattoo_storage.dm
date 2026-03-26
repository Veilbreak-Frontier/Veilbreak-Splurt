/datum/preferences/proc/save_custom_tattoo_data(list/save_data)
	var/mob/living/carbon/human/H
	if(parent?.mob && ishuman(parent.mob))
		H = parent.mob

	var/list/tattoo_data = list()

	if(H && !QDELETED(H))
		for(var/datum/custom_tattoo/T as anything in H.custom_body_tattoos)
			if(!istype(T) || QDELETED(T))
				continue

			var/list/T_data = list(
				"artist" = T.artist,
				"design" = T.design,
				"body_part" = T.body_part,
				"color" = T.color,
				"date_applied" = T.date_applied,
				"layer" = T.layer,
				"is_signature" = T.is_signature,
				"font" = T.font,
				"flair" = T.flair
			)
			tattoo_data += list(T_data)

	if(!length(tattoo_data))
		if(features && islist(features["custom_tattoos"]) && length(features["custom_tattoos"]))
			if(save_data)
				save_data["custom_tattoos"] = features["custom_tattoos"]
		return

	if(save_data)
		save_data["custom_tattoos"] = tattoo_data

	if(!features)
		features = list()
	features["custom_tattoos"] = tattoo_data
	features -= "custom_tattoos_loaded"

/datum/preferences/proc/load_custom_tattoo_data()
	if(!features)
		features = list()

	var/list/tattoo_data = features["custom_tattoos"]
	if(!islist(tattoo_data))
		return

	var/list/loaded_tattoos = list()
	for(var/i in 1 to length(tattoo_data))
		var/list/tattoo_info = tattoo_data[i]
		if(!islist(tattoo_info))
			continue

		var/final_artist = tattoo_info["artist"]
		var/final_design = tattoo_info["design"]
		var/body_part = tattoo_info["body_part"]
		var/final_color = tattoo_info["color"]
		var/final_layer = tattoo_info["layer"]
		var/final_is_signature = tattoo_info["is_signature"]
		var/final_font = tattoo_info["font"]
		var/final_flair = tattoo_info["flair"]
		var/date_applied = tattoo_info["date_applied"]

		var/datum/custom_tattoo/T = new(final_artist, final_design, body_part, final_color, final_layer, final_is_signature, final_font, final_flair)
		if(date_applied)
			T.date_applied = sanitize_text(date_applied)

		loaded_tattoos += T

	features["custom_tattoos_loaded"] = loaded_tattoos

/datum/preferences/proc/apply_custom_tattoos_to_mob(mob/living/carbon/human/H)
	if(!istype(H))
		return

	H.custom_body_tattoos.Cut()

	var/list/saved_tattoos = features["custom_tattoos_loaded"]
	if(!islist(saved_tattoos) || !length(saved_tattoos))
		load_custom_tattoo_data()
		saved_tattoos = features["custom_tattoos_loaded"]

	if(!islist(saved_tattoos))
		return

	for(var/datum/custom_tattoo/T as anything in saved_tattoos)
		if(istype(T) && !QDELETED(T))
			if(!is_custom_tattoo_bodypart_existing(H, T.body_part))
				continue

			var/datum/custom_tattoo/new_tattoo = new(T.artist, T.design, T.body_part, T.color, T.layer, T.is_signature, T.font, T.flair)
			new_tattoo.date_applied = T.date_applied
			H.add_custom_tattoo(new_tattoo)
	H.regenerate_icons()
