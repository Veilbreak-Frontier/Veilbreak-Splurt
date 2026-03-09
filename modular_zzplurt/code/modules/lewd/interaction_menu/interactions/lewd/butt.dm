// Butt smothering interactions - smother target's face with butt
/datum/interaction/lewd/butt_smother
	name = "Butt Smother"
	description = "Smother their face with your butt. (Warning: Causes oxygen damage)"
	interaction_requires = list(INTERACTION_REQUIRE_TARGET_MOUTH)
	user_required_parts = list(ORGAN_SLOT_BUTT = REQUIRE_GENITAL_EXPOSED)

	message = null // Message is set in the act proc depending on intent (i'll kill most of these stupid comments at integration. I like writing to myself n stuff)
	target_arousal = 6
	target_pleasure = 4
	target_pain = 0
	user_arousal = 4
	user_pleasure = 4
	user_pain = 0
	sound_possible = list(
		'modular_zzplurt/sound/interactions/squelch1.ogg',
		'modular_zzplurt/sound/interactions/squelch2.ogg'
	)
	sound_range = 1
	sound_use = TRUE

/datum/interaction/lewd/butt_smother/allow_act(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE

	// Check if smothering is enabled in preferences
	if(!user.client?.prefs?.read_preference(/datum/preference/toggle/erp/smothering) && !(!ishuman(user) && !user.client && !SSinteractions.is_blacklisted(user)))
		return FALSE
	if(!target.client?.prefs?.read_preference(/datum/preference/toggle/erp/smothering) && !(!ishuman(target) && !target.client && !SSinteractions.is_blacklisted(target)))
		return FALSE

	return TRUE

/datum/interaction/lewd/butt_smother/act(mob/living/user, mob/living/target)

	switch(resolve_intent_name(user))
		if("harm")
			target_pain = 4
			message = list(
				"drops their heavy butt onto %TARGET%'s face, crushing them.",
				"slams their ass down onto %TARGET%'s face, blocking all air.",
				"forces %TARGET%'s face into their butt, smothering them completely."
			)
		if("grab")
			target_arousal += 3
			target_pleasure += 2
			user_arousal += 2
			message = list(
				"grabs %TARGET%'s head and pulls it into their butt.",
				"presses their ass tight against %TARGET%'s face, limiting airflow.",
				"wraps their legs around %TARGET%'s head and smothering them with their butt."
			)
		else // help
			message = list(
				"gently lowers their butt onto %TARGET%'s face, covering it completely",
				"carefully covers %TARGET%'s nose and mouth with their ass.",
				"lays their butt over %TARGET%'s face, a warm smother."
			)

	// Check for choke slut trait
	if(HAS_TRAIT(target, TRAIT_CHOKE_SLUT))
		target_arousal += 8
		target_pleasure += 4
		to_chat(target, span_purple("You can barely breathe with their ass on your face... it's incredible!"))

	. = ..()

/datum/interaction/lewd/butt_smother/post_interaction(mob/living/user, mob/living/target)
	. = ..()
	var/stat_before = target.stat
	var/oxy_damage = 3
	// Always apply oxy damage up to 45
	if(target.get_oxy_loss() < 45)
		target.adjust_oxy_loss(oxy_damage)
	// Only apply additional damage if extmharm is enabled
	else if(user.client?.prefs?.read_preference(/datum/preference/choiced/erp_status_extmharm) != "No" || target.client?.prefs?.read_preference(/datum/preference/choiced/erp_status_extmharm) != "No")
		target.adjust_oxy_loss(oxy_damage)
	// Check if target just passed out
	if(target.stat == UNCONSCIOUS && stat_before != UNCONSCIOUS)
		message = list("%TARGET% passes out under %USER%'s butt.")


/datum/interaction/lewd/butt_smother_deep
	name = "Deep Butt Smother"
	description = "Force their face into your butt. (Warning: Causes severe oxygen damage)"
	interaction_requires = list(INTERACTION_REQUIRE_TARGET_MOUTH)
	user_required_parts = list(ORGAN_SLOT_BUTT = REQUIRE_GENITAL_ANY)
	message = null
	target_arousal = 10
	target_pleasure = 8
	target_pain = 2
	user_arousal = 8
	user_pleasure = 6
	user_pain = 0
	sound_possible = list(
		'modular_zzplurt/sound/interactions/squelch1.ogg',
		'modular_zzplurt/sound/interactions/squelch2.ogg'
	)
	sound_range = 1
	sound_use = TRUE

/datum/interaction/lewd/butt_smother_deep/allow_act(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE

	// Check if smothering is enabled in preferences
	if(!user.client?.prefs?.read_preference(/datum/preference/toggle/erp/smothering) && !(!ishuman(user) && !user.client && !SSinteractions.is_blacklisted(user)))
		return FALSE
	if(!target.client?.prefs?.read_preference(/datum/preference/toggle/erp/smothering) && !(!ishuman(target) && !target.client && !SSinteractions.is_blacklisted(target)))
		return FALSE

	return TRUE

/datum/interaction/lewd/butt_smother_deep/act(mob/living/user, mob/living/target)

	switch(resolve_intent_name(user))
		if("harm")
			target_pain = 4
			message = list(
				"shoves %TARGET%'s face deep into their butt, completely enveloping their head.",
				"forces %TARGET%'s face into their ass, squeezing tight around their head.",
				"wraps their heavy butt around %TARGET%'s face, cutting off all air completely."
			)
		if("grab")
			target_arousal += 4
			target_pleasure += 3
			user_arousal += 3
			message = list(
				"pulls %TARGET%'s head deep into their butt, completely covering their face.",
				"wraps their legs around %TARGET%'s head and pushes them deep into their ass.",
				"grinds %TARGET%'s face deep into their butt, cutting off all air."
			)
		else // help
			message = list(
				"gently pushes %TARGET%'s face deep into their butt.",
				"carefully guides %TARGET%'s head into their ass, covering their face completely.",
				"lays %TARGET%'s face deep into their butt, a warm enveloping smother."
			)

	// Check for choke slut trait
	if(HAS_TRAIT(target, TRAIT_CHOKE_SLUT))
		target_arousal += 10
		target_pleasure += 6
		to_chat(target, span_purple("You can't breathe at all! It's so hot! You need more!"))

	. = ..()

/datum/interaction/lewd/butt_smother_deep/post_interaction(mob/living/user, mob/living/target)
	. = ..()
	var/stat_before = target.stat
	var/oxy_damage = 5
	// Always apply oxy damage up to 45
	if(target.get_oxy_loss() < 45)
		target.adjust_oxy_loss(oxy_damage)
	// Only apply additional damage if extmharm is enabled
	else if(user.client?.prefs?.read_preference(/datum/preference/choiced/erp_status_extmharm) != "No" || target.client?.prefs?.read_preference(/datum/preference/choiced/erp_status_extmharm) != "No")
		target.adjust_oxy_loss(oxy_damage)
	// Check if target just passed out
	if(target.stat == UNCONSCIOUS && stat_before != UNCONSCIOUS)
		message = list("%TARGET% passes out deep in %USER%'s butt.")
