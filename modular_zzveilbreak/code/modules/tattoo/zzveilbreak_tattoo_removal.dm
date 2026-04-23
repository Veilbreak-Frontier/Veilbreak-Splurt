/datum/surgery/custom_tattoo_removal
	name = "Custom Tattoo Removal"
	steps = list(/datum/surgery_step/cauterize_custom_tattoo)
	possible_locs = list()
	surgery_flags = SURGERY_SELF_OPERABLE
	target_mobtypes = list(/mob/living/carbon/human)
	var/list/self_surgery_possible_locs = list()
	var/list/accessible_tattoos

/datum/surgery/custom_tattoo_removal/New(atom/surgery_target, surgery_location, surgery_bodypart)
	. = ..()
	if(!length(possible_locs))
		src.possible_locs = list(
			BODY_ZONE_HEAD,
			BODY_ZONE_CHEST,
			BODY_ZONE_L_ARM,
			BODY_ZONE_R_ARM,
			BODY_ZONE_L_LEG,
			BODY_ZONE_R_LEG,
			BODY_ZONE_PRECISE_GROIN,
		)
	if(!length(self_surgery_possible_locs))
		self_surgery_possible_locs = possible_locs.Copy()

/datum/surgery/custom_tattoo_removal/mechanic
	name = "Custom Tattoo Erasure (Mechanical)"
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/cauterize_custom_tattoo,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close
	)
	target_mobtypes = list(/mob/living/carbon/human)
	requires_bodypart_type = BODYTYPE_ROBOTIC | BODYTYPE_NANO

/datum/surgery/custom_tattoo_removal/mechanic/can_start(mob/user, mob/living/carbon/target)
	if(!issynthetic(target) || (target.dna && target.dna.species.id == SPECIES_PROTEAN))
		return FALSE
	return ..()

/datum/surgery/custom_tattoo_removal/can_start(mob/user, mob/living/patient)
	if(!ishuman(patient))
		return FALSE
	var/mob/living/carbon/human/H = patient

	// 1. Species Path Routing
	if(isprotean(H))
		if(src.type != /datum/surgery/custom_tattoo_removal/protean)
			return FALSE
	else if(issynthetic(H))
		if(src.type != /datum/surgery/custom_tattoo_removal/mechanic)
			return FALSE
	else
		if(src.type != /datum/surgery/custom_tattoo_removal)
			return FALSE

	var/target_zone = user.zone_selected
	var/list/tattoos = get_accessible_custom_tattoos(H)
	var/found_in_zone = FALSE

	for(var/datum/custom_tattoo/T in tattoos)
		if(T.body_part == target_zone)
			found_in_zone = TRUE
			break

	if(!found_in_zone)
		return FALSE

	src.accessible_tattoos = tattoos
	return TRUE

/datum/surgery/custom_tattoo_removal/proc/get_accessible_custom_tattoos(mob/living/carbon/human/H)
	if(!istype(H))
		return list()
	var/list/tattoos = list()
	for(var/datum/custom_tattoo/T as anything in H.custom_body_tattoos)
		if(!istype(T) || QDELETED(T))
			continue
		if(!is_custom_tattoo_bodypart_existing(H, T.body_part))
			continue
		if(!get_custom_tattoo_location_accessible(H, T.body_part))
			continue
		tattoos += T
	return tattoos

/datum/surgery_step/cauterize_custom_tattoo
	name = "cauterize custom tattoo"
	implements = list(
		/obj/item/cautery = 100,
		/obj/item/cigarette = 75,
		/obj/item/lighter = 50,
		TOOL_SCALPEL = 40,
		/obj/item/weldingtool = 25
	)
	time = 4 SECONDS
	var/datum/custom_tattoo/operated_tattoo

/datum/surgery_step/cauterize_custom_tattoo/tool_check(mob/user, obj/item/tool)
	switch(tool.type)
		if(/obj/item/weldingtool)
			var/obj/item/weldingtool/welder = tool
			if(!welder.isOn())
				to_chat(user, span_warning("You need to turn [tool] on first!"))
				return FALSE
		if(/obj/item/lighter)
			var/obj/item/lighter/lighter = tool
			if(!lighter.lit)
				to_chat(user, span_warning("You need to light [tool] first!"))
				return FALSE
		if(/obj/item/cigarette)
			var/obj/item/cigarette/cig = tool
			if(!cig.lit)
				to_chat(user, span_warning("You need to light [tool] first!"))
				return FALSE
	return TRUE

/datum/surgery_step/cauterize_custom_tattoo/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/mob/living/carbon/human/H = target
	if(!istype(H))
		to_chat(user, span_warning("This can only be performed on humans!"))
		return FALSE

	if(!H.client?.prefs?.read_preference(/datum/preference/toggle/erp/allow_bodywriting))
		to_chat(user, span_warning("[H] does not allow body modifications!"))
		return FALSE

	var/list/tattoos
	if(istype(surgery, /datum/surgery/custom_tattoo_removal))
		var/datum/surgery/custom_tattoo_removal/removal = surgery
		tattoos = removal.get_accessible_custom_tattoos(H)
	else
		tattoos = H.custom_body_tattoos

	if(!length(tattoos))
		to_chat(user, span_warning("There are no accessible tattoos here!"))
		return FALSE

	var/datum/custom_tattoo/to_remove
	if(length(tattoos) == 1)
		to_remove = tattoos[1]
	else
		var/list/tattoo_choices = list()
		for(var/datum/custom_tattoo/T as anything in tattoos)
			var/part_name = get_custom_tattoo_body_part_description(T.body_part)
			tattoo_choices["[part_name]: [T.design] by [T.artist]"] = T
		var/choice = input(user, "Which tattoo would you like to remove?", "Custom Tattoo Removal") as null|anything in tattoo_choices
		if(!choice)
			return FALSE
		to_remove = tattoo_choices[choice]

	if(!to_remove)
		return FALSE

	operated_tattoo = to_remove
	if(istype(surgery, /datum/surgery/custom_tattoo_removal))
		var/datum/surgery/custom_tattoo_removal/removal = surgery
		removal.accessible_tattoos = null

	surgery.location = to_remove.body_part

	var/atom/movable/screen/zone_sel/zone_selector = user.hud_used?.zone_select
	if(zone_selector)
		zone_selector.set_selected_zone(to_remove.body_part, user, FALSE)
	else
		user.zone_selected = to_remove.body_part

	var/burn_message
	if(istype(tool, /obj/item/cautery))
		burn_message = "You begin carefully cauterizing the custom tattoo..."
	else if(istype(tool, /obj/item/cigarette))
		burn_message = "You begin carefully burning the custom tattoo with the cigarette..."
	else if(istype(tool, /obj/item/lighter))
		burn_message = "You begin burning the custom tattoo with the lighter..."
	else if(istype(tool, /obj/item/weldingtool))
		burn_message = "You begin aggressively burning away the custom tattoo with the welding tool..."
	else
		burn_message = "You begin scraping away the custom tattoo..."

	var/part_desc = get_custom_tattoo_body_part_description(to_remove.body_part)
	display_results(
		user,
		target,
		span_notice("[burn_message]"),
		span_notice("[user] begins removing a custom tattoo from [target]'s [part_desc]."),
		span_notice("[user] begins working on [target]'s [part_desc]."),
	)
	display_pain(target, "Your [part_desc] burns with intense heat!")
	return TRUE

/datum/surgery_step/cauterize_custom_tattoo/success(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(!operated_tattoo)
		to_chat(user, span_warning("There is no custom tattoo to remove!"))
		return FALSE

	var/mob/living/carbon/human/H = target
	if(!istype(H) || QDELETED(operated_tattoo) || !(operated_tattoo in H.custom_body_tattoos))
		to_chat(user, span_warning("The tattoo appears to have already been removed!"))
		return FALSE

	var/burn_damage = 5
	var/tool_message = "carefully"

	if(istype(tool, /obj/item/cautery))
		burn_damage = 8
		tool_message = "precisely with the cautery"
	else if(istype(tool, /obj/item/cigarette))
		burn_damage = 25
		tool_message = "carefully with the cigarette"
	else if(istype(tool, /obj/item/lighter))
		burn_damage = 25
		tool_message = "crudely with the lighter"
	else if(tool.tool_behaviour == TOOL_SCALPEL)
		burn_damage = 12
		tool_message = "inefficiently with the scalpel"
	else if(istype(tool, /obj/item/weldingtool))
		burn_damage = 35
		tool_message = "aggressively with the welding tool, causing severe burns"

	if(H.remove_custom_tattoo(operated_tattoo))
		var/effective_zone = operated_tattoo.body_part || target_zone
		var/body_part_desc = get_custom_tattoo_body_part_description(effective_zone)

		display_results(
			user,
			target,
			span_notice("You successfully remove the custom tattoo [tool_message]."),
			span_notice("[user] successfully removes the custom tattoo from your [body_part_desc] [tool_message]!"),
			span_notice("[user] successfully works on your [body_part_desc]!"),
		)

		var/obj/item/bodypart/BP = H.get_bodypart(effective_zone)
		if(BP)
			if(IS_ROBOTIC_LIMB(BP) || IS_NANO_LIMB(BP))
				BP.receive_damage(brute = 0, fire = burn_damage)
			else
				BP.receive_damage(burn = burn_damage)
				if(burn_damage >= 30)
					BP.check_wounding(60, WOUND_BURN, target_zone)
				else if(burn_damage >= 20)
					BP.check_wounding(40, WOUND_BURN, target_zone)
				else if(burn_damage >= 10)
					BP.check_wounding(25, WOUND_BURN, target_zone)

		log_combat(user, target, "removed a custom tattoo from", addition="TATTOO: [operated_tattoo.design] | TOOL: [tool.name]")
	else
		to_chat(user, span_warning("Failed to remove the custom tattoo!"))

	return ..()

/datum/surgery_step/cauterize_custom_tattoo/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, fail_prob = 0)
	var/screwedmessage = ""
	switch(fail_prob)
		if(0 to 24)
			screwedmessage = " You almost had it, though."
		if(50 to 74)
			screwedmessage = " This is hard to get right in these conditions..."
		if(75 to 99)
			screwedmessage = " This is practically impossible in these conditions..."
	display_results(
		user,
		target,
		span_warning("You screw up![screwedmessage]"),
		span_warning("[user] screws up!"),
		span_notice("[user] finishes."),
	)
	var/obj/item/bodypart/BP = target.get_bodypart(operated_tattoo?.body_part || target_zone)
	if(BP)
		var/failure_damage = 20
		if(istype(tool, /obj/item/weldingtool))
			failure_damage = 50
		else if(istype(tool, /obj/item/lighter))
			failure_damage = 35
		else if(istype(tool, /obj/item/cigarette))
			failure_damage = 25
		else if(istype(tool, /obj/item/cautery))
			failure_damage = 15
		BP.receive_damage(burn = failure_damage)
		BP.check_wounding(50, WOUND_BURN, target_zone)
	return FALSE

/datum/surgery_step/protean_tattoo_flush
	name = "flush nanite pigments"
	implements = list(
		/obj/item/multitool = 100,
		/obj/item/weldingtool = 70
	)
	time = 40
	var/datum/custom_tattoo/operated_tattoo

/datum/surgery_step/protean_tattoo_flush/preop(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/datum/surgery/custom_tattoo_removal/S = surgery
	var/list/tattoos = list()
	for(var/datum/custom_tattoo/T in S.accessible_tattoos)
		if(T.body_part == target_zone)
			tattoos += T
	if(!length(tattoos))
		return FALSE
	var/datum/custom_tattoo/chosen = tattoos[1]
	if(length(tattoos) > 1)
		var/list/choices = list()
		for(var/datum/custom_tattoo/T in tattoos)
			choices["[T.design] ([T.artist])"] = T
		var/sel = input(user, "Select pattern to flush", "Nanite Flush") as null|anything in choices
		if(!sel)
			return FALSE
		chosen = choices[sel]
	operated_tattoo = chosen
	display_results(
		user,
		target,
		span_notice("You begin recalibrating the nanites in [target]'s [target_zone] to flush the [operated_tattoo.design] pattern..."),
		span_notice("[user] begins recalibrating [target]'s [target_zone] with [tool]."),
		span_notice("[user] begins recalibrating [target]'s [target_zone].")
	)
	return TRUE

/datum/surgery_step/protean_tattoo_flush/success(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(operated_tattoo)
		display_results(
			user,
			target,
			span_notice("You successfully flush the nanite pigments, erasing the [operated_tattoo.design] pattern."),
			span_notice("[user] successfully flushes the nanite pigments on [target]'s [target_zone]."),
			span_notice("[user] finishes the recalibration.")
		)
		target.custom_body_tattoos -= operated_tattoo
		qdel(operated_tattoo)
	return ..()

/datum/surgery_step/protean_tattoo_flush/failure(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_warning("You fail to recalibrate the nanites, causing the pigment to smear!"),
		span_warning("[user] fails to recalibrate the nanites on [target]'s [target_zone]."),
		span_notice("[user] stops the recalibration.")
	)
	return FALSE

/datum/surgery/custom_tattoo_removal/protean
	name = "Protean Tattoo Erasure"
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/protean_tattoo_flush,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close
	)
	target_mobtypes = list(/mob/living/carbon/human)
	possible_locs = list(BODY_ZONE_CHEST, BODY_ZONE_HEAD, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_GROIN)

/datum/surgery/custom_tattoo_removal/protean/can_start(mob/user, mob/living/carbon/human/target)
	return ..()

/datum/surgery/custom_tattoo_removal/protean/New()
	..()
	if(GLOB && !(src.type in GLOB.surgeries_list))
		GLOB.surgeries_list += src.type
