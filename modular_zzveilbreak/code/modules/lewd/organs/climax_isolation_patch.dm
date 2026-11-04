// This module provides global chemistry transmission interceptions to decouple fluid transfer loops from stomach ingestion vectors.
// It overrides the stomach organ lifecycle loop to pull semen or milk loads out of digestive tracts and sort them into genitals.
// It hooks universal background initialization signals to satisfy Concubus quirk metrics without spamming user chat boxes.

/obj/item/organ/stomach/on_life(seconds_per_tick, times_fired)
	. = ..()
	if(!owner || !reagents || !reagents.total_volume)
		return
	var/static/list/lewd_fluid_paths = list(/datum/reagent/consumable/cum, /datum/reagent/consumable/femcum, /datum/reagent/consumable/milk)
	for(var/fluid_path in lewd_fluid_paths)
		var/amt = reagents.get_reagent_amount(fluid_path)
		if(amt > 0)
			var/destination_slot = ORGAN_SLOT_VAGINA
			if(!owner.get_organ_slot(ORGAN_SLOT_VAGINA))
				destination_slot = ORGAN_SLOT_ANUS
			var/obj/item/organ/genital/target_organ = owner.get_organ_slot(destination_slot)
			if(target_organ && target_organ.reagents)
				reagents.trans_to(target_organ.reagents, amt, passed_id = fluid_path, ignore_stomach = TRUE)

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
