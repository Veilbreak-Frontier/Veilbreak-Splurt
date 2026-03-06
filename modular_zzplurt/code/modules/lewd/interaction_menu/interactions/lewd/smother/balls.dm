// Ball/sac smothering interactions - smother target's face with testicles
/datum/interaction/lewd/smother/ball_smother
	name = "Ball Smother"
	description = "Smother their face with your balls. (Warning: Causes oxygen loss)"
	interaction_requires = list(INTERACTION_REQUIRE_TARGET_MOUTH)
	user_required_parts = list(ORGAN_SLOT_TESTICLES = REQUIRE_GENITAL_EXPOSED)
	target_arousal = 8
	target_pleasure = 6
	target_pain = 0
	user_arousal = 6
	user_pleasure = 6
	user_pain = 0
	oxy_damage = 3
	sound_possible = list(
		'modular_zzplurt/sound/interactions/wet1.ogg',
		'modular_zzplurt/sound/interactions/wet2.ogg'
	)
	sound_range = 1
	sound_use = TRUE

/datum/interaction/lewd/smother/ball_smother/act(mob/living/user, mob/living/target)
	message = null

	// Base values
	target_arousal = 8
	target_pleasure = 6
	user_arousal = 6
	user_pleasure = 6
	oxy_damage = 3

	switch(resolve_intent_name(user))
		if("harm")
			oxy_damage = rand(3, 6)
			target_pain = 4
			message = list(
				"drops their heavy ballsack onto %TARGET%'s face, crushing their nose and blocking airways.",
				"presses their testicles hard against %TARGET%'s mouth and nose, smothering them.",
				"forces %TARGET%'s face into their balls, cutting off all air supply."
			)
		if("grab")
			target_arousal += 3
			target_pleasure += 2
			user_arousal += 2
			message = list(
				"wraps their legs around %TARGET%'s head and pulls their balls over their face.",
				"presses their sac against %TARGET%'s nose and mouth, smothering them.",
				"grinds their balls over %TARGET%'s face, blocking their airways."
			)
		else // help
			message = list(
				"gently lowers their balls onto %TARGET%'s face.",
				"carefully covers %TARGET%'s nose and mouth with their sac.",
				"lays their testicles over %TARGET%'s face, a warm smother."
			)

	// Check for choke slut trait
	if(HAS_TRAIT(target, TRAIT_CHOKE_SLUT))
		target_arousal += 8
		target_pleasure += 4
		to_chat(target, span_purple("You can barely breathe with their balls on your face... it's incredible!"))

	// Apply oxygen damage
	if(!HAS_TRAIT(target, TRAIT_NOBREATH) && oxy_damage)
		if(target.get_oxy_loss() > 40)
			oxy_damage = 0
		if(oxy_damage)
			target.apply_damage(oxy_damage, OXY)

	. = ..()

/datum/interaction/lewd/smother/ball_smother_deep
	name = "Deep Ball Smother"
	description = "Force their face into your sac. (Warning: Causes severe oxygen loss)"
	interaction_requires = list(INTERACTION_REQUIRE_TARGET_MOUTH)
	user_required_parts = list(ORGAN_SLOT_TESTICLES = REQUIRE_GENITAL_EXPOSED)
	target_arousal = 10
	target_pleasure = 8
	target_pain = 2
	user_arousal = 8
	user_pleasure = 6
	user_pain = 0
	oxy_damage = 5
	sound_possible = list(
		'modular_zzplurt/sound/interactions/wet1.ogg',
		'modular_zzplurt/sound/interactions/wet2.ogg'
	)
	sound_range = 1
	sound_use = TRUE
	message = list(
		"shoves %TARGET%'s face deep into their ballsack, completely enveloping their head.",
		"forces %TARGET%'s face into their sac, squeezing tight around their head.",
		"wraps their heavy testicles around %TARGET%'s face, cutting off all air completely."
	)

/datum/interaction/lewd/smother/ball_smother_deep/act(mob/living/user, mob/living/target)
	// Check for choke slut trait
	if(HAS_TRAIT(target, TRAIT_CHOKE_SLUT))
		target_arousal += 10
		target_pleasure += 6
		to_chat(target, span_purple("You can't breathe at all! It's so hot! You need more!"))

	// Apply oxygen damage
	if(!HAS_TRAIT(target, TRAIT_NOBREATH) && oxy_damage)
		if(target.get_oxy_loss() > 40)
			oxy_damage = 0
		if(oxy_damage)
			target.apply_damage(oxy_damage, OXY)

	. = ..()

