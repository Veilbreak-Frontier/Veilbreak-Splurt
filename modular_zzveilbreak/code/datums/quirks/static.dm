/datum/quirk/static_discharge
	name = "Static"
	desc = "You have a build up of static charge. People who touch you might get a little zap."
	value = 0
	icon = "bolt"

	var/last_shock_time = 0
	var/shock_cooldown = 7 SECONDS

/datum/quirk/static_discharge/add()
	RegisterSignal(quirk_holder, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_attack_hand))

/datum/quirk/static_discharge/remove()
	UnregisterSignal(quirk_holder, COMSIG_ATOM_ATTACK_HAND)

/datum/quirk/static_discharge/proc/on_attack_hand(datum/source, mob/living/user, list/modifiers)
	SIGNAL_HANDLER

	if(user == quirk_holder)
		return

	if(last_shock_time + shock_cooldown > world.time)
		return

	if(!prob(5))
		return

	// Effect
	user.do_jitter_animation(30)
	playsound(user, 'modular_zzveilbreak/sound/effects/zap.mp3', 50, TRUE)
	to_chat(user, span_warning("You feel a sharp zap as you touch [quirk_holder]!"))
	to_chat(quirk_holder, span_warning("You feel a static discharge zap [user]!"))

	// Flinch/Shock
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.Paralyze(2) // Very low duration shock/flinch (0.2 seconds)

	last_shock_time = world.time
