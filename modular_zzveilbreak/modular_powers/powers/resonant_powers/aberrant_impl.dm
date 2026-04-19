/proc/veilbreak_has_cuprous_circulation(mob/living/carbon/victim)
	if(!ishuman(victim))
		return FALSE
	var/mob/living/carbon/human/human_victim = victim
	if(HAS_TRAIT(human_victim, TRAIT_POWER_CUPROUS_HEART, TRAIT_POWER))
		return TRUE
	return istype(human_victim.get_organ_slot(ORGAN_SLOT_HEART), /obj/item/organ/heart/resonant/copper)

/datum/movespeed_modifier/veilbreak_muscly
	variable = TRUE
	id = "veilbreak_muscly"
	multiplicative_slowdown = -0.22

/datum/power/muscly/add(mob/living/carbon/human/target)
	target.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/veilbreak_muscly, multiplicative_slowdown = -0.22)

/mob/living/carbon/human/sound_damage(damage, deafen)
	if(HAS_TRAIT(src, TRAIT_POWER_BESTIAL) && damage > 0)
		damage *= 1.4
		if(isnum(deafen))
			deafen *= 1.15
	return ..()

/obj/item/organ/heart/resonant/copper/on_mob_insert(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	stored_circulation_type = null
	ADD_TRAIT(organ_owner, TRAIT_NO_BLOOD_REGEN, REF(src))
	if(ishuman(organ_owner))
		var/mob/living/carbon/human/human_owner = organ_owner
		if(human_owner.dna)
			stored_circulation_type = human_owner.get_bloodtype()
			human_owner.set_blood_type(BLOOD_TYPE_LIVING_COPPER)
		human_owner.physiology?.brute_mod *= 0.92
		human_owner.physiology?.burn_mod *= 0.92
		human_owner.physiology?.blood_regen_mod *= 0.25
		human_owner.physiology?.bleed_mod *= 0.65

/obj/item/organ/heart/resonant/copper/on_mob_remove(mob/living/carbon/organ_owner, special, movement_flags)
	REMOVE_TRAIT(organ_owner, TRAIT_NO_BLOOD_REGEN, REF(src))
	if(ishuman(organ_owner))
		var/mob/living/carbon/human/human_owner = organ_owner
		if(human_owner.dna)
			if(stored_circulation_type)
				human_owner.set_blood_type(stored_circulation_type)
			else if(human_owner.dna.species?.exotic_bloodtype)
				human_owner.set_blood_type(human_owner.dna.species.exotic_bloodtype)
			else
				human_owner.set_blood_type(random_human_blood_type())
		stored_circulation_type = null
		if(human_owner.physiology)
			human_owner.physiology.brute_mod /= 0.92
			human_owner.physiology.burn_mod /= 0.92
			human_owner.physiology.blood_regen_mod /= 0.25
			human_owner.physiology.bleed_mod /= 0.65
	return ..()

/obj/item/organ/heart/resonant/copper/on_life(seconds_per_tick, times_fired)
	..()
	if(!owner || (organ_flags & ORGAN_FAILING))
		return
	// Living copper knits tissue: modest passive sealing, biased toward brute and bleeding.
	var/heal_brute = 0.55 * seconds_per_tick
	var/heal_burn = 0.35 * seconds_per_tick
	if(owner.get_brute_loss() > 0)
		owner.adjust_brute_loss(-heal_brute, updating_health = TRUE, forced = TRUE)
	if(owner.get_fire_loss() > 0)
		owner.adjust_fire_loss(-heal_burn, updating_health = TRUE, forced = TRUE)
	var/bleed_close = 0.2 * seconds_per_tick
	for(var/obj/item/bodypart/part as anything in owner.bodyparts)
		part.adjustBleedStacks(-bleed_close)
