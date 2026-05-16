/datum/preferences
	var/list/H_custom_tattoos_loaded

/datum/preferences/proc/save_custom_tattoo_data(list/save_data, mob/living/carbon/human/explicit_mob)
	var/mob/living/carbon/human/H = explicit_mob
	if(!istype(H) && parent?.mob && ishuman(parent.mob))
		H = parent.mob

	if(!H || QDELETED(H))
		if(save_data)
			var/tree_key = "character[default_slot]"
			var/list/existing_disk_data = savefile.get_entry(tree_key)
			if(islist(existing_disk_data) && islist(existing_disk_data["custom_tattoos"]))
				save_data["custom_tattoos"] = existing_disk_data["custom_tattoos"]
			else if(islist(H_custom_tattoos_loaded) && length(H_custom_tattoos_loaded))
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
					save_data["custom_tattoos"] = fallback_serialization
		return

	var/list/tattoo_serialization = list()
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

	if(save_data)
		save_data["custom_tattoos"] = tattoo_serialization

/datum/preferences/proc/load_custom_tattoo_data(list/source_data)
	if(islist(H_custom_tattoos_loaded))
		for(var/datum/custom_tattoo/T in H_custom_tattoos_loaded)
			qdel(T)
	H_custom_tattoos_loaded = list()

	if(!source_data || !islist(source_data["custom_tattoos"]))
		return

	var/list/tattoo_serialization = source_data["custom_tattoos"]
	var/list/reconstructed_objects = list()

	for(var/data_entry in tattoo_serialization)
		var/list/data = data_entry
		if(!islist(data))
			if(islist(tattoo_serialization[data_entry]))
				data = tattoo_serialization[data_entry]
			else
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

	H_custom_tattoos_loaded = reconstructed_objects

/datum/preferences/proc/apply_custom_tattoos_to_mob(mob/living/carbon/human/H, list/source_data)
	if(!istype(H))
		return

	H.custom_body_tattoos.Cut()

	load_custom_tattoo_data(source_data)

	if(!islist(H_custom_tattoos_loaded) || !length(H_custom_tattoos_loaded))
		return

	for(var/datum/custom_tattoo/T in H_custom_tattoos_loaded)
		if(!istype(T) || QDELETED(T))
			continue
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
