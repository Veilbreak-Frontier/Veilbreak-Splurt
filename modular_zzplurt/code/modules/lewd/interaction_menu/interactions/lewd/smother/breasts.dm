// Breast smothering interactions - smother target's face with breasts
/datum/interaction/lewd/smother/breast_smother
	name = "Breast Smother"
	description = "Smother their face with your breasts. (Warning: Causes oxygen loss)"
	interaction_requires = list(INTERACTION_REQUIRE_TARGET_MOUTH)
	user_required_parts = list(ORGAN_SLOT_BREASTS = REQUIRE_GENITAL_ANY)
	target_arousal = 6
	target_pleasure = 4
	target_pain = 0
	user_arousal = 4
	user_pleasure = 4
	user_pain = 0
	oxy_damage = 2
	sound_possible = list(
		'modular_zzplurt/sound/interactions/squelch1.ogg',
		'modular_zzplurt/sound/interactions/squelch2.ogg'
	)
	sound_range = 1
	sound_use = TRUE

/datum/interaction/lewd/smother/breast_smother/act(mob/living/user, mob/living/target)
	message = null

	// Base values
	target_arousal = 6
	target_pleasure = 4
	user_arousal = 4
	user_pleasure = 4
	oxy_damage = 2

	switch(resolve_intent_name(user))
		if("harm")
			oxy_damage = rand(2, 4)
			target_pain = 3
			message = list(
				"presses their breasts hard against %TARGET%'s face, smothering them completely.",
				"wraps their arms around %TARGET%'s head and pulls it into their chest, cutting off air.",
				"forces %TARGET%'s face between their breasts and squeezes, blocking airways."
			)
		if("grab")
			target_arousal += 3
			target_pleasure += 2
			user_arousal += 2
			message = list(
				"presses their breasts over %TARGET%'s face, covering nose and mouth.",
				"wraps their chest around %TARGET%'s head, cutting off their air.",
				"pushes %TARGET%'s face into their cleavage, smothering them."
			)
		else // help
			message = list(
				"gently presses their breasts over %TARGET%'s face.",
				"lays their chest over %TARGET%'s face, a soft smother.",
				"covers %TARGET%'s nose and mouth with their breasts."
			)

	// Check for choke slut trait
	if(HAS_TRAIT(target, TRAIT_CHOKE_SLUT))
		target_arousal += 6
		target_pleasure += 4
		to_chat(target, span_purple("The weight on your face makes you feel faint... but excited!"))

	// Apply oxygen damage
	if(!HAS_TRAIT(target, TRAIT_NOBREATH) && oxy_damage)
		if(target.get_oxy_loss() > 40)
			oxy_damage = 0
		if(oxy_damage)
			target.apply_damage(oxy_damage, OXY)

	. = ..()

/datum/interaction/lewd/smother/breast_smother_ned
	name = "Breast Smother (No Escape)"
	description = "Trapped breast smother. (Warning: Causes significant oxygen loss)"
	interaction_requires = list(INTERACTION_REQUIRE_TARGET_MOUTH, INTERACTION_REQUIRE_TARGET_HAND)
	user_required_parts = list(ORGAN_SLOT_BREASTS = REQUIRE_GENITAL_ANY)
	target_arousal = 8
	target_pleasure = 4
	target_pain = 2
	user_arousal = 6
	user_pleasure = 4
	user_pain = 0
	oxy_damage = 4
	sound_possible = list(
		'modular_zzplurt/sound/interactions/squelch1.ogg',
		'modular_zzplurt/sound/interactions/squelch2.ogg'
	)
	sound_range = 1
	sound_use = TRUE
	message = list(
		"traps %TARGET%'s head between their breasts, holding tightly and cutting off all air.",
		"uses their hands to press %TARGET%'s face deeper into their chest, not letting go.",
		"squeezes their breasts around %TARGET%'s head, a desperate, air-cutting smother."
	)

/datum/interaction/lewd/smother/breast_smother_ned/act(mob/living/user, mob/living/target)
	// Check for choke slut trait
	if(HAS_TRAIT(target, TRAIT_CHOKE_SLUT))
		target_arousal += 8
		target_pleasure += 4
		to_chat(target, span_purple("You can't breathe... and you love every second of it!"))

	// Apply oxygen damage
	if(!HAS_TRAIT(target, TRAIT_NOBREATH) && oxy_damage)
		if(target.get_oxy_loss() > 40)
			oxy_damage = 0
		if(oxy_damage)
			target.apply_damage(oxy_damage, OXY)

	. = ..()

