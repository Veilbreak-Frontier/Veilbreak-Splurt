// Thigh scissoring smothering interactions - restrict breathing between thighs
/datum/interaction/lewd/smother/thigh_smother
	name = "Thigh Scissor Smother"
	description = "Smother them between your thighs. (Warning: Causes oxygen loss)"
	interaction_requires = list(INTERACTION_REQUIRE_TARGET_MOUTH)
	user_required_parts = list(ORGAN_SLOT_VAGINA = REQUIRE_GENITAL_EXPOSED)
	target_arousal = 8
	target_pleasure = 6
	target_pain = 0
	user_arousal = 8
	user_pleasure = 6
	user_pain = 0
	oxy_damage = 3
	sound_possible = list(
		'modular_zzplurt/sound/interactions/bang1.ogg',
		'modular_zzplurt/sound/interactions/bang2.ogg',
		'modular_zzplurt/sound/interactions/bang3.ogg'
	)
	sound_range = 1
	sound_use = TRUE

/datum/interaction/lewd/smother/thigh_smother/act(mob/living/user, mob/living/target)
	message = null

	// Base values
	target_arousal = 8
	target_pleasure = 6
	user_arousal = 8
	user_pleasure = 6
	oxy_damage = 3

	switch(resolve_intent_name(user))
		if("harm")
			oxy_damage = rand(4, 7)
			target_pain = 4
			message = list(
				"squeezes their thighs around %TARGET%'s head tightly, cutting off all air.",
				"wraps their legs around %TARGET%'s neck and squeezes, blocking their airways.",
				"presses their thighs against %TARGET%'s face with crushing force, preventing breathing."
			)
		if("grab")
			target_arousal += 3
			target_pleasure += 2
			user_arousal += 2
			message = list(
				"wraps their legs around %TARGET%'s head, cutting off their air supply.",
				"squeezes %TARGET%'s head between their thighs, restricting breathing.",
				"presses their thighs against %TARGET%'s face, blocking their nose and mouth."
			)
		else // help
			message = list(
				"gently traps %TARGET%'s head between their thighs.",
				"wraps their legs around %TARGET%'s head in a soft embrace.",
				"positions %TARGET%'s face between their thighs, a warm squeeze."
			)

	// Check for choke slut trait
	if(HAS_TRAIT(target, TRAIT_CHOKE_SLUT))
		target_arousal += 8
		target_pleasure += 4
		to_chat(target, span_purple("Their thighs are so tight around your neck... you can't breathe... it's amazing!"))

	// Apply oxygen damage
	if(!HAS_TRAIT(target, TRAIT_NOBREATH) && oxy_damage)
		if(target.get_oxy_loss() > 40)
			oxy_damage = 0
		if(oxy_damage)
			target.apply_damage(oxy_damage, OXY)

	. = ..()

/datum/interaction/lewd/smother/thigh_smother_penis
	name = "Thigh Scissor Smother (Penis)"
	description = "Smother them between your thighs with your penis. (Warning: Causes oxygen loss)"
	interaction_requires = list(INTERACTION_REQUIRE_TARGET_MOUTH)
	user_required_parts = list(ORGAN_SLOT_PENIS = REQUIRE_GENITAL_EXPOSED)
	target_arousal = 8
	target_pleasure = 6
	target_pain = 0
	user_arousal = 8
	user_pleasure = 6
	user_pain = 0
	oxy_damage = 3
	sound_possible = list(
		'modular_zzplurt/sound/interactions/bang1.ogg',
		'modular_zzplurt/sound/interactions/bang2.ogg',
		'modular_zzplurt/sound/interactions/bang3.ogg'
	)
	sound_range = 1
	sound_use = TRUE

/datum/interaction/lewd/smother/thigh_smother_penis/act(mob/living/user, mob/living/target)
	message = null

	// Base values
	target_arousal = 8
	target_pleasure = 6
	user_arousal = 8
	user_pleasure = 6
	oxy_damage = 3

	switch(resolve_intent_name(user))
		if("harm")
			oxy_damage = rand(4, 7)
			target_pain = 4
			message = list(
				"thrusts their cock between %TARGET%'s lips while squeezing their thighs around their head, blocking air.",
				"shoves their penis into %TARGET%'s mouth and wraps their legs around their neck, suffocating them.",
				"forces their cock deep into %TARGET%'s throat while crushing their head with their thighs."
			)
		if("grab")
			target_arousal += 3
			target_pleasure += 2
			user_arousal += 2
			message = list(
				"thrusts into %TARGET%'s mouth while wrapping their thighs around their head.",
				"fucks %TARGET%'s face while squeezing their neck with their legs.",
				"pushes their cock between %TARGET%'s lips and cuts off their breathing with their thighs."
			)
		else // help
			message = list(
				"gently slides their cock into %TARGET%'s mouth while wrapping their thighs around their head.",
				"positions their penis in %TARGET%'s mouth while trapping their head between their thighs.",
				"thrusts slowly into %TARGET%'s mouth while providing a gentle thigh squeeze."
			)

	// Check for choke slut trait
	if(HAS_TRAIT(target, TRAIT_CHOKE_SLUT))
		target_arousal += 8
		target_pleasure += 4
		to_chat(target, span_purple("Their thighs are crushing your neck and their cock is in your mouth... you can't breathe... it's perfect!"))

	// Apply oxygen damage
	if(!HAS_TRAIT(target, TRAIT_NOBREATH) && oxy_damage)
		if(target.get_oxy_loss() > 40)
			oxy_damage = 0
		if(oxy_damage)
			target.apply_damage(oxy_damage, OXY)

	. = ..()

/datum/interaction/lewd/smother/thigh_smother_victim
	name = "Request Thigh Smother"
	description = "Ask your partner to smother you between their thighs."
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list(ORGAN_SLOT_VAGINA = REQUIRE_GENITAL_EXPOSED)
	target_arousal = 6
	target_pleasure = 4
	target_pain = 0
	user_arousal = 4
	user_pleasure = 4
	user_pain = 0
	oxy_damage = 2
	sound_possible = list(
		'modular_zzplurt/sound/interactions/bang1.ogg',
		'modular_zzplurt/sound/interactions/bang2.ogg',
		'modular_zzplurt/sound/interactions/bang3.ogg'
	)
	sound_range = 1
	sound_use = TRUE
	message = list(
		"buries their face between %USER%'s thighs, requesting to be smothered.",
		"presses their face against %USER%'s crotch, breathing in their scent.",
		"nuzzles into %USER%'s thighs, asking to be squeezed."
	)

/datum/interaction/lewd/smother/thigh_smother_victim/act(mob/living/user, mob/living/target)
	// Check for choke slut trait
	if(HAS_TRAIT(user, TRAIT_CHOKE_SLUT))
		user_arousal += 8
		user_pleasure += 4
		to_chat(user, span_purple("You can't wait to feel their thighs around your neck!"))

	// Apply oxygen damage
	if(!HAS_TRAIT(user, TRAIT_NOBREATH) && oxy_damage)
		if(user.get_oxy_loss() > 40)
			oxy_damage = 0
		if(oxy_damage)
			user.apply_damage(oxy_damage, OXY)

	. = ..()

