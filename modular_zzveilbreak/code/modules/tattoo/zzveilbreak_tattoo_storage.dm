/datum/preferences
	var/list/H_custom_tattoos_loaded

/datum/preferences/proc/save_custom_tattoo_data(list/save_data, mob/living/carbon/human/explicit_mob)
	var/mob/living/carbon/human/H = explicit_mob
	if(!istype(H) && parent?.mob && ishuman(parent.mob))
		H = parent.mob

	var/list/target_list = save_data
	if(islist(save_data))
		var/slot_key = "character[default_slot]"
		if(islist(save_data[slot_key]))
			target_list = save_data[slot_key]

	if(!H || QDELETED(H))
		if(islist(target_list) && islist(H_custom_tattoos_loaded))
			var/list/fallback_serialization = list()
			for(var/datum/custom_tattoo/T as anything in H_custom_tattoos_loaded)
				if(!istype(T) || QDELETED(T))
					continue
				fallback_serialization += list(list(
					"artist" = T.artist,
					"design" = T.design,
					"body_part" = T.body_part,
					"color" = T.color,
					"date_applied" = T.date_applied,
					"layer" = T.layer,
					"is_signature" = T.is_signature,
					"font" = T.font,
					"flair" = T.flair
				))
			if(length(fallback_serialization))
				target_list["custom_tattoos"] = fallback_serialization
		return

	var/list/tattoo_serialization = list()
	for(var/datum/custom_tattoo/T as anything in H.custom_body_tattoos)
		if(!istype(T) || QDELETED(T))
			continue
		tattoo_serialization += list(list(
			"artist" = T.artist,
			"design" = T.design,
			"body_part" = T.body_part,
			"color" = T.color,
			"date_applied" = T.date_applied,
			"layer" = T.layer,
			"is_signature" = T.is_signature,
			"font" = T.font,
			"flair" = T.flair
		))

	if(islist(target_list))
		target_list["custom_tattoos"] = tattoo_serialization

/datum/preferences/proc/load_custom_tattoo_data(list/source_data)
	if(islist(H_custom_tattoos_loaded))
		for(var/datum/custom_tattoo/T in H_custom_tattoos_loaded)
			qdel(T)
	H_custom_tattoos_loaded = list()

	if(!source_data)
		return

	var/list/target_list = source_data
	if(islist(source_data))
		var/slot_key = "character[default_slot]"
		if(islist(source_data[slot_key]))
			target_list = source_data[slot_key]

	if(!islist(target_list) || !islist(target_list["custom_tattoos"]))
		return

	var/list/tattoo_serialization = target_list["custom_tattoos"]
	var/list/reconstructed_objects = list()

	for(var/i in 1 to length(tattoo_serialization))
		var/list/data = tattoo_serialization[i]
		if(!islist(data))
			continue

		var/b_part = data["body_part"]
		if(b_part == "butt" || b_part == "groin")
			b_part = "chest"

		var/datum/custom_tattoo/T = new(
			data["artist"],
			data["design"],
			b_part,
			data["color"],
			data["layer"],
			data["is_signature"],
			data["font"],
			data["flair"]
		)
		if(data["date_applied"])
			T.date_applied = data["date_applied"]

		reconstructed_objects += T

	H_custom_tattoos_loaded = reconstructed_objects

/datum/preferences/proc/apply_custom_tattoos_to_mob(mob/living/carbon/human/H, list/source_data)
	if(!istype(H))
		return

	H.custom_body_tattoos.Cut()

	load_custom_tattoo_data(source_data)

	if(islist(H_custom_tattoos_loaded) && length(H_custom_tattoos_loaded))
		for(var/datum/custom_tattoo/T in H_custom_tattoos_loaded)
			var/datum/custom_tattoo/cloned = new(
				T.artist,
				T.design,
				T.body_part,
				T.color,
				T.layer,
				T.is_signature,
				T.font,
				T.flair
			)
			cloned.date_applied = T.date_applied
			H.add_custom_tattoo(cloned)
