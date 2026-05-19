/datum/preferences
	var/list/H_custom_tattoos_loaded
	var/tattoo_version = 1

/datum/preferences/proc/save_custom_tattoo_data(list/save_data, mob/living/carbon/human/explicit_mob)
	var/mob/living/carbon/human/H = explicit_mob
	if(!istype(H) && parent?.mob && ishuman(parent.mob))
		H = parent.mob

	var/list/target_list = save_data
	if(islist(save_data))
		var/slot_key = "character[default_slot]"
		if(islist(save_data[slot_key]))
			target_list = save_data[slot_key]

	if(!islist(target_list))
		return

	if(!H || QDELETED(H))
		if(islist(H_custom_tattoos_loaded))
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
					"flair" = T.flair,
					"version" = tattoo_version
				))
			target_list["custom_tattoos"] = fallback_serialization
		return

	var/list/tattoo_serialization = list()
	var/list/all_tattoos = H.custom_body_tattoos
	if(islist(all_tattoos))
		for(var/datum/custom_tattoo/T as anything in all_tattoos)
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
				"flair" = T.flair,
				"version" = tattoo_version
			))

	target_list["custom_tattoos"] = tattoo_serialization

/datum/preferences/proc/load_custom_tattoo_data(list/source_data)
	if(islist(H_custom_tattoos_loaded))
		for(var/datum/custom_tattoo/T in H_custom_tattoos_loaded)
			if(T && !QDELETED(T))
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

/datum/preferences/proc/apply_custom_tattoos_to_mob(mob/living/carbon/human/H)
	if(!istype(H))
		return

	if(islist(H.custom_body_tattoos))
		for(var/datum/custom_tattoo/T in H.custom_body_tattoos)
			if(T && !QDELETED(T))
				qdel(T)
		H.custom_body_tattoos.Cut()
	else
		H.custom_body_tattoos = list()

	if(islist(H_custom_tattoos_loaded) && length(H_custom_tattoos_loaded))
		for(var/datum/custom_tattoo/T in H_custom_tattoos_loaded)
			if(!T || QDELETED(T))
				continue
			var/current_zone = T.body_part
			if(!is_custom_tattoo_bodypart_valid(current_zone))
				continue
			var/datum/custom_tattoo/cloned = new(
				T.artist,
				T.design,
				current_zone,
				T.color,
				T.layer,
				T.is_signature,
				T.font,
				T.flair
			)
			cloned.date_applied = T.date_applied
			H.add_custom_tattoo(cloned)

/datum/preferences/proc/update_tattoo_cache_from_mob(mob/living/carbon/human/H)
	if(!istype(H) || QDELETED(H))
		return

	if(islist(H_custom_tattoos_loaded))
		for(var/datum/custom_tattoo/T in H_custom_tattoos_loaded)
			if(T && !QDELETED(T))
				qdel(T)
	H_custom_tattoos_loaded = list()

	var/list/all_tattoos = H.custom_body_tattoos
	if(!islist(all_tattoos) || !length(all_tattoos))
		return

	for(var/datum/custom_tattoo/T in all_tattoos)
		if(!T || QDELETED(T))
			continue
		var/datum/custom_tattoo/cached = new(
			T.artist,
			T.design,
			T.body_part,
			T.color,
			T.layer,
			T.is_signature,
			T.font,
			T.flair
		)
		cached.date_applied = T.date_applied
		H_custom_tattoos_loaded += cached
