/**
 * SPLURT Edit: Body Morpher Presets
 * 
 * Extends the base /datum/action/innate/alter_form with preset save/load functionality.
 * Presets are stored in a JSON file per player in their save directory.
 */

// Preset subtype of alter_form with preset support
/datum/action/innate/alter_form/preset
	name = "Alter Form"
	button_icon_state = "alter_form"
	button_icon = 'modular_skyrat/master_files/icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"

/// Path to the presets save file for a given ckey
/proc/get_body_morpher_presets_path(ckey)
	if(!ckey)
		return null
	return "data/player_saves/[ckey[1]]/[ckey]/body_morpher_presets.json"

/// Load presets from the player's save file
/proc/load_body_morpher_presets(ckey)
	var/path = get_body_morpher_presets_path(ckey)
	if(!path || !fexists(path))
		return list()
	var/file_content = file2text(path)
	if(!file_content)
		return list()
	var/data = json_decode(file_content)
	if(!islist(data))
		return list()
	return data["presets"] || list()

/// Save presets to the player's save file
/proc/save_body_morpher_presets(ckey, list/presets)
	var/path = get_body_morpher_presets_path(ckey)
	if(!path)
		return FALSE
	var/full_data = list(
		"presets" = presets,
		"version" = 1
	)
	WRITE_FILE(path, json_encode(full_data))
	return TRUE

/// Gather all relevant body data from a human mob for preset saving
/proc/gather_body_morpher_data(mob/living/carbon/human/target)
	if(!istype(target))
		return null

	. = list()

	// Body colors
	.["mutant_color"] = target.dna.features[FEATURE_MUTANT_COLOR]
	.["mutant_color_two"] = target.dna.features[FEATURE_MUTANT_COLOR_TWO]
	.["mutant_color_three"] = target.dna.features[FEATURE_MUTANT_COLOR_THREE]

	// Body size
	.["body_size"] = target.dna.features["body_size"]

	// Gender & physique
	.["gender"] = target.gender
	.["physique"] = target.physique

	// Hair colors
	.["hair_color"] = target.hair_color
	.["facial_hair_color"] = target.facial_hair_color

	// Hairstyles
	.["hairstyle"] = target.hairstyle
	.["facial_hairstyle"] = target.facial_hairstyle

	// Mutant bodyparts (deep copy to avoid reference issues)
	.["mutant_bodyparts"] = deep_copy_list(target.dna.species.mutant_bodyparts)
	.["dna_mutant_bodyparts"] = deep_copy_list(target.dna.mutant_bodyparts)

	// Body markings
	.["body_markings"] = deep_copy_list(target.dna.species.body_markings)

	// Genitals data (from DNA features)
	.["breasts_lactation"] = target.dna.features["breasts_lactation"]
	.["breasts_size"] = target.dna.features["breasts_size"]
	.["penis_girth"] = target.dna.features["penis_girth"]
	.["penis_size"] = target.dna.features["penis_size"]
	.["penis_sheath"] = target.dna.features["penis_sheath"]
	.["penis_taur_mode"] = target.dna.features["penis_taur_mode"]
	.["balls_size"] = target.dna.features["balls_size"]
	.["butt_size"] = target.dna.features["butt_size"]
	.["belly_size"] = target.dna.features["belly_size"]

/// Apply preset data to a human mob
/proc/apply_body_morpher_data(mob/living/carbon/human/target, list/data)
	if(!istype(target) || !data)
		return FALSE

	// Body colors
	if("mutant_color" in data)
		target.dna.features[FEATURE_MUTANT_COLOR] = data["mutant_color"]
		target.dna.update_uf_block(/datum/dna_block/feature/mutant_color)
	if("mutant_color_two" in data)
		target.dna.features[FEATURE_MUTANT_COLOR_TWO] = data["mutant_color_two"]
		target.dna.update_uf_block(/datum/dna_block/feature/mutant_color/two)
	if("mutant_color_three" in data)
		target.dna.features[FEATURE_MUTANT_COLOR_THREE] = data["mutant_color_three"]
		target.dna.update_uf_block(/datum/dna_block/feature/mutant_color/three)

	// Body size
	if("body_size" in data)
		target.update_size(data["body_size"])

	// Gender & physique
	if("gender" in data)
		target.gender = data["gender"]
		target.dna.update_ui_block(/datum/dna_block/identity/gender)
	if("physique" in data)
		target.physique = data["physique"]

	// Hair colors
	if("hair_color" in data)
		target.hair_color = data["hair_color"]
	if("facial_hair_color" in data)
		target.facial_hair_color = data["facial_hair_color"]

	// Hairstyles
	if("hairstyle" in data)
		target.set_hairstyle(data["hairstyle"], update = FALSE)
	if("facial_hairstyle" in data)
		target.set_facial_hairstyle(data["facial_hairstyle"], update = FALSE)

	// Mutant bodyparts
	if("mutant_bodyparts" in data)
		target.dna.species.mutant_bodyparts = deep_copy_list(data["mutant_bodyparts"])
	if("dna_mutant_bodyparts" in data)
		target.dna.mutant_bodyparts = deep_copy_list(data["dna_mutant_bodyparts"])

	// Body markings
	if("body_markings" in data)
		target.dna.species.body_markings = deep_copy_list(data["body_markings"])

	// Genitals data (DNA features only, not organs)
	if("breasts_lactation" in data)
		target.dna.features["breasts_lactation"] = data["breasts_lactation"]
	if("breasts_size" in data)
		target.dna.features["breasts_size"] = data["breasts_size"]
	if("penis_girth" in data)
		target.dna.features["penis_girth"] = data["penis_girth"]
	if("penis_size" in data)
		target.dna.features["penis_size"] = data["penis_size"]
	if("penis_sheath" in data)
		target.dna.features["penis_sheath"] = data["penis_sheath"]
	if("penis_taur_mode" in data)
		target.dna.features["penis_taur_mode"] = data["penis_taur_mode"]
	if("balls_size" in data)
		target.dna.features["balls_size"] = data["balls_size"]
	if("butt_size" in data)
		target.dna.features["butt_size"] = data["butt_size"]
	if("belly_size" in data)
		target.dna.features["belly_size"] = data["belly_size"]

	// Apply organ-specific genital changes
	apply_body_morpher_genitals(target, data)

	// Full update
	target.mutant_renderkey = ""
	target.update_body(is_creating = TRUE)
	target.update_body_parts()
	target.update_clothing(ALL)

	return TRUE

/// Apply genital organ-specific changes from preset data
/proc/apply_body_morpher_genitals(mob/living/carbon/human/target, list/data)
	if(!istype(target) || !data)
		return

	// Breasts
	var/obj/item/organ/genital/breasts/breasts = target.get_organ_slot(ORGAN_SLOT_BREASTS)
	if(breasts)
		if("breasts_lactation" in data)
			breasts.lactates = data["breasts_lactation"]
		if("breasts_size" in data)
			var/size = data["breasts_size"]
			breasts.set_size(size)

	// Penis
	var/obj/item/organ/genital/penis/penis = target.get_organ_slot(ORGAN_SLOT_PENIS)
	if(penis)
		if("penis_girth" in data)
			penis.girth = data["penis_girth"]
		if("penis_size" in data)
			var/size = data["penis_size"]
			penis.set_size(size)
		if("penis_sheath" in data)
			penis.sheath = data["penis_sheath"]
		// Note: penis_taur_mode is handled via DNA features in apply_body_morpher_data

	// Testicles
	var/obj/item/organ/genital/testicles/testicles = target.get_organ_slot(ORGAN_SLOT_TESTICLES)
	if(testicles)
		if("balls_size" in data)
			var/size = data["balls_size"]
			testicles.set_size(size)

	// Butt
	var/obj/item/organ/genital/butt/butt = target.get_organ_slot(ORGAN_SLOT_BUTT)
	if(butt)
		if("butt_size" in data)
			var/size = data["butt_size"]
			butt.set_size(size)

	// Belly
	var/obj/item/organ/genital/belly/belly = target.get_organ_slot(ORGAN_SLOT_BELLY)
	if(belly)
		if("belly_size" in data)
			var/size = data["belly_size"]
			belly.set_size(size)

/datum/action/innate/alter_form/preset/change_form(mob/living/carbon/human/alterer)
	var/selected_alteration = show_radial_menu(
		alterer,
		alterer,
		list(
			"Body Colours" = image(icon = 'modular_skyrat/master_files/icons/mob/actions/actions_slime.dmi', icon_state = "slime_rainbow"),
			"DNA" = image(icon = 'modular_skyrat/master_files/icons/mob/actions/actions_slime.dmi', icon_state = "dna"),
			"Hair" = image(icon = 'modular_skyrat/master_files/icons/mob/actions/actions_slime.dmi', icon_state = "scissors"),
			"Markings" = image(icon = 'modular_skyrat/master_files/icons/mob/actions/actions_slime.dmi', icon_state = "rainbow_spraycan"),
			"Presets" = image(icon = 'modular_skyrat/master_files/icons/mob/actions/actions_slime.dmi', icon_state = "dna"),
		),
		tooltips = TRUE,
	)
	switch(selected_alteration)
		if("Body Colours")
			alter_colours(alterer)
		if("DNA")
			alter_dna(alterer)
		if("Hair")
			alter_hair(alterer)
		if("Markings")
			alter_markings(alterer)
		if("Presets")
			alter_presets(alterer)

/datum/action/innate/alter_form/preset/proc/alter_presets(mob/living/carbon/human/alterer)
	if(!alterer?.client)
		return

	var/ckey = alterer.client.ckey
	var/list/presets = load_body_morpher_presets(ckey)

	var/choice = tgui_alert(
		alterer,
		"What would you like to do with presets?",
		"Body Morpher Presets",
		list("Load Preset", "Save Preset", "Delete Preset", "Cancel")
	)

	switch(choice)
		if("Load Preset")
			load_preset(alterer, presets)
		if("Save Preset")
			save_preset(alterer, presets, ckey)
		if("Delete Preset")
			delete_preset(alterer, presets, ckey)

/datum/action/innate/alter_form/preset/proc/load_preset(mob/living/carbon/human/alterer, list/presets)
	if(!length(presets))
		alterer.balloon_alert(alterer, "no presets saved!")
		return

	var/list/preset_names = list()
	for(var/name in presets)
		preset_names += name

	var/chosen = tgui_input_list(alterer, "Select a preset to load", "Load Preset", preset_names)
	if(!chosen || !presets[chosen])
		return

	var/list/preset_data = presets[chosen]
	if(apply_body_morpher_data(alterer, preset_data))
		alterer.balloon_alert(alterer, "loaded preset: [chosen]")
	else
		alterer.balloon_alert(alterer, "failed to load preset!")

/datum/action/innate/alter_form/preset/proc/save_preset(mob/living/carbon/human/alterer, list/presets, ckey)
	var/name = tgui_input_text(alterer, "Enter a name for this preset", "Save Preset", max_length = 50)
	if(!name || name == "" || !alterer?.client)
		return

	// Check for duplicate names
	if(presets[name])
		var/confirm = tgui_alert(alterer, "A preset named '[name]' already exists. Overwrite it?", "Overwrite Preset", list("Yes", "No"))
		if(confirm != "Yes")
			return

	// Remove old entry if it exists
	presets -= name

	// Gather current body data and save
	var/list/body_data = gather_body_morpher_data(alterer)
	if(!body_data)
		alterer.balloon_alert(alterer, "failed to gather body data!")
		return

	presets[name] = body_data

	if(save_body_morpher_presets(ckey, presets))
		alterer.balloon_alert(alterer, "saved: [name]")
	else
		alterer.balloon_alert(alterer, "failed to save preset!")

/datum/action/innate/alter_form/preset/proc/delete_preset(mob/living/carbon/human/alterer, list/presets, ckey)
	if(!length(presets))
		alterer.balloon_alert(alterer, "no presets to delete!")
		return

	var/list/preset_names = list()
	for(var/name in presets)
		preset_names += name

	var/chosen = tgui_input_list(alterer, "Select a preset to delete", "Delete Preset", preset_names)
	if(!chosen || !presets[chosen])
		return

	var/confirm = tgui_alert(alterer, "Delete the preset '[chosen]'?", "Confirm Delete", list("Yes", "No"))
	if(confirm != "Yes")
		return

	presets -= chosen

	if(save_body_morpher_presets(ckey, presets))
		alterer.balloon_alert(alterer, "deleted: [chosen]")
	else
		alterer.balloon_alert(alterer, "failed to delete preset!")
