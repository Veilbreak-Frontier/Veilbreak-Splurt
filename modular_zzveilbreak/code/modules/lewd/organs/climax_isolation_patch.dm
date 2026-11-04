// This module implements the core human climax fluid routing interceptions and cavity containment logic loops.
// It overrides the human mob climax proc to isolate fluid transfers directly into reproductive organ receptacles.
// It hooks universal reagent injection signals to provide Concubus quirk metabolic tracking whenever fluids fill any organ slot.

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
	var/obj/item/organ/genital/vagina/V = get_organ_slot(ORGAN_SLOT_VAGINA)
	if(V && V.reagents)
		RegisterSignal(V.reagents, COMSIG_REAGENTS_TRANSFERRED, PROC_REF(block_stomach_dumping))
	var/obj/item/organ/genital/anus/An = get_organ_slot(ORGAN_SLOT_ANUS)
	if(An && An.reagents)
		RegisterSignal(An.reagents, COMSIG_REAGENTS_TRANSFERRED, PROC_REF(block_stomach_dumping))

/mob/living/carbon/human/proc/block_stomach_dumping(datum/reagents/source, atom/target, amount, methods)
	SIGNAL_HANDLER
	if(target == src && (methods & INGEST))
		return COMPONENT_CANCEL_INGESTION

/mob/living/carbon/human/proc/handle_concubus_metabolism(datum/source, datum/reagent/handled_reagent, amount)
	SIGNAL_HANDLER
	if(!has_quirk(/datum/quirk/concubus) && !HAS_TRAIT(src, TRAIT_CONCUBUS))
		return
	var/nutrition_bonus = amount * 2
	adjust_nutrition(nutrition_bonus)
