/// Extra brute stacked on a normal human punch after species melee math resolves.
#define VEILBREAK_GENERIC_BONUS_DAMAGE 4
/// Parry chance vs unarmed strikes while throw mode is on (no projectiles).
#define VEILBREAK_GENERIC_BLOCK_CHANCE 40

/datum/martial_art/veilbreak_generic
	name = "Martial Art"
	id = MARTIALART_VEILBREAK_GENERIC
	var/bonus_brute = VEILBREAK_GENERIC_BONUS_DAMAGE
	var/block_chance = VEILBREAK_GENERIC_BLOCK_CHANCE

/datum/martial_art/veilbreak_generic/can_teach(mob/living/new_holder)
	return ishuman(new_holder)

/datum/martial_art/veilbreak_generic/activate_style(mob/living/new_holder)
	. = ..()
	RegisterSignal(new_holder, COMSIG_LIVING_CHECK_BLOCK, PROC_REF(check_block))

/datum/martial_art/veilbreak_generic/deactivate_style(mob/living/remove_from)
	UnregisterSignal(remove_from, COMSIG_LIVING_CHECK_BLOCK)
	return ..()

/datum/martial_art/veilbreak_generic/proc/check_block(mob/living/brawler, atom/movable/hitby, damage, attack_text, attack_type, ...)
	SIGNAL_HANDLER
	if(!can_use(brawler) || !brawler.throw_mode || INCAPACITATED_IGNORING(brawler, INCAPABLE_GRAB))
		return NONE
	if(attack_type != UNARMED_ATTACK)
		return NONE
	if(!prob(block_chance))
		return NONE

	var/mob/living/attacker = GET_ASSAILANT(hitby)
	if(istype(attacker) && brawler.Adjacent(attacker))
		brawler.visible_message(
			span_danger("[brawler] deflects [attack_text] and shoves [attacker] back!"),
			span_userdanger("You deflect [attack_text]!"),
		)
	else
		brawler.visible_message(
			span_danger("[brawler] deflects [attack_text]!"),
			span_userdanger("You deflect [attack_text]!"),
		)
	return SUCCESSFUL_BLOCK

/datum/martial_art/veilbreak_generic/harm_act(mob/living/attacker, mob/living/defender)
	if(!ishuman(attacker) || !ishuman(defender))
		return MARTIAL_ATTACK_INVALID
	var/mob/living/carbon/human/striker = attacker
	var/mob/living/carbon/human/victim = defender
	if(victim.check_block(striker, 10, striker.name, UNARMED_ATTACK))
		return MARTIAL_ATTACK_FAIL

	var/datum/species/species = striker.dna?.species
	if(!species)
		return MARTIAL_ATTACK_INVALID

	var/punch_result = species.harm(striker, victim, src)
	if(punch_result == FALSE)
		return MARTIAL_ATTACK_FAIL

	var/hit_zone = victim.get_random_valid_zone(striker.zone_selected)
	var/obj/item/bodypart/chosen = victim.get_bodypart(hit_zone)
	if(chosen)
		var/armor = victim.run_armor_check(chosen, MELEE)
		victim.apply_damage(bonus_brute, BRUTE, chosen, armor)

	return MARTIAL_ATTACK_SUCCESS
