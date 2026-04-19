/// Tracks theologian burden-spell resource (freeform number).
/datum/mind
	var/theologist_piety = 0

/proc/get_theologist_piety(mob/living/user)
	return user?.mind?.theologist_piety || 0

/proc/change_theologist_piety(mob/living/user, delta)
	if(!user?.mind)
		return
	user.mind.theologist_piety = max(0, user.mind.theologist_piety + delta)

#define BURDEN_REVERED_TRAIT_SOURCE "burden_revered"

// --- Prestidigitation (core sorcerous) ---

/datum/action/cooldown/spell/prestidigitation
	name = "Prestidigitation"
	desc = "The knowledge required to perform a variety of magical tricks."
	button_icon_state = "arcane_barrage"
	school = SCHOOL_CONJURATION
	cooldown_time = 12 SECONDS
	cooldown_reduction_per_rank = 2.5 SECONDS
	spell_requirements = NONE
	invocation_type = INVOCATION_EMOTE
	invocation = "Someone starts performing magic tricks!"
	invocation_self_message = "You start performing magic tricks."

/datum/action/cooldown/spell/prestidigitation/cast(atom/cast_on)
	. = ..()
	if(!isliving(owner))
		return
	owner.visible_message(
		span_notice("[owner] produces a harmless shower of sparks between [owner.p_their()] fingers."),
		span_notice("You finish a small flourish of harmless sparks and sleight of hand."),
	)
	do_sparks(2, FALSE, owner)
	switch(rand(1, 4))
		if(1)
			owner.balloon_alert(owner, "clever!")
		if(2)
			owner.SpinAnimation(speed = 3, loops = 1)
		if(3)
			if(iscarbon(owner))
				var/mob/living/carbon/C = owner
				C.adjust_drowsiness(-2 SECONDS)
		if(4)
			playsound(owner, 'sound/items/weapons/genhit.ogg', 20, TRUE)

// --- Meditate (core resonant) ---

/datum/action/cooldown/spell/meditate
	name = "Meditate"
	desc = "This state of internal focus allows them to replenish any reserves they have and purge any impurities dredged up by abusing Nature's law."
	button_icon_state = "nose"
	school = SCHOOL_CONJURATION
	cooldown_time = 12 SECONDS
	cooldown_reduction_per_rank = 2.5 SECONDS
	spell_requirements = NONE
	invocation_type = INVOCATION_EMOTE
	invocation = "Someone starts meditating."
	invocation_self_message = "You start meditating"

/datum/action/cooldown/spell/meditate/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/caster = owner
	if(!veilbreak_resonant_meditation_ok(caster))
		caster.balloon_alert(caster, "wrong place to meditate!")
		to_chat(caster, span_warning("Your resonance will not settle here."))
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/meditate/cast(atom/cast_on)
	. = ..()
	if(!iscarbon(owner))
		return
	var/mob/living/carbon/carbon_owner = owner
	carbon_owner.adjust_stamina_loss(-40, updating_stamina = TRUE, forced = TRUE)
	carbon_owner.adjust_drowsiness(-8 SECONDS)
	carbon_owner.adjust_disgust(-8)
	carbon_owner.adjust_tox_loss(-2, forced = TRUE)
	to_chat(carbon_owner, span_green("You breathe evenly; your body settles."))

// --- Burden Shared ---

/datum/action/cooldown/spell/pointed/burden_shared
	name = "A Burden Shared"
	desc = "The knowledge required to share one's burden."
	button_icon_state = "arcane_barrage"
	ranged_mousepointer = 'icons/effects/mouse_pointers/cult_target.dmi'
	school = SCHOOL_CONJURATION
	cooldown_time = 2 MINUTES
	cooldown_reduction_per_rank = 2.5 SECONDS
	spell_requirements = NONE
	invocation_type = INVOCATION_EMOTE
	invocation = "Someone starts sharing their burden!"
	invocation_self_message = "You start sharing your burden."
	cast_range = 2
	active_msg = "You reach to share someone's burden..."

/datum/action/cooldown/spell/pointed/burden_shared/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	return iscarbon(cast_on)

/datum/action/cooldown/spell/pointed/burden_shared/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return
	return . | SPELL_NO_IMMEDIATE_COOLDOWN

/datum/action/cooldown/spell/pointed/burden_shared/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/caster = owner
	var/mob/living/carbon/victim = cast_on
	if(!istype(caster) || !istype(victim))
		StartCooldown()
		return
	var/initial_caster = caster.get_total_damage()
	var/initial_target = victim.get_total_damage()
	to_chat(caster, span_notice("You begin to equalize your wounds with [victim]. Stay adjacent."))
	burden_share_tick(caster, victim, initial_caster, initial_target)

/datum/action/cooldown/spell/pointed/burden_shared/proc/burden_share_tick(mob/living/carbon/caster, mob/living/carbon/victim, initial_caster, initial_target)
	if(QDELETED(src) || QDELETED(caster) || QDELETED(victim))
		return
	if(get_dist(get_turf(caster), get_turf(victim)) > 1)
		to_chat(caster, span_warning("You are too far — the burden shared is lost."))
		StartCooldown()
		return
	var/c1 = caster.get_total_damage()
	var/c2 = victim.get_total_damage()
	if(abs(c1 - c2) < 0.5)
		resolve_piety_shared(caster, initial_caster, initial_target)
		to_chat(caster, span_green("Your injuries and [victim]'s finally match."))
		to_chat(victim, span_green("Your injuries and [caster]'s finally match."))
		StartCooldown()
		return
	var/amt = min(10, max(1, ROUND_UP(abs(c1 - c2) * 0.5)))
	if(c1 > c2)
		caster.heal_overall_damage(amt, 0, updating_health = TRUE, forced = TRUE)
		var/share_hurt = veilbreak_has_cuprous_circulation(victim) ? amt * 0.72 : amt
		victim.take_overall_damage(share_hurt, 0, updating_health = TRUE, forced = TRUE)
	else
		victim.heal_overall_damage(amt, 0, updating_health = TRUE, forced = TRUE)
		var/share_hurt = veilbreak_has_cuprous_circulation(caster) ? amt * 0.72 : amt
		caster.take_overall_damage(share_hurt, 0, updating_health = TRUE, forced = TRUE)
	caster.visible_message(
		span_notice("Injury seems to crawl between [caster] and [victim]."),
		span_notice("You feel damage shift between you and [victim]."),
		blind_message = span_notice("You hear someone stifle pain."),
	)
	addtimer(CALLBACK(src, PROC_REF(burden_share_tick), caster, victim, initial_caster, initial_target), 4 SECONDS)

/datum/action/cooldown/spell/pointed/burden_shared/proc/resolve_piety_shared(mob/living/carbon/caster, initial_caster, initial_target)
	var/delta = initial_target - initial_caster
	if(delta >= 10)
		change_theologist_piety(caster, 1)
		to_chat(caster, span_notice("You took on another's hurt: your piety grows."))
	else if(delta <= -10)
		change_theologist_piety(caster, -1)
		to_chat(caster, span_warning("You shed harm onto another: your piety wanes."))

// --- Burden Twisted ---

/datum/action/cooldown/spell/pointed/burden_twist
	name = "A Burden Twisted"
	desc = "The knowledge required to twist one's burden."
	button_icon_state = "arcane_barrage"
	ranged_mousepointer = 'icons/effects/mouse_pointers/cult_target.dmi'
	school = SCHOOL_CONJURATION
	cooldown_time = 2 MINUTES
	cooldown_reduction_per_rank = 2.5 SECONDS
	spell_requirements = NONE
	invocation_type = INVOCATION_EMOTE
	invocation = "Someone starts twisting their burden!"
	invocation_self_message = "You start twisting your burden."
	cast_range = 2
	active_msg = "You prepare to twist a burden..."

/datum/action/cooldown/spell/pointed/burden_twist/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	return iscarbon(cast_on)

/datum/action/cooldown/spell/pointed/burden_twist/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return
	return . | SPELL_NO_IMMEDIATE_COOLDOWN

/datum/action/cooldown/spell/pointed/burden_twist/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/caster = owner
	var/mob/living/carbon/victim = cast_on
	if(!istype(caster) || !istype(victim))
		StartCooldown()
		return
	to_chat(caster, span_notice("You twist [victim]'s wounds — the channel will pulse every ten seconds while you remain close."))
	burden_twist_tick(caster, victim, 0)

/datum/action/cooldown/spell/pointed/burden_twist/proc/burden_twist_tick(mob/living/carbon/caster, mob/living/carbon/victim, stage)
	if(QDELETED(src) || QDELETED(caster) || QDELETED(victim))
		return
	if(get_dist(get_turf(caster), get_turf(victim)) > 1)
		to_chat(caster, span_warning("The twisted burden snaps — you drifted too far."))
		StartCooldown()
		return
	if(stage >= 5)
		StartCooldown()
		return
	if(victim.stat == DEAD)
		to_chat(caster, span_warning("[victim] is dead — the burden unravels."))
		StartCooldown()
		return
	var/before = victim.get_total_damage()
	var/to_heal = min(30, before)
	if(to_heal <= 0)
		to_chat(caster, span_notice("[victim] has no physical wounds left to twist."))
		StartCooldown()
		return
	victim.heal_overall_damage(to_heal, 0, updating_health = TRUE, forced = TRUE)
	var/healed = before - victim.get_total_damage()
	if(healed <= 0)
		StartCooldown()
		return
	if(before > 30 && prob(40))
		change_theologist_piety(caster, 1)
		to_chat(caster, span_notice("Their suffering was deep; you feel a scrap of piety."))
	var/backlash = healed * 0.5 * (veilbreak_has_cuprous_circulation(victim) ? 0.72 : 1)
	var/brute_share = round(backlash * (rand(20, 60) / 100), DAMAGE_PRECISION)
	var/burn_share = round(backlash * (rand(10, 40) / 100), DAMAGE_PRECISION)
	var/oxy_share = max(0, backlash - brute_share - burn_share)
	victim.apply_damage(brute_share, BRUTE)
	victim.apply_damage(burn_share, BURN)
	victim.apply_damage(oxy_share, OXY)
	victim.visible_message(
		span_warning("[victim] knits for a moment, then buckles as pain twists back!"),
		span_userdanger("Relief floods you — then something cruel takes its place!"),
	)
	addtimer(CALLBACK(src, PROC_REF(burden_twist_tick), caster, victim, stage + 1), 10 SECONDS)

// --- Burden Revered ---

/datum/action/cooldown/spell/pointed/burden_revered
	name = "A Burden Revered."
	desc = "The knowledge required to revere one's burden."
	button_icon_state = "arcane_barrage"
	ranged_mousepointer = 'icons/effects/mouse_pointers/cult_target.dmi'
	school = SCHOOL_CONJURATION
	cooldown_time = 2 MINUTES
	cooldown_reduction_per_rank = 2.5 SECONDS
	spell_requirements = NONE
	invocation_type = INVOCATION_EMOTE
	invocation = "Someone starts revering their burden!"
	invocation_self_message = "You start revering your burden."
	cast_range = 2
	active_msg = "You prepare to revere a burden (self or adjacent)..."

/datum/action/cooldown/spell/pointed/burden_revered/is_valid_target(atom/cast_on)
	if(cast_on == owner)
		return iscarbon(cast_on)
	if(get_dist(get_turf(owner), get_turf(cast_on)) > 1)
		to_chat(owner, span_warning("Too far — move adjacent or select yourself."))
		return FALSE
	return iscarbon(cast_on)

/datum/action/cooldown/spell/pointed/burden_revered/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/victim = cast_on
	if(!istype(victim))
		return
	var/injury_before = victim.get_total_damage()
	ADD_TRAIT(victim, TRAIT_ANALGESIA, BURDEN_REVERED_TRAIT_SOURCE)
	to_chat(victim, span_green("Your pain dulls to a distant echo."))
	addtimer(CALLBACK(src, PROC_REF(burden_revered_clear_trait), victim), 50 SECONDS)
	for(var/i in 1 to 6)
		addtimer(CALLBACK(src, PROC_REF(burden_revered_heal_pulse), victim), i * 8 SECONDS)
	var/piety_gain = min(5, max(0, round(injury_before / 15)))
	if(piety_gain > 0 && isliving(owner))
		change_theologist_piety(owner, piety_gain)
		to_chat(owner, span_notice("Their need was great: you gain [piety_gain] piety."))

/datum/action/cooldown/spell/pointed/burden_revered/proc/burden_revered_heal_pulse(mob/living/carbon/victim)
	if(QDELETED(victim))
		return
	victim.heal_overall_damage(5, 5, updating_health = TRUE, forced = TRUE)

/datum/action/cooldown/spell/pointed/burden_revered/proc/burden_revered_clear_trait(mob/living/carbon/victim)
	if(QDELETED(victim))
		return
	REMOVE_TRAIT(victim, TRAIT_ANALGESIA, BURDEN_REVERED_TRAIT_SOURCE)
	to_chat(victim, span_warning("True feeling slowly returns to your body."))

// --- Check Piety ---

/datum/action/cooldown/mob_cooldown/check_piety
	name = "Check Piety"
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "scan_mode"
	desc = "Allows you to check your piety."
	cooldown_time = 1.5 SECONDS

/datum/action/cooldown/mob_cooldown/check_piety/Activate(atom/target_atom)
	var/p = get_theologist_piety(owner)
	to_chat(owner, span_notice("Your piety is [p]."))
	return TRUE
