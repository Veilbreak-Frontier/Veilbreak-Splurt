/datum/power/void
	abstract_parent_type = /datum/power/void
	archetype = POWER_ARCHETYPE_VOID
	path = POWER_PATH_VOID
	priority = POWER_PRIORITY_BASIC

/// Void power unlocked by completing the Succubus Max Mark achievement
/datum/power/void/succubus_mark_mastery
	name = "Master of Marks"
	desc = "Having brought your succubus marking to ultimate perfection in a past life, your presence radiates a subtle alluring resonance."
	required_achievement = /datum/award/achievement/veilbreak/succubus_max_mark
	value = 5
	power_flags = POWER_PROCESSES

	/// Phrases broadcasted to nearby mobs
	var/static/list/alluring_phrases = list(
		"You feel a subtle attraction towards %X%...",
		"You have trouble looking away from %X%...",
		"Your gaze lingers on %X% for a moment longer than intended.",
		"A strange warmth stirs within you whenever %X% is near.",
		"You find %X%'s presence inexplicably alluring...",
		"A fleeting thought whispers in your mind to get closer to %X%..."
	)

/datum/power/void/succubus_mark_mastery/process(seconds_between_ticks)
	if(!power_holder || power_holder.stat != CONSCIOUS || !prob(30))
		return
	var/list/mob/living/carbon/human/nearby = list()
	for(var/mob/living/carbon/human/H in range(1, power_holder))
		if(H != power_holder && H.stat == CONSCIOUS && H.client)
			nearby += H
	if(!length(nearby))
		return
	var/mob/living/carbon/human/target = pick(nearby)
	var/phrase = pick(alluring_phrases)
	phrase = replacetext(phrase, "%X%", power_holder.name)
	to_chat(target, span_pink(phrase))

/// Void power unlocked by slaying Melos Vecare
/datum/power/void/melos_silencer
	name = "Silence the Siren"
	desc = "Having silenced Melos Vecare, her chaotic melodies no longer shake your resolve. Grants sound/ear damage protection and total immunity to slipping."
	required_achievement = /datum/award/achievement/veilbreak/melos_vecare_kill
	value = 5
	mob_trait = TRAIT_NO_SLIP_ALL

/datum/power/void/melos_silencer/add(client/client_source)
	RegisterSignal(power_holder, COMSIG_LIVING_GET_EAR_PROTECTION, PROC_REF(on_get_ear_protection))

/datum/power/void/melos_silencer/remove()
	if(power_holder)
		UnregisterSignal(power_holder, COMSIG_LIVING_GET_EAR_PROTECTION)

/datum/power/void/melos_silencer/proc/on_get_ear_protection(mob/living/source, list/ear_protection)
	SIGNAL_HANDLER
	ear_protection[EAR_PROTECTION_ARG] = max(ear_protection[EAR_PROTECTION_ARG], 100)

/// Void power unlocked by slaying Inai
/datum/power/void/inai_defiance
	name = "Unshakable Stance"
	desc = "Having stood your ground against Inai, you possess a 15% chance to phase through incoming melee strikes, dodging the hit and stepping behind your attacker."
	required_achievement = /datum/award/achievement/veilbreak/inai_kill
	value = 5

/datum/power/void/inai_defiance/add(client/client_source)
	RegisterSignal(power_holder, COMSIG_LIVING_CHECK_BLOCK, PROC_REF(on_check_block))

/datum/power/void/inai_defiance/remove()
	if(power_holder)
		UnregisterSignal(power_holder, COMSIG_LIVING_CHECK_BLOCK)

/datum/power/void/inai_defiance/proc/on_check_block(mob/living/source, atom/hit_by, damage, attack_text, attack_type, armour_penetration, damage_type)
	SIGNAL_HANDLER
	if(attack_type != MELEE_ATTACK && attack_type != UNARMED_ATTACK)
		return FAILED_BLOCK
	if(!prob(15))
		return FAILED_BLOCK

	var/mob/living/attacker = isliving(hit_by) ? hit_by : (hit_by ? hit_by.loc : null)
	if(isliving(attacker) && attacker != power_holder)
		var/turf/behind_turf = get_step(attacker, attacker.dir)
		if(behind_turf && !behind_turf.density)
			power_holder.forceMove(behind_turf)
		else
			var/turf/attacker_turf = get_turf(attacker)
			if(attacker_turf)
				power_holder.forceMove(attacker_turf)

	to_chat(power_holder, span_notice("You phase through space, dodging the attack!"))
	return SUCCESSFUL_BLOCK
