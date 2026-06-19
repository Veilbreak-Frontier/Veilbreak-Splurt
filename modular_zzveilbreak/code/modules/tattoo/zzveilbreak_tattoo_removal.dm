#define VEILBREAK_OPERATION_TATTOO "veilbreak_tattoo_target"

/// Shared helpers for custom tattoo removal operations.
/proc/get_accessible_custom_tattoos(mob/living/carbon/human/human, body_zone)
	if(!ishuman(human))
		return list()

	var/list/tattoos = list()
	for(var/datum/custom_tattoo/tattoo as anything in human.custom_body_tattoos)
		if(!istype(tattoo) || QDELETED(tattoo))
			continue
		if(body_zone && tattoo.body_part != body_zone)
			continue
		if(!is_custom_tattoo_bodypart_existing(human, tattoo.body_part))
			continue
		if(!get_custom_tattoo_location_accessible(human, tattoo.body_part))
			continue
		tattoos += tattoo
	return tattoos

/proc/pick_custom_tattoo_for_removal(mob/living/surgeon, mob/living/carbon/human/patient, body_zone, list/tattoos)
	if(!length(tattoos))
		return null
	if(length(tattoos) == 1)
		return tattoos[1]

	var/list/tattoo_choices = list()
	for(var/datum/custom_tattoo/tattoo as anything in tattoos)
		var/part_name = get_custom_tattoo_body_part_description(tattoo.body_part)
		tattoo_choices["[part_name]: [tattoo.design] by [tattoo.artist]"] = tattoo

	var/choice = input(surgeon, "Which tattoo would you like to remove?", "Custom Tattoo Removal") as null|anything in tattoo_choices
	return choice ? tattoo_choices[choice] : null

/datum/surgery_operation/limb/remove_custom_tattoo
	name = "remove custom tattoo"
	desc = "Cauterize or scrape away an accessible custom tattoo."
	implements = list(
		/obj/item/cautery = 1,
		/obj/item/cigarette = 1.33,
		/obj/item/lighter = 1.5,
		TOOL_SCALPEL = 2,
		/obj/item/weldingtool = 2.5,
	)
	time = 4 SECONDS
	operation_flags = OPERATION_SELF_OPERABLE | OPERATION_AFFECTS_MOOD
	required_bodytype = BODYTYPE_ORGANIC

/datum/surgery_operation/limb/remove_custom_tattoo/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	var/mob/living/carbon/human/patient = get_patient(operating_on)
	if(!ishuman(patient) || isprotean(patient) || issynthetic(patient))
		return FALSE
	return length(get_accessible_custom_tattoos(patient, operated_zone)) > 0

/datum/surgery_operation/limb/remove_custom_tattoo/tool_check(obj/item/tool)
	if(istype(tool, /obj/item/weldingtool))
		var/obj/item/weldingtool/welder = tool
		return welder.isOn()
	if(istype(tool, /obj/item/lighter))
		var/obj/item/lighter/lighter = tool
		return lighter.lit
	if(istype(tool, /obj/item/cigarette))
		var/obj/item/cigarette/cigarette = tool
		return cigarette.lit
	return TRUE

/datum/surgery_operation/limb/remove_custom_tattoo/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/mob/living/carbon/human/patient = limb.owner
	if(!patient.client?.prefs?.read_preference(CUSTOM_TATTOO_PREFERENCE_PATH))
		surgeon.balloon_alert(surgeon, "[patient] does not allow body modifications!")
		return FALSE

	var/datum/custom_tattoo/target_tattoo = pick_custom_tattoo_for_removal(
		surgeon,
		patient,
		operation_args[OPERATION_TARGET_ZONE],
		get_accessible_custom_tattoos(patient, operation_args[OPERATION_TARGET_ZONE]),
	)
	if(!target_tattoo)
		return FALSE

	operation_args[VEILBREAK_OPERATION_TATTOO] = target_tattoo
	operation_args[OPERATION_TARGET_ZONE] = target_tattoo.body_part

	var/part_desc = get_custom_tattoo_body_part_description(target_tattoo.body_part)
	var/burn_message = "You begin working on the custom tattoo..."
	if(istype(tool, /obj/item/cautery))
		burn_message = "You begin carefully cauterizing the custom tattoo..."
	else if(istype(tool, /obj/item/cigarette))
		burn_message = "You begin carefully burning the custom tattoo with the cigarette..."
	else if(istype(tool, /obj/item/lighter))
		burn_message = "You begin burning the custom tattoo with the lighter..."
	else if(istype(tool, /obj/item/weldingtool))
		burn_message = "You begin aggressively burning away the custom tattoo with the welding tool..."

	display_results(
		surgeon,
		patient,
		span_notice("[burn_message]"),
		span_notice("[surgeon] begins removing a custom tattoo from [patient]'s [part_desc]."),
		span_notice("[surgeon] begins working on [patient]'s [part_desc]."),
	)
	display_pain(patient, "Your [part_desc] burns with intense heat!")

/datum/surgery_operation/limb/remove_custom_tattoo/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/mob/living/carbon/human/patient = limb.owner
	var/datum/custom_tattoo/target_tattoo = operation_args[VEILBREAK_OPERATION_TATTOO]
	if(!target_tattoo || QDELETED(target_tattoo) || !(target_tattoo in patient.custom_body_tattoos))
		surgeon.balloon_alert(surgeon, "tattoo already removed!")
		return

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

	if(!patient.remove_custom_tattoo(target_tattoo))
		surgeon.balloon_alert(surgeon, "failed to remove tattoo!")
		return

	var/effective_zone = target_tattoo.body_part || operation_args[OPERATION_TARGET_ZONE]
	var/body_part_desc = get_custom_tattoo_body_part_description(effective_zone)
	display_results(
		surgeon,
		patient,
		span_notice("You successfully remove the custom tattoo [tool_message]."),
		span_notice("[surgeon] successfully removes the custom tattoo from your [body_part_desc] [tool_message]!"),
		span_notice("[surgeon] successfully works on your [body_part_desc]!"),
	)

	var/obj/item/bodypart/affected_limb = patient.get_bodypart(effective_zone) || limb
	if(affected_limb)
		if(IS_ROBOTIC_LIMB(affected_limb) || IS_NANO_LIMB(affected_limb))
			affected_limb.receive_damage(brute = 0, fire = burn_damage)
		else
			affected_limb.receive_damage(burn = burn_damage)
			if(burn_damage >= 30)
				affected_limb.check_wounding(60, WOUND_BURN, effective_zone)
			else if(burn_damage >= 20)
				affected_limb.check_wounding(40, WOUND_BURN, effective_zone)
			else if(burn_damage >= 10)
				affected_limb.check_wounding(25, WOUND_BURN, effective_zone)

	log_combat(surgeon, patient, "removed a custom tattoo from", addition="TATTOO: [target_tattoo.design] | TOOL: [tool.name]")

/datum/surgery_operation/limb/remove_custom_tattoo/on_failure(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/mob/living/carbon/human/patient = limb.owner
	var/datum/custom_tattoo/target_tattoo = operation_args[VEILBREAK_OPERATION_TATTOO]
	var/effective_zone = target_tattoo?.body_part || operation_args[OPERATION_TARGET_ZONE]
	var/obj/item/bodypart/affected_limb = patient.get_bodypart(effective_zone) || limb
	if(!affected_limb)
		return

	var/failure_damage = 20
	if(istype(tool, /obj/item/weldingtool))
		failure_damage = 50
	else if(istype(tool, /obj/item/lighter))
		failure_damage = 35
	else if(istype(tool, /obj/item/cigarette))
		failure_damage = 25
	else if(istype(tool, /obj/item/cautery))
		failure_damage = 15

	affected_limb.receive_damage(burn = failure_damage)
	affected_limb.check_wounding(50, WOUND_BURN, effective_zone)

/datum/surgery_operation/limb/remove_custom_tattoo/mechanic
	name = "erase custom tattoo"
	desc = "Scrape away a custom tattoo on a mechanical patient."
	operation_flags = OPERATION_SELF_OPERABLE | OPERATION_AFFECTS_MOOD | OPERATION_MECHANIC
	required_bodytype = BODYTYPE_ROBOTIC
	all_surgery_states_required = SURGERY_SKIN_OPEN | SURGERY_VESSELS_CLAMPED

/datum/surgery_operation/limb/remove_custom_tattoo/mechanic/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	var/mob/living/carbon/human/patient = get_patient(operating_on)
	if(!ishuman(patient) || isprotean(patient))
		return FALSE
	return length(get_accessible_custom_tattoos(patient, operated_zone)) > 0

/datum/surgery_operation/limb/protean_tattoo_flush
	name = "flush nanite tattoo pigments"
	desc = "Recalibrate protean nanites to erase a custom tattoo pattern."
	implements = list(
		TOOL_MULTITOOL = 1,
		/obj/item/weldingtool = 1.4,
	)
	time = 4 SECONDS
	operation_flags = OPERATION_SELF_OPERABLE | OPERATION_AFFECTS_MOOD | OPERATION_MECHANIC
	required_bodytype = BODYTYPE_NANO
	all_surgery_states_required = SURGERY_SKIN_OPEN | SURGERY_VESSELS_CLAMPED

/datum/surgery_operation/limb/protean_tattoo_flush/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	var/mob/living/carbon/human/patient = get_patient(operating_on)
	return isprotean(patient) && ..()

/datum/surgery_operation/limb/protean_tattoo_flush/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/mob/living/carbon/human/patient = limb.owner
	var/datum/custom_tattoo/target_tattoo = pick_custom_tattoo_for_removal(
		surgeon,
		patient,
		operation_args[OPERATION_TARGET_ZONE],
		get_accessible_custom_tattoos(patient, operation_args[OPERATION_TARGET_ZONE]),
	)
	if(!target_tattoo)
		return FALSE

	operation_args[VEILBREAK_OPERATION_TATTOO] = target_tattoo
	display_results(
		surgeon,
		patient,
		span_notice("You begin recalibrating the nanites in [patient]'s [target_tattoo.body_part] to flush the [target_tattoo.design] pattern..."),
		span_notice("[surgeon] begins recalibrating [patient]'s [parse_zone(target_tattoo.body_part)] with [tool]."),
		span_notice("[surgeon] begins recalibrating [patient]'s [parse_zone(target_tattoo.body_part)]."),
	)

/datum/surgery_operation/limb/protean_tattoo_flush/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/mob/living/carbon/human/patient = limb.owner
	var/datum/custom_tattoo/target_tattoo = operation_args[VEILBREAK_OPERATION_TATTOO]
	if(!target_tattoo || QDELETED(target_tattoo))
		return

	display_results(
		surgeon,
		patient,
		span_notice("You successfully flush the nanite pigments, erasing the [target_tattoo.design] pattern."),
		span_notice("[surgeon] successfully flushes the nanite pigments on [patient]'s [parse_zone(target_tattoo.body_part)]."),
		span_notice("[surgeon] finishes the recalibration."),
	)
	patient.custom_body_tattoos -= target_tattoo
	qdel(target_tattoo)

#undef VEILBREAK_OPERATION_TATTOO
