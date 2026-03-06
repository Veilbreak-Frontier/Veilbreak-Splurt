// Butt smothering interactions - smother target's face with buttocks
/datum/interaction/lewd/smother/butt_smother
	name = "Butt Smother"
	description = "Smother their face with your butt. (Warning: Causes oxygen loss)"
	interaction_requires = list(INTERACTION_REQUIRE_TARGET_MOUTH)
	user_required_parts = list(ORGAN_SLOT_BUTT = REQUIRE_GENITAL_ANY)
	target_arousal = 6
	target_pleasure = 4
	target_pain = 0
	user_arousal = 4
	user_pleasure = 4
	user_pain = 0
	oxy_damage = 3
	sound_possible = list(
		'modular_zzplurt/sound/interactions/bang1.ogg',
		'modular_zzplurt/sound/interactions/bang2.ogg',
		'modular_zzplurt/sound/interactions/bang3.ogg'
	)
	sound_range = 1
	sound_use = TRUE

/datum/interaction/lewd/smother/butt_smother/act(mob/living/user, mob/living/target)
	message = null

	// Base values
	target_arousal = 6
	target_pleasure = 4
	user_arousal = 4
	user_pleasure = 4
	oxy_damage = 3

	switch(resolve_intent_name(user))
		if("harm")
			oxy_damage = rand(3, 6)
			target_pain = 4
			message = list(
				"slams their ass down onto %TARGET%'s face with full force, crushing their nose and blocking their airways.",
				"grinds their hips against %TARGET%'s face, forcing them to breathe in their ass.",
				"forces %TARGET%'s face deep into their cheeks, cutting off all air supply."
			)
		if("grab")
			target_arousal += 3
			target_pleasure += 2
			user_arousal += 2
			message = list(
				"presses their weight down onto %TARGET%'s face, smothering them between their cheeks.",
				"wraps their legs around %TARGET%'s head and squeezes, cutting off their air.",
				"grinds their ass against %TARGET%'s face, blocking their vision and nose."
			)
		else // help
			message = list(
				"gently lowers themselves onto %TARGET%'s face, covering their nose and mouth.",
				"carefully sits on %TARGET%'s face, letting them breathe through their cheeks.",
				"positions their butt over %TARGET%'s face, providing a soft smother."
			)

	// Check for choke slut trait - gives arousal bonus
	if(HAS_TRAIT(target, TRAIT_CHOKE_SLUT))
		target_arousal += 6
		target_pleasure += 4
		to_chat(target, span_purple("You feel dizzy from lack of air, but it only turns you on more..."))

	// Apply oxygen damage
	if(!HAS_TRAIT(target, TRAIT_NOBREATH) && oxy_damage)
		if(target.get_oxy_loss() > 40)
			oxy_damage = 0
		if(oxy_damage)
			target.apply_damage(oxy_damage, OXY)

	. = ..()

/datum/interaction/lewd/smother/butt_sit
	name = "Sit on Face"
	description = "Sit on your partner's face. (Warning: Causes oxygen loss)"
	interaction_requires = list(INTERACTION_REQUIRE_TARGET_MOUTH)
	user_required_parts = list(ORGAN_SLOT_BUTT = REQUIRE_GENITAL_ANY)
	target_arousal = 4
	target_pleasure = 6
	target_pain = 0
	user_arousal = 6
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
		"crushes %TARGET% under their weight, smothering their face.",
		"sits heavily on %TARGET%'s face, breathing heavily.",
		"uses %TARGET%'s face as a seat, pressing down with their full weight."
	)

/datum/interaction/lewd/smother/butt_sit/act(mob/living/user, mob/living/target)
	// Check for choke slut trait
	if(HAS_TRAIT(target, TRAIT_CHOKE_SLUT))
		target_arousal += 6
		target_pleasure += 4
		to_chat(target, span_purple("The pressure on your face makes you feel lightheaded... in a good way!"))

	// Apply oxygen damage
	if(!HAS_TRAIT(target, TRAIT_NOBREATH) && oxy_damage)
		if(target.get_oxy_loss() > 40)
			oxy_damage = 0
		if(oxy_damage)
			target.apply_damage(oxy_damage, OXY)

	. = ..()

