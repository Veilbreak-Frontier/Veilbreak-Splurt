// This file overhauls global fluid tracking, calibrated 3-minute regeneration loops, apparel bitmask leaks, and medical scanner outputs.
// It overrides portal configuration directions and intercepts human climax calls to completely isolate fluid containers away from the stomach.

/datum/interaction/lewd/portal/fuck_anus
	cum_target = list(CLIMAX_POSITION_USER = ORGAN_SLOT_ANUS, CLIMAX_POSITION_TARGET = ORGAN_SLOT_PENIS)
	additional_details = list(INTERACTION_FILLS_CONTAINERS)

/datum/interaction/lewd/portal/fuck_anus/show_climax(mob/living/cumming, mob/living/came_in, position)
	if(position == CLIMAX_POSITION_USER)
		if(length(cum_message_text_overrides[position]))
			cum_message_text_overrides[position] = list("%CUMMING% shoots their load deep into %CAME_IN%'s anus through the portal fleshlight.")
		if(length(cum_self_text_overrides[position]))
			cum_self_text_overrides[position] = list("You shoot your load deep into %CAME_IN%'s anus through the portal fleshlight.")
		if(length(cum_partner_text_overrides[position]))
			cum_partner_text_overrides[position] = list("%CUMMING% shoots their load deep into your anus through the portal panties.")
	return ..()

/datum/interaction/lewd/portal/anal_ride
	cum_target = list(CLIMAX_POSITION_USER = ORGAN_SLOT_PENIS, CLIMAX_POSITION_TARGET = ORGAN_SLOT_ANUS)
	additional_details = list(INTERACTION_FILLS_CONTAINERS)

/datum/interaction/lewd/portal/fuck_vagina
	additional_details = list(INTERACTION_FILLS_CONTAINERS)

/datum/interaction/lewd/portal/fuck_urethra
	additional_details = list(INTERACTION_FILLS_CONTAINERS)

/datum/interaction/lewd/portal/urethral_ride
	additional_details = list(INTERACTION_FILLS_CONTAINERS)

/datum/interaction/lewd/portal/vaginal_ride
	additional_details = list(INTERACTION_FILLS_CONTAINERS)

/obj/item/organ/genital/process(seconds_per_tick)
	if(!owner || !reagents || !reagents.total_volume)
		STOP_PROCESSING(SSprocessing, src)
		return
	var/clothing_leakage_pass = FALSE
	var/obj/item/clothing/under/U = owner.w_uniform
	var/obj/item/clothing/suit/S = owner.wear_suit
	if(U && !istype(U, /obj/item/clothing/sextoy))
		if(!(U.body_parts_covered & LEGS))
			clothing_leakage_pass = TRUE
		else if(findtext(U.name, "skirt") || findtext(U.name, "dress") || findtext(U.name, "kilt") || findtext(U.name, "gown") || findtext(U.name, "kimono") || findtext(U.name, "qipao"))
			clothing_leakage_pass = TRUE
	if(S && !istype(S, /obj/item/clothing/sextoy))
		if(!(S.body_parts_covered & LEGS))
			clothing_leakage_pass = TRUE
		else if(findtext(S.name, "skirt") || findtext(S.name, "dress") || findtext(S.name, "cloak") || findtext(S.name, "gown") || findtext(S.name, "kimono"))
			clothing_leakage_pass = TRUE
	if(owner.is_bottomless() || clothing_leakage_pass)
		var/drip_volume = min(0.2 * (seconds_per_tick / 2), reagents.total_volume)
		var/turf/T = get_turf(owner)
		if(T && drip_volume > 0)
			reagents.remove_any(drip_volume)
			var/datum/reagents/LeakR = new(drip_volume)
			LeakR.add_reagent(src.internal_fluid_datum, drip_volume)
			T.add_liquid_from_reagents(LeakR, FALSE, 1)
			qdel(LeakR)
	if(!reagents.total_volume)
		STOP_PROCESSING(SSprocessing, src)

/datum/status_effect/body_fluid_regen/vagina/tick(seconds_between_ticks)
	var/mob/living/carbon/human/affected_human = owner
	if(owner.stat >= DEAD || !owner.client?.prefs?.read_preference(/datum/preference/toggle/erp) || !istype(affected_human))
		return FALSE
	var/obj/item/organ/genital/vagina/vagina = owner.get_organ_slot(ORGAN_SLOT_VAGINA)
	if(!istype(vagina))
		owner.remove_status_effect(/datum/status_effect/body_fluid_regen/vagina)
		return FALSE
	if(affected_human.arousal > 10)
		var/scaled_regen = (affected_human.arousal / 25) * (vagina.reagents.maximum_volume / 10) * 0.27 * (seconds_between_ticks / 5)
		vagina.reagents.add_reagent(vagina.internal_fluid_datum, min(scaled_regen, 2.0))
	else
		vagina.reagents.remove_reagent(vagina.internal_fluid_datum, 0.05 * (seconds_between_ticks / 5))

/datum/status_effect/body_fluid_regen/testes/tick(seconds_between_ticks)
	var/mob/living/carbon/human/affected_human = owner
	if(owner.stat >= DEAD || !owner.client?.prefs?.read_preference(/datum/preference/toggle/erp) || !istype(affected_human))
		return FALSE
	var/obj/item/organ/genital/testicles/testes = owner.get_organ_slot(ORGAN_SLOT_TESTICLES)
	if(!istype(testes))
		owner.remove_status_effect(/datum/status_effect/body_fluid_regen/testes)
		return FALSE
	var/active_arousal = max(15, affected_human.arousal)
	var/scaled_regen = (active_arousal / 25) * (testes.reagents.maximum_volume / 20) * 0.55 * (seconds_between_ticks / 5)
	testes.reagents.add_reagent(testes.internal_fluid_datum, min(scaled_regen, 4.0))

/datum/status_effect/body_fluid_regen/breasts/tick(seconds_between_ticks)
	var/mob/living/carbon/human/affected_human = owner
	if(owner.stat >= DEAD || !owner.client?.prefs?.read_preference(/datum/preference/toggle/erp) || !istype(affected_human))
		return FALSE
	var/obj/item/organ/genital/breasts/breasts = owner.get_organ_slot(ORGAN_SLOT_BREASTS)
	if(!istype(breasts) || !breasts.lactates)
		owner.remove_status_effect(/datum/status_effect/body_fluid_regen/breasts)
		return FALSE
	var/hunger_factor = (owner.nutrition / 450)
	var/scaled_regen = hunger_factor * (breasts.reagents.maximum_volume / 60) * 1.66 * (seconds_between_ticks / 5)
	var/final_regen = min(scaled_regen, 6.0)
	if(breasts.reagents.total_volume < breasts.reagents.maximum_volume)
		var/free_space = breasts.reagents.maximum_volume - breasts.reagents.total_volume
		if(final_regen > free_space)
			final_regen = free_space
		owner.adjust_nutrition(-final_regen * 0.05)
		breasts.reagents.add_reagent(breasts.internal_fluid_datum, final_regen)

/obj/item/healthanalyzer/afterattack(atom/movable/A, mob/user)
	..()
	if(!ishuman(A) || !user)
		return
	var/mob/living/carbon/human/patient = A
	var/scan_text = ""
	var/obj/item/organ/genital/vagina/V = patient.get_organ_slot(ORGAN_SLOT_VAGINA)
	if(V && V.reagents && V.reagents.total_volume)
		scan_text += "\n <span class='notice ml-1'>* Subject contains the following reagents in their Womb:</span><br>"
		for(var/datum/reagent/R in V.reagents.reagent_list)
			scan_text += " <span class='notice ml-2'>- [R.name]: [R.volume]u</span><br>"
	var/obj/item/organ/genital/anus/An = patient.get_organ_slot(ORGAN_SLOT_ANUS)
	if(An && An.reagents && An.reagents.total_volume)
		scan_text += "\n <span class='notice ml-1'>* Subject contains the following reagents in their Bowels:</span><br>"
		for(var/datum/reagent/R in An.reagents.reagent_list)
			scan_text += " <span class='notice ml-2'>- [R.name]: [R.volume]u</span><br>"
	if(scan_text != "")
		to_chat(user, "<span class='notice'><b>Anatomical Content Analysis Results:</b></span>[scan_text]")

/mob/living/carbon/human/climax(climax_choice, manual, nonhuman_bypass_partner)
	var/obj/item/organ/genital/testicles/testicles = get_organ_slot(ORGAN_SLOT_TESTICLES)
	var/obj/item/organ/genital/vagina/vagina = get_organ_slot(ORGAN_SLOT_VAGINA)
	var/mob/living/carbon/human/partner_mob = partner
	var/destination_slot = null
	var/transfer_volume = 0
	var/fluid_type = null
	if(climax_choice == CLIMAX_PENIS && testicles)
		transfer_volume = testicles.cumshot_size
		fluid_type = testicles.internal_fluid_datum
		if(climax_interaction)
			var/target_raw = climax_interaction.cum_target[interaction_position]
			if(target_raw == ORGAN_SLOT_ANUS || target_raw == ORGAN_SLOT_VAGINA)
				destination_slot = target_raw
		if(!destination_slot && partner_mob)
			if(partner_mob.get_organ_slot(ORGAN_SLOT_VAGINA))
				destination_slot = ORGAN_SLOT_VAGINA
			else
				destination_slot = ORGAN_SLOT_ANUS
		if(partner_mob && destination_slot)
			var/obj/item/organ/genital/target_organ = partner_mob.get_organ_slot(destination_slot)
			if(target_organ && target_organ.reagents)
				target_organ.reagents.add_reagent(fluid_type, transfer_volume)
				testicles.reagents.remove_all(transfer_volume)
				START_PROCESSING(SSprocessing, target_organ)
				if(prob(5 + partner_mob.arousal))
					partner_mob.apply_status_effect(/datum/status_effect/pregnancy, partner_mob, src)
				return TRUE
	if((climax_choice == CLIMAX_VAGINA || climax_choice == CLIMAX_BOTH) && vagina)
		transfer_volume = vagina.reagents.total_volume
		fluid_type = vagina.internal_fluid_datum
		if(partner_mob)
			if(partner_mob.get_organ_slot(ORGAN_SLOT_VAGINA))
				destination_slot = ORGAN_SLOT_VAGINA
			else
				destination_slot = ORGAN_SLOT_ANUS
		if(partner_mob && destination_slot)
			var/obj/item/organ/genital/target_organ = partner_mob.get_organ_slot(destination_slot)
			if(target_organ && target_organ.reagents)
				target_organ.reagents.add_reagent(fluid_type, transfer_volume)
				vagina.reagents.remove_all(transfer_volume)
				START_PROCESSING(SSprocessing, target_organ)
				return TRUE
	return ..()

/mob/living/carbon/human/Initialize(mapload)
	. = ..()
	var/static/list/fluid_signals = list(COMSIG_REAGENT_ADD_CUM, COMSIG_REAGENT_ADD_BREASTMILK)
	RegisterSignals(src, fluid_signals, PROC_REF(handle_concubus_metabolism))

/mob/living/carbon/human/proc/handle_concubus_metabolism(datum/source, datum/reagent/handled_reagent, amount)
	SIGNAL_HANDLER
	if(!has_quirk(/datum/quirk/concubus) && !HAS_TRAIT(src, TRAIT_CONCUBUS))
		return
	var/nutrition_bonus = amount * 2
	adjust_nutrition(nutrition_bonus)
