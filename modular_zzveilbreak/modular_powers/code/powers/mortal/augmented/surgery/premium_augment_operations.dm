#define VEILBREAK_OPERATION_PREMIUM_ORGAN "veilbreak_premium_organ"

/proc/get_premium_augments_for_zone(mob/living/carbon/target, target_zone)
	if(!target)
		return list()

	var/list/organs = target.get_organs_for_zone(target_zone)
	var/list/premium_augments = list()
	for(var/obj/item/organ/organ as anything in organs)
		if(!organ.premium)
			continue
		premium_augments += organ
	return premium_augments

/proc/pick_premium_augment_for_surgery(mob/living/surgeon, mob/living/carbon/target, target_zone, obj/item/tool)
	var/list/premium_augments = get_premium_augments_for_zone(target, target_zone)
	if(!length(premium_augments))
		return null
	if(length(premium_augments) == 1)
		return premium_augments[1]

	var/list/options = list()
	for(var/obj/item/organ/cyberimp/implant as anything in premium_augments)
		var/label = implant.name
		if(options[label])
			label = "[label] ([implant.type])"
		options[label] = implant

	var/chosen = tgui_input_list(surgeon, "Service which premium augment?", "Surgery", sort_list(options))
	if(isnull(chosen))
		return null

	var/obj/item/held_tool = surgeon.get_active_held_item()
	if(held_tool)
		held_tool = held_tool.get_proxy_attacker_for(target, surgeon)
	if(held_tool != tool)
		return null

	var/obj/item/organ/selected = options[chosen]
	if(!selected || selected.owner != target || !selected.premium)
		return null
	return selected

/datum/surgery_operation/limb/premium_augment_access
	name = "open premium augment panel"
	desc = "Open the maintenance panel on a premium cybernetic implant."
	implements = list(
		TOOL_SCREWDRIVER = 1,
		TOOL_SCALPEL = 1.33,
		/obj/item/knife = 1.5,
		/obj/item = 10,
	)
	time = 2.6 SECONDS
	preop_sound = 'sound/items/tools/screwdriver.ogg'
	success_sound = 'sound/items/tools/screwdriver2.ogg'
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_NOTABLE
	all_surgery_states_required = SURGERY_SKIN_OPEN | SURGERY_ORGANS_CUT | SURGERY_BONE_SAWED | SURGERY_VESSELS_CLAMPED

/datum/surgery_operation/limb/premium_augment_access/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	var/mob/living/carbon/human/patient = get_patient(operating_on)
	return ishuman(patient) && length(get_premium_augments_for_zone(patient, operated_zone)) > 0

/datum/surgery_operation/limb/premium_augment_access/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/mob/living/carbon/human/patient = limb.owner
	var/obj/item/organ/target_implant = pick_premium_augment_for_surgery(
		surgeon,
		patient,
		operation_args[OPERATION_TARGET_ZONE],
		tool,
	)
	if(!target_implant)
		return FALSE

	operation_args[VEILBREAK_OPERATION_PREMIUM_ORGAN] = target_implant
	var/zone_desc = patient.parse_zone_with_bodypart(operation_args[OPERATION_TARGET_ZONE])
	display_results(
		surgeon,
		patient,
		span_notice("You begin opening the access panel to [patient]'s [target_implant.name] in [zone_desc]..."),
		span_notice("[surgeon] begins opening an access panel in [patient]'s [zone_desc]."),
		span_notice("[surgeon] begins opening something inside [patient]'s [zone_desc]."),
	)
	display_pain(patient, "You feel a sharp, uncomfortable pressure in your [zone_desc]!")

/datum/surgery_operation/limb/premium_augment_access/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/mob/living/carbon/human/patient = limb.owner
	var/obj/item/organ/target_implant = operation_args[VEILBREAK_OPERATION_PREMIUM_ORGAN]
	if(!target_implant || target_implant.owner != patient || !target_implant.premium)
		surgeon.balloon_alert(surgeon, "no premium augment there!")
		return

	var/zone_desc = patient.parse_zone_with_bodypart(operation_args[OPERATION_TARGET_ZONE])
	display_results(
		surgeon,
		patient,
		span_notice("You open access to [patient]'s [target_implant.name] in [zone_desc]."),
		span_notice("[surgeon] opens access to premium augment hardware in [patient]'s [zone_desc]."),
		span_notice("[surgeon] opens access to something inside [patient]'s [zone_desc]."),
	)

/datum/surgery_operation/limb/premium_augment_maintenance
	name = "service premium augment"
	desc = "Perform maintenance on a premium cybernetic implant."
	implements = list(
		TOOL_MULTITOOL = 1,
		TOOL_WIRECUTTER = 1.54,
	)
	time = 4 SECONDS
	preop_sound = 'sound/items/tools/ratchet.ogg'
	success_sound = 'sound/machines/airlock/doorclick.ogg'
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_NOTABLE
	all_surgery_states_required = SURGERY_SKIN_OPEN | SURGERY_ORGANS_CUT | SURGERY_BONE_SAWED | SURGERY_VESSELS_CLAMPED

/datum/surgery_operation/limb/premium_augment_maintenance/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	var/mob/living/carbon/human/patient = get_patient(operating_on)
	return ishuman(patient) && length(get_premium_augments_for_zone(patient, operated_zone)) > 0

/datum/surgery_operation/limb/premium_augment_maintenance/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/mob/living/carbon/human/patient = limb.owner
	var/obj/item/organ/target_implant = operation_args[VEILBREAK_OPERATION_PREMIUM_ORGAN] || pick_premium_augment_for_surgery(
		surgeon,
		patient,
		operation_args[OPERATION_TARGET_ZONE],
		tool,
	)
	if(!target_implant)
		return FALSE
	if(target_implant.premium_component && target_implant.premium_component.quality <= 0)
		surgeon.balloon_alert(surgeon, "implant needs refurbishing first!")
		return FALSE

	operation_args[VEILBREAK_OPERATION_PREMIUM_ORGAN] = target_implant
	var/zone_desc = patient.parse_zone_with_bodypart(operation_args[OPERATION_TARGET_ZONE])
	display_results(
		surgeon,
		patient,
		span_notice("You begin servicing [patient]'s [target_implant.name] in [zone_desc]..."),
		span_notice("[surgeon] begins servicing the premium augment hardware in [patient]'s [zone_desc]."),
		span_notice("[surgeon] begins servicing something inside [patient]'s [zone_desc]."),
	)
	display_pain(patient, "You feel a sharp, uncomfortable pressure in your [zone_desc]!")

/datum/surgery_operation/limb/premium_augment_maintenance/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/mob/living/carbon/human/patient = limb.owner
	var/obj/item/organ/target_implant = operation_args[VEILBREAK_OPERATION_PREMIUM_ORGAN]
	if(!target_implant || target_implant.owner != patient || !target_implant.premium)
		surgeon.balloon_alert(surgeon, "no premium augment there!")
		return

	target_implant.premium_component?.apply_premium_maintenance(AUGMENTED_PREMIUM_QUALITY_START)
	var/zone_desc = patient.parse_zone_with_bodypart(operation_args[OPERATION_TARGET_ZONE])
	display_results(
		surgeon,
		patient,
		span_notice("You successfully service [patient]'s [target_implant.name] in [zone_desc]."),
		span_notice("[surgeon] successfully services [patient]'s [target_implant.name] in [zone_desc]."),
		span_notice("[surgeon] successfully services something inside [patient]'s [zone_desc]."),
	)
	log_combat(surgeon, patient, "serviced premium augments in", addition="COMBAT MODE: [uppertext(surgeon.combat_mode)]")

/datum/surgery_operation/limb/premium_augment_access/mechanic
	name = "open premium augment hatch"
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC | OPERATION_SELF_OPERABLE
	required_bodytype = BODYTYPE_ROBOTIC
	all_surgery_states_required = SURGERY_SKIN_OPEN | SURGERY_VESSELS_CLAMPED

/datum/surgery_operation/limb/premium_augment_maintenance/mechanic
	name = "service premium augment"
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC | OPERATION_SELF_OPERABLE
	required_bodytype = BODYTYPE_ROBOTIC
	all_surgery_states_required = SURGERY_SKIN_OPEN | SURGERY_VESSELS_CLAMPED

#undef VEILBREAK_OPERATION_PREMIUM_ORGAN
