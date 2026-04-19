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
	ADD_TRAIT(organ_owner, TRAIT_NO_BLOOD_REGEN, REF(src))
	if(ishuman(organ_owner))
		var/mob/living/carbon/human/human_owner = organ_owner
		human_owner.physiology?.brute_mod *= 0.92
		human_owner.physiology?.burn_mod *= 0.92
		human_owner.physiology?.blood_regen_mod *= 0.25
		human_owner.physiology?.bleed_mod *= 0.65

/obj/item/organ/heart/resonant/copper/on_mob_remove(mob/living/carbon/organ_owner, special, movement_flags)
	REMOVE_TRAIT(organ_owner, TRAIT_NO_BLOOD_REGEN, REF(src))
	if(ishuman(organ_owner))
		var/mob/living/carbon/human/human_owner = organ_owner
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
	var/heal = 0.35 * seconds_per_tick
	owner.adjustBruteLoss(-heal, updating_health = TRUE, forced = TRUE)
	owner.adjustFireLoss(-heal * 0.5, updating_health = TRUE, forced = TRUE)
