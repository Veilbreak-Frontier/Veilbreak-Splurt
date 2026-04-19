/// Multiplier on weapon force when a CQB-trained user pistol-whips (melee) with a gun.
#define VEILBREAK_CQB_GUN_MELEE_MULT 1.55

/// Boosts /obj/item/gun melee hits vs mobs for characters with TRAIT_POWER_CQB.
/datum/element/veilbreak_cqb_melee

/datum/element/veilbreak_cqb_melee/Attach(datum/target)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_USER_PRE_ITEM_ATTACK, PROC_REF(on_pre_item_attack))

/datum/element/veilbreak_cqb_melee/Detach(datum/source, ...)
	UnregisterSignal(source, COMSIG_USER_PRE_ITEM_ATTACK)
	return ..()

/datum/element/veilbreak_cqb_melee/proc/on_pre_item_attack(mob/living/wielder, obj/item/weapon, atom/victim, list/modifiers, list/attack_modifiers)
	SIGNAL_HANDLER
	if(!HAS_TRAIT(wielder, TRAIT_POWER_CQB))
		return NONE
	if(!istype(weapon, /obj/item/gun))
		return NONE
	if(!isliving(victim))
		return NONE
	if(weapon.item_flags & NOBLUDGEON)
		return NONE
	if(!islist(attack_modifiers))
		return NONE
	MODIFY_ATTACK_FORCE_MULTIPLIER(attack_modifiers, VEILBREAK_CQB_GUN_MELEE_MULT)
	return NONE

/datum/power/cqb/add(mob/living/carbon/human/target)
	target.AddElement(/datum/element/veilbreak_cqb_melee)
