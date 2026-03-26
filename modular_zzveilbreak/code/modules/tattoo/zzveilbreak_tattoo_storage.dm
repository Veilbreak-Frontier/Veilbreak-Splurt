/datum/preferences/proc/save_custom_tattoo_data(list/save_data)
	var/mob/living/carbon/human/H
	if(parent?.mob && ishuman(parent.mob))
		H = parent.mob

	var/list/tattoo_serialization = list()

	if(H && !QDELETED(H))
		for(var/datum/custom_tattoo/T as anything in H.custom_body_tattoos)
			if(!istype(T) || QDELETED(T))
				continue

			var/list/T_dict = list(
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
			tattoo_serialization += list(T_dict)

	if(!length(tattoo_serialization))
		if(features && islist(features["custom_tattoos"]) && length(features["custom_tattoos"]))
			if(save_data)
				save_data["custom_tattoos"] = features["custom_tattoos"]
		return

	if(save_data)
		save_data["custom_tattoos"] = tattoo_serialization

	if(!features)
		features = list()

	features["custom_tattoos"] = tattoo_serialization
	features -= "custom_tattoos_loaded"

/datum/preferences/proc/load_custom_tattoo_data()
	if(!features)
		features = list()

	var/list/tattoo_serialization = features["custom_tattoos"]
	if(!islist(tattoo_serialization))
		return

	var/list/reconstructed_objects = list()
	for(var/i in 1 to length(tattoo_serialization))
		var/list/data = tattoo_serialization[i]
		if(!islist(data))
			continue

		var/datum/custom_tattoo/T = new(
			data["artist"],
			data["design"],
			data["body_part"],
			data["color"],
			data["layer"],
			data["is_signature"],
			data["font"],
			data["flair"]
		)
		if(data["date_applied"])
			T.date_applied = data["date_applied"]

		reconstructed_objects += T

	features["custom_tattoos_loaded"] = reconstructed_objects

/datum/preferences/proc/apply_custom_tattoos_to_mob(mob/living/carbon/human/H)
	if(!istype(H))
		return

	H.custom_body_tattoos.Cut()

	if(!islist(features["custom_tattoos_loaded"]) || !length(features["custom_tattoos_loaded"]))
		load_custom_tattoo_data()

	var/list/stored = features["custom_tattoos_loaded"]
	if(!islist(stored))
		return

	for(var/datum/custom_tattoo/T as anything in stored)
		if(istype(T) && !QDELETED(T))
			if(!is_custom_tattoo_bodypart_existing(H, T.body_part))
				continue

			var/datum/custom_tattoo/copy = new(T.artist, T.design, T.body_part, T.color, T.layer, T.is_signature, T.font, T.flair)
			copy.date_applied = T.date_applied
			H.add_custom_tattoo(copy)
