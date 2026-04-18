/datum/preference_middleware/powers
	var/static/list/name_to_powers
	action_delegations = list(
		"give_power" = PROC_REF(give_power),
		"remove_power" = PROC_REF(remove_power),
	)

/datum/preference_middleware/powers/get_ui_data(mob/user)
	if(length(name_to_powers) != length(GLOB.all_powers))
		initialize_names_to_powers()
	var/list/data = list()
	var/list/thaumaturge = list()
	var/list/enigmatist = list()
	var/list/theologist = list()
	var/list/psyker = list()
	var/list/cultivator = list()
	var/list/aberrant = list()
	var/list/warfighter = list()
	var/list/expert = list()
	var/list/augmented = list()
	var/max_power_points = MAXIMUM_POWER_POINTS
	var/current_points = point_check()
	for(var/power_key in GLOB.all_powers)
		var/datum/power/power = GLOB.power_datum_instances[power_key]
		var/state
		var/word
		var/color
		var/powertype
		var/rootpower = null
		if(power.root_power == power.type)
			powertype = "crown"
		else if(power.advanced)
			powertype = "diamond"
			rootpower = initial(power.root_power.name)
		else
			powertype = ""
			rootpower = initial(power.root_power.name)
		if(preferences.powers[power.name])
			state = "bad"
			word = "Forget"
		else
			state = "good"
			word = "Learn"
			if((power.cost + current_points) > max_power_points)
				state = "transparent"
				word = "N/A"
				color = "0.5"
				rootpower = null
			else
				color = "1"
		var/final_list = list(list(
				"description" = power.desc,
				"name" = power.name,
				"cost" = power.cost,
				"state" = state,
				"word" = word,
				"color" = color,
				"powertype" = powertype,
				"rootpower" = rootpower
			))
		switch(power.power_type)
			if(TRAIT_PATH_SUBTYPE_THAUMATURGE)
				thaumaturge += final_list
			if(TRAIT_PATH_SUBTYPE_ENIGMATIST)
				enigmatist += final_list
			if(TRAIT_PATH_SUBTYPE_THEOLOGIST)
				theologist += final_list
			if(TRAIT_PATH_SUBTYPE_PSYKER)
				psyker += final_list
			if(TRAIT_PATH_SUBTYPE_CULTIVATOR)
				cultivator += final_list
			if(TRAIT_PATH_SUBTYPE_ABERRANT)
				aberrant += final_list
			if(TRAIT_PATH_SUBTYPE_WARFIGHTER)
				warfighter += final_list
			if(TRAIT_PATH_SUBTYPE_EXPERT)
				expert += final_list
			if(TRAIT_PATH_SUBTYPE_AUGMENTED)
				augmented += final_list
	data["total_power_points"] = max_power_points
	data["thaumaturge"] = thaumaturge
	data["enigmatist"] = enigmatist
	data["theologist"] = theologist
	data["psyker"] = psyker
	data["cultivator"] = cultivator
	data["aberrant"] = aberrant
	data["warfighter"] = warfighter
	data["expert"] = expert
	data["augmented"] = augmented
	data["power_points"] = point_check()
	return data

/datum/preference_middleware/powers/proc/initialize_names_to_powers()
	name_to_powers = list()
	for(var/power_key in GLOB.all_powers)
		var/datum/power/power = GLOB.power_datum_instances[power_key]
		name_to_powers[power.name] = power_key

/datum/preference_middleware/powers/proc/give_power(list/params, mob/user)
	var/datum/power/power_typepath = name_to_powers[params["power_name"]]
	var/max_points = MAXIMUM_POWER_POINTS
	if(!ispath(power_typepath, /datum/power))
		return TRUE
	var/datum/power/power_meta = GLOB.power_datum_instances[power_typepath]
	if(preferences.powers)
		if(power_meta.advanced && advanced_check(power_meta))
			to_chat(user, span_boldwarning("[power_meta.name] is an advanced power! You cannot cross-path with it!"))
			return TRUE
		if(root_check(power_meta))
			to_chat(user, span_boldwarning("[power_meta.name] is missing it's root power!"))
			return TRUE
		if((point_check() + power_meta.cost) > max_points)
			return TRUE
		var/datum/power/power_datum = new power_typepath()
		if(power_datum.blacklist.len && blacklist_check(power_datum, user))
			qdel(power_datum)
			return TRUE
		if(power_datum.required_powers.len && required_check(power_datum))
			to_chat(user, span_boldwarning("[power_meta.name] is missing one or more of it's required powers!"))
			qdel(power_datum)
			return TRUE
		qdel(power_datum)
	preferences.powers[power_meta.name] = power_typepath
	return TRUE

/datum/preference_middleware/powers/proc/remove_power(list/params)
	var/datum/power/power_typepath = name_to_powers[params["power_name"]]
	if(!ispath(power_typepath, /datum/power))
		return TRUE
	var/datum/power/power_meta = GLOB.power_datum_instances[power_typepath]
	preferences.powers -= power_meta.name
	for(var/power_name in preferences.powers)
		var/datum/power/powor_type = preferences.powers[power_name]
		var/datum/power/powor_meta = GLOB.power_datum_instances[powor_type]
		if(powor_meta.advanced && advanced_check(powor_meta))
			preferences.powers -= powor_meta.name
			continue
		if(root_check(powor_meta))
			preferences.powers -= powor_meta.name
			continue
		var/datum/power/power_datum = new powor_type()
		if(power_datum.required_powers.len && required_check(power_datum))
			qdel(power_datum)
			return TRUE
		qdel(power_datum)
	return TRUE

/datum/preference_middleware/powers/proc/advanced_check(datum/power/power_check)
	var/list/types = list()
	types += get_path_type(power_check.power_type)
	for(var/power_name in preferences.powers)
		var/datum/power/pow_type = preferences.powers[power_name]
		var/datum/power/pow_meta = GLOB.power_datum_instances[pow_type]
		var/type_to_check = get_path_type(pow_meta.power_type)
		if(!(type_to_check in types))
			types += type_to_check
	if(types.len > 1)
		return TRUE
	return FALSE

/datum/preference_middleware/powers/proc/root_check(datum/power/power_check)
	if(power_check.root_power == power_check.type)
		return FALSE
	for(var/power_name in preferences.powers)
		var/datum/power/powah_type = preferences.powers[power_name]
		if(power_check.root_power == powah_type)
			return FALSE
	return TRUE

/datum/preference_middleware/powers/proc/point_check()
	var/total_points = 0
	for(var/power_name in preferences.powers)
		var/datum/power/pow_type = preferences.powers[power_name]
		var/datum/power/pow_meta = GLOB.power_datum_instances[pow_type]
		total_points += pow_meta.cost
	return total_points

/datum/preference_middleware/powers/proc/blacklist_check(datum/power/power_check, mob/user)
	for(var/power_name in preferences.powers)
		if(preferences.powers[power_name] in power_check.blacklist)
			to_chat(user, span_boldwarning("[power_name] conflicts with [power_check.name]!"))
			return TRUE
	return FALSE

/datum/preference_middleware/powers/proc/required_check(datum/power/power_check)
	var/count = 0
	for(var/power_name in preferences.powers)
		var/datum/power/required_type = preferences.powers[power_name]
		if(required_type in power_check.required_powers)
			count++
	if(count == power_check.required_powers.len)
		return FALSE
	return TRUE

/datum/preferences/proc/sanitize_powers()
	var/powers_edited = FALSE
	for(var/power_name as anything in powers)
		if(!power_name)
			powers.Remove(power_name)
			powers_edited = TRUE
			continue
		var/power_path = powers[power_name]
		if(!ispath(power_path, /datum/power))
			powers.Remove(power_name)
			powers_edited = TRUE
			continue
		if(!initial(power_path.name))
			powers.Remove(power_name)
			powers_edited = TRUE
			continue
	return powers_edited

/datum/asset/simple/powers
	assets = list(
		"gear.png" = 'modular_zzveilbreak/modular_powers/icons/ui/powers/gear.png',
		"heart.png" = 'modular_zzveilbreak/modular_powers/icons/ui/powers/heart.png',
		"seal.png" = 'modular_zzveilbreak/modular_powers/icons/ui/powers/seal.png'
	)

/datum/preference_middleware/powers/get_ui_assets()
	return list(
		get_asset_datum(/datum/asset/simple/powers),
	)

/proc/get_path_type(string)
	switch(string)
		if(TRAIT_PATH_SUBTYPE_THAUMATURGE, TRAIT_PATH_SUBTYPE_ENIGMATIST, TRAIT_PATH_SUBTYPE_THEOLOGIST)
			return TRAIT_PATH_SORCEROUS
		if(TRAIT_PATH_SUBTYPE_PSYKER, TRAIT_PATH_SUBTYPE_CULTIVATOR, TRAIT_PATH_SUBTYPE_ABERRANT)
			return TRAIT_PATH_RESONANT
		if(TRAIT_PATH_SUBTYPE_WARFIGHTER, TRAIT_PATH_SUBTYPE_EXPERT, TRAIT_PATH_SUBTYPE_AUGMENTED)
			return TRAIT_PATH_MORTAL
