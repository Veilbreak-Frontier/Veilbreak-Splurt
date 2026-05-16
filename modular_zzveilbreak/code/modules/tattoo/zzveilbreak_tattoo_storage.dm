/datum/preferences/proc/get_custom_tattoos_serialized_for_slot(slot)
	if(!slot)
		slot = default_slot

	if(load_and_save && savefile && path != DEV_PREFS_PATH)
		var/list/char_data = savefile.get_entry("character[slot]")
		if(islist(char_data))
			var/list/from_features = char_data["features"]?["custom_tattoos"]
			if(islist(from_features))
				return from_features
			if(islist(char_data["custom_tattoos"]))
				return char_data["custom_tattoos"]

	if(slot == default_slot && islist(features?["custom_tattoos"]))
		return features["custom_tattoos"]

	return list()

/datum/preferences/proc/save_custom_tattoo_data(list/save_data, saved_slot, mob/living/carbon/human/target)
	// saved_slot: which character slot save_data belongs to when called from save_character; null treats as default_slot
	var/mob/living/carbon/human/H = target
	if(!H && parent?.mob && ishuman(parent.mob))
		H = parent.mob

	if(!H || QDELETED(H))
		if(save_data && islist(features?["custom_tattoos"]))
			save_data["custom_tattoos"] = features["custom_tattoos"]
		return

	if(isnull(saved_slot))
		saved_slot = default_slot

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

	var/body_slot = H.mind?.original_character_slot_index || default_slot

	if(body_slot == default_slot)
		if(!features)
			features = list()
		features["custom_tattoos"] = tattoo_serialization
		features -= "custom_tattoos_loaded"

	if(save_data && body_slot == saved_slot)
		save_data["custom_tattoos"] = tattoo_serialization
		if(islist(save_data["features"]))
			save_data["features"]["custom_tattoos"] = tattoo_serialization

	if(isnull(save_data) && load_and_save && savefile && path != DEV_PREFS_PATH)
		var/tree_key = "character[body_slot]"
		var/list/char_data = savefile.get_entry(tree_key)
		if(islist(char_data))
			char_data["custom_tattoos"] = tattoo_serialization
			if(!islist(char_data["features"]))
				char_data["features"] = list()
			char_data["features"]["custom_tattoos"] = tattoo_serialization
			savefile.set_entry(tree_key, char_data)
			savefile.save()

/datum/preferences/proc/load_custom_tattoo_data(slot)
	if(!features)
		features = list()

	features["custom_tattoos_loaded"] = list()

	var/list/tattoo_serialization = get_custom_tattoos_serialized_for_slot(slot)
	if(!islist(tattoo_serialization) || !length(tattoo_serialization))
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

/datum/preferences/proc/apply_custom_tattoos_to_mob(mob/living/carbon/human/H, slot)
	if(!istype(H))
		return

	if(isnull(slot))
		slot = H.mind?.original_character_slot_index || default_slot

	var/list/tattoo_serialization = get_custom_tattoos_serialized_for_slot(slot)
	if(!length(tattoo_serialization))
		return

	H.custom_body_tattoos.Cut()

	load_custom_tattoo_data(slot)

	var/list/stored = features["custom_tattoos_loaded"]
	if(!islist(stored))
		return

	for(var/datum/custom_tattoo/T as anything in stored)
		if(istype(T) && !QDELETED(T))
			var/datum/custom_tattoo/copy = new(
				T.artist,
				T.design,
				T.body_part,
				T.color,
				T.layer,
				T.is_signature,
				T.font,
				T.flair
			)
			copy.date_applied = T.date_applied
			H.add_custom_tattoo(copy, skip_prefs_save = TRUE)

	if(!H.tattoos_signal_registered)
		RegisterSignal(H, COMSIG_CARBON_REMOVE_LIMB, TYPE_PROC_REF(/mob/living/carbon/human, _tattoo_on_limb_removed))
		H.tattoos_signal_registered = TRUE

	H.regenerate_icons()
