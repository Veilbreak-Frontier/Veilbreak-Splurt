/datum/preferences/load_character(slot, mob/living/carbon/human/explicit_target_mob)
	value_cache = list()
	all_quirks = list()
	job_preferences = list()
	randomise = list()
	custom_emote_panel = list()
	all_powers = list()
	augments = list()
	augment_limb_styles = list()
	mutant_bodyparts = list()
	body_markings = list()
	mismatched_customization = FALSE
	allow_advanced_colors = FALSE
	alt_job_titles = list()
	general_record = ""
	security_record = ""
	medical_record = ""
	background_info = ""
	exploitable_info = ""
	languages = list()
	food_preferences = list()

	if(islist(features))
		features["custom_tattoos"] = list()
		features["custom_tattoos_loaded"] = null
	features = list()

	if(islist(H_custom_tattoos_loaded))
		for(var/datum/custom_tattoo/T in H_custom_tattoos_loaded)
			qdel(T)
	H_custom_tattoos_loaded = list()

	return ..()
