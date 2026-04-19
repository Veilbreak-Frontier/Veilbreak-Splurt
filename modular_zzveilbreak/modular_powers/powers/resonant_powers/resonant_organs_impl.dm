/// Astral dantian: meditate productively only under open sky with star-like darkness.
/// Umbral dantian: meditate only in very low light; grants mild night vision and faster hunger.

/proc/veilbreak_resonant_meditation_ok(mob/living/carbon/human/human_owner)
	var/obj/item/organ/chosen = human_owner.get_organ_slot(ORGAN_SLOT_RESONANT)
	if(!istype(chosen, /obj/item/organ/resonant))
		return TRUE
	if(istype(chosen, /obj/item/organ/resonant/paracausal))
		return TRUE
	var/turf/owner_turf = get_turf(human_owner)
	if(!isturf(owner_turf))
		return FALSE
	if(istype(chosen, /obj/item/organ/resonant/astral_dantian))
		if(isspaceturf(owner_turf))
			return TRUE
		var/area/owner_area = get_area(owner_turf)
		if(!owner_area?.outdoors)
			return FALSE
		return owner_turf.get_lumcount() < 0.35
	if(istype(chosen, /obj/item/organ/resonant/umbral_dantian))
		return owner_turf.get_lumcount() <= LIGHTING_TILE_IS_DARK
	return TRUE

/obj/item/organ/resonant/paracausal/on_mob_insert(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	RegisterSignal(organ_owner, COMSIG_ATOM_EMP_ACT, PROC_REF(on_owner_emp))
	if(ishuman(organ_owner))
		var/mob/living/carbon/human/human_owner = organ_owner
		if(human_owner.physiology)
			human_owner.physiology.brain_mod *= 0.9

/obj/item/organ/resonant/paracausal/on_mob_remove(mob/living/carbon/organ_owner, special, movement_flags)
	UnregisterSignal(organ_owner, COMSIG_ATOM_EMP_ACT)
	if(ishuman(organ_owner))
		var/mob/living/carbon/human/human_owner = organ_owner
		if(human_owner.physiology)
			human_owner.physiology.brain_mod /= 0.9
	return ..()

/obj/item/organ/resonant/paracausal/proc/on_owner_emp(datum/source, severity)
	SIGNAL_HANDLER
	apply_organ_damage(12 / max(severity, 1))
	if(owner)
		to_chat(owner, span_warning("Your paracausal gland shrieks against the pulse!"))

/obj/item/organ/resonant/paracausal/on_life(seconds_per_tick, times_fired)
	..()
	if(!owner || (organ_flags & ORGAN_FAILING))
		return
	var/obj/item/organ/brain/brain = owner.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(brain?.damage > 0)
		brain.apply_organ_damage(-0.2 * seconds_per_tick)

/obj/item/organ/resonant/umbral_dantian/on_mob_insert(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	ADD_TRAIT(organ_owner, TRAIT_NIGHT_VISION, REF(src))
	if(ishuman(organ_owner))
		var/mob/living/carbon/human/human_owner = organ_owner
		if(human_owner.physiology)
			human_owner.physiology.hunger_mod *= 1.18

/obj/item/organ/resonant/umbral_dantian/on_mob_remove(mob/living/carbon/organ_owner, special, movement_flags)
	REMOVE_TRAIT(organ_owner, TRAIT_NIGHT_VISION, REF(src))
	if(ishuman(organ_owner))
		var/mob/living/carbon/human/human_owner = organ_owner
		if(human_owner.physiology)
			human_owner.physiology.hunger_mod /= 1.18
	return ..()
