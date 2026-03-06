// Belly smothering interactions - smother target's face with belly
/datum/interaction/lewd/smother/belly_smother
	name = "Belly Smother"
	description = "Smother their face with your belly. (Warning: Causes oxygen loss)"
	interaction_requires = list(INTERACTION_REQUIRE_TARGET_MOUTH)
	user_required_parts = list(ORGAN_SLOT_BELLY = REQUIRE_GENITAL_ANY)
	target_arousal = 6
	target_pleasure = 4
	target_pain = 0
	user_arousal = 4
	user_pleasure = 4
	user_pain = 0
	oxy_damage = 3
	sound_possible = list(
		'modular_zzplurt/sound/interactions/squelch1.ogg',
		'modular_zzplurt/sound/interactions/squelch2.ogg'
	)
	sound_range = 1
	sound_use = TRUE

/datum/interaction/lewd/smother/belly_smother/act(mob/living/user, mob/living/target)
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
				"drops their massive belly onto %TARGET%'s face, crushing them with their weight.",
				"presses their belly hard onto %TARGET%'s face, cutting off all air.",
				"forces %TARGET%'s face deep into their soft flesh, smothering them completely."
			)
		if("grab")
			target_arousal += 3
			target_pleasure += 2
			user_arousal += 2
			message = list(
				"wraps their belly around %TARGET%'s head, covering nose and mouth.",
				"presses their soft belly over %TARGET%'s face, limiting air flow.",
				"settles their weight onto %TARGET%'s face with their belly."
			)
		else // help
			message = list(
				"gently lowers their belly onto %TARGET%'s face.",
				"carefully covers %TARGET%'s face with their belly.",
				"lays their belly over %TARGET%'s nose and mouth."
			)

	// Check for choke slut trait
	if(HAS_TRAIT(target, TRAIT_CHOKE_SLUT))
		target_arousal += 6
		target_pleasure += 4
		to_chat(target, span_purple("The weight on your face is overwhelming... and so hot!"))

	// Apply oxygen damage
	if(!HAS_TRAIT(target, TRAIT_NOBREATH) && oxy_damage)
		if(target.get_oxy_loss() > 40)
			oxy_damage = 0
		if(oxy_damage)
			target.apply_damage(oxy_damage, OXY)

	. = ..()

/datum/interaction/lewd/smother/belly_sit
	name = "Sit on Belly"
	description = "Sit on your partner's face using your belly. (Warning: Causes oxygen loss)"
	interaction_requires = list(INTERACTION_REQUIRE_TARGET_MOUTH)
	user_required_parts = list(ORGAN_SLOT_BELLY = REQUIRE_GENITAL_ANY)
	target_arousal = 4
	target_pleasure = 6
	target_pain = 0
	user_arousal = 6
	user_pleasure = 4
	user_pain = 0
	oxy_damage = 2
	sound_possible = list(
		'modular_zzplurt/sound/interactions/squelch1.ogg',
		'modular_zzplurt/sound/interactions/squelch2.ogg'
	)
	sound_range = 1
	sound_use = TRUE
	message = list(
		"crushes %TARGET% under their belly weight, smothering their face.",
		"sits heavily on %TARGET%'s face, their belly pressing down.",
		"uses %TARGET%'s face as a seat, pressing their belly against them."
	)

/datum/interaction/lewd/smother/belly_sit/act(mob/living/user, mob/living/target)
	// Check for choke slut trait
	if(HAS_TRAIT(target, TRAIT_CHOKE_SLUT))
		target_arousal += 6
		target_pleasure += 4
		to_chat(target, span_purple("Your face is trapped under their weight... you can't get enough air... but it's amazing!"))

	// Apply oxygen damage
	if(!HAS_TRAIT(target, TRAIT_NOBREATH) && oxy_damage)
		if(target.get_oxy_loss() > 40)
			oxy_damage = 0
		if(oxy_damage)
			target.apply_damage(oxy_damage, OXY)

	. = ..()

