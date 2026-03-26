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

/datum/preferences/proc/load_custom_tattoo_data()
	if(!features)
		features = list()

	var/list/tattoo_data = features["custom_tattoos"]
	if(!islist(tattoo_data))
		return

	var/list/loaded_tattoos = list()
	var/list/legacy_flair_map = list(
		"flair_1" = "pink",
		"flair_2" = "userlove",
		"flair_3" = "brown",
		"flair_4" = "cyan",
		"flair_5" = "orange",
		"flair_6" = "yellow",
		"flair_7" = "subtle",
		"flair_8" = "velvet",
		"flair_9" = "velvet_notice",
		"flair_10" = "glossy"
	)

	for(var/list/tattoo_info in tattoo_data)
		if(!islist(tattoo_info))
			continue

		var/body_part = tattoo_info["body_part"]
		if(!body_part || !is_custom_tattoo_bodypart_valid(body_part))
			continue

		var/artist = tattoo_info["artist"]
		var/design = tattoo_info["design"]
		var/color = tattoo_info["color"]
		var/layer = tattoo_info["layer"]
		var/date_applied = tattoo_info["date_applied"]
		var/is_signature = tattoo_info["is_signature"]
		var/font = tattoo_info["font"]
		var/flair = tattoo_info["flair"]

		var/final_artist = artist ? sanitize_text(artist) : "Unknown Artist"
		var/final_design = design ? sanitize_text(design) : "An intricate design"
		var/final_color = sanitize_hexcolor(color, default = "#000000")
		var/final_layer = sanitize_integer(layer, CUSTOM_TATTOO_LAYER_UNDER, CUSTOM_TATTOO_LAYER_OVER, CUSTOM_TATTOO_LAYER_NORMAL)
		var/final_is_signature = is_signature ? TRUE : FALSE
		var/final_font = (font && (font in GLOB.custom_tattoo_fonts)) ? font : PEN_FONT

		var/final_flair = null
		if(flair)
			if(flair in GLOB.custom_tattoo_flairs)
				final_flair = flair
			else if(flair in legacy_flair_map)
				final_flair = legacy_flair_map[flair]

		var/datum/custom_tattoo/T = new(final_artist, final_design, body_part, final_color, final_layer, final_is_signature, final_font, final_flair)
		if(date_applied)
			T.date_applied = sanitize_text(date_applied)

		loaded_tattoos += T

	features["custom_tattoos_loaded"] = loaded_tattoos

/datum/preferences/proc/apply_custom_tattoos_to_mob(mob/living/carbon/human/H)
	if(!istype(H))
		return

	H.custom_body_tattoos.Cut()

	// Use the loaded tattoo objects if available, otherwise load from data
	var/list/saved_tattoos = features["custom_tattoos_loaded"]
	if(!islist(saved_tattoos) || !length(saved_tattoos))
		load_custom_tattoo_data()
		saved_tattoos = features["custom_tattoos_loaded"]

	if(!islist(saved_tattoos))
		return

	var/pruned = FALSE
	for(var/datum/custom_tattoo/T as anything in saved_tattoos)
		if(istype(T) && !QDELETED(T))
			// Skip tattoos that reference body parts that no longer exist on this mob
			if(!is_custom_tattoo_bodypart_existing(H, T.body_part))
				pruned = TRUE
				continue

			// Create a fresh copy to avoid reference issues
			var/datum/custom_tattoo/new_tattoo = new(T.artist, T.design, T.body_part, T.color, T.layer, T.is_signature, T.font, T.flair)
			if(T.date_applied)
				new_tattoo.date_applied = T.date_applied
			H.add_custom_tattoo(new_tattoo)

	// If we pruned any saved tattoos (they referenced missing body parts), update stored prefs
	if(pruned && parent)
		save_custom_tattoo_data()

	H.regenerate_icons()
