// This module implements chemical holder engine interceptions to isolate fluid logs within matching anatomical organ containers.
// It overrides trans_to on the reagents datum tree to block incoming semen and milk ingestions from routing to the stomach.
// It hooks universal background initialization signals to satisfy Concubus quirk metrics without spamming user chat boxes.

/datum/reagents/proc/trans_to(atom/target, amount, multiplier = 1, preserve_data = 1, no_react = 0, passed_id = null, transferred_by = null, methods = TOUCH, ignore_stomach = FALSE)
	if(ishuman(target) && (methods & INGEST))
		var/mob/living/carbon/human/H = target
		var/is_lewd_fluid = FALSE
		if(has_reagent(/datum/reagent/consumable/cum) || has_reagent(/datum/reagent/consumable/femcum) || has_reagent(/datum/reagent/consumable/milk))
			is_lewd_fluid = TRUE
		if(is_lewd_fluid)
			var/destination_slot = ORGAN_SLOT_VAGINA
			if(transferred_by && ishuman(transferred_by))
				var/mob/living/carbon/human/attacker = transferred_by
				if(attacker.climax_interaction)
					var/target_raw = attacker.climax_interaction.cum_target[attacker.interaction_position]
					if(target_raw == ORGAN_SLOT_ANUS || target_raw == ORGAN_SLOT_VAGINA)
						destination_slot = target_raw
			if(!H.get_organ_slot(destination_slot) && destination_slot == ORGAN_SLOT_VAGINA)
				destination_slot = ORGAN_SLOT_ANUS
			var/obj/item/organ/genital/target_organ = H.get_organ_slot(destination_slot)
			if(target_organ && target_organ.reagents)
				return ..(target_organ.reagents, amount, multiplier, preserve_data, no_react, passed_id, transferred_by, methods, ignore_stomach = TRUE)
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
