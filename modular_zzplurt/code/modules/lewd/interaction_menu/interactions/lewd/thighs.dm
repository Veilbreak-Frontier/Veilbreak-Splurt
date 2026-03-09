/datum/interaction/lewd/thighs_penis
	name = "Thigh Smother (Penis)"
	description = "Smother them with your penis."
	interaction_requires = list(INTERACTION_REQUIRE_TARGET_MOUTH)
	user_required_parts = list(ORGAN_SLOT_PENIS = REQUIRE_GENITAL_EXPOSED)
	cum_genital = list(CLIMAX_POSITION_USER = CLIMAX_PENIS)
	cum_target = list(CLIMAX_POSITION_USER = CLIMAX_TARGET_MOUTH)
	message = list(
		null
		)
	sound_possible = list(
		'modular_zzplurt/sound/interactions/bj10.ogg',
		'modular_zzplurt/sound/interactions/bj3.ogg',
		'modular_zzplurt/sound/interactions/foot_wet1.ogg',
		'modular_zzplurt/sound/interactions/foot_dry3.ogg'
	)
	sound_range = 1
	sound_use = TRUE
	user_pleasure = 4
	target_pleasure = 0
	user_arousal = 6
	target_arousal = 2

/datum/interaction/lewd/thighs_penis/allow_act(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE

	// Check if smothering is enabled in preferences
	if(!user.client?.prefs?.read_preference(/datum/preference/toggle/erp/smothering) && !(!ishuman(user) && !user.client && !SSinteractions.is_blacklisted(user)))
		return FALSE
	if(!target.client?.prefs?.read_preference(/datum/preference/toggle/erp/smothering) && !(!ishuman(target) && !target.client && !SSinteractions.is_blacklisted(target)))
		return FALSE

	return TRUE

/datum/interaction/lewd/thighs_penis/act(mob/living/user, mob/living/target)

 // this will change variables depending on intent. Experimental system, if people like it we can add it to the rest of interactions in the future.


	switch(resolve_intent_name(user))
		if("harm")
			target_pain = 3
			message = list(
				"grinds their hips down hard onto %TARGET%'s face, crushing their nose.",
				"presses their full weight onto %TARGET%'s face, blocking their airways.",
				"forces %TARGET%'s face into their crotch, smothering them completely."
			)
		if("grab")
			target_arousal += 3
			target_pleasure += 2
			user_arousal += 2
			message = list(
				"wraps their legs around %TARGET%'s head and pulls them into their crotch.",
				"presses their thighs tight against %TARGET%'s face, smothering them.",
				"grinds their groin into %TARGET%'s face, blocking their airways."
			)
		else // help
			message = list(
				"presses their weight down onto %TARGET%'s face, blocking their vision completely.",
				"gently lowers their hips onto %TARGET%'s face.",
				"carefully covers %TARGET%'s nose and mouth with their thighs."
			)

	// Check for choke slut trait
	if(HAS_TRAIT(target, TRAIT_CHOKE_SLUT))
		target_arousal += 8
		target_pleasure += 4
		to_chat(target, span_purple("You can barely breathe with their thighs on your face... it's incredible!"))

	. = ..()

/datum/interaction/lewd/thighs_penis/post_interaction(mob/living/user, mob/living/target)
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
		message = list("%TARGET% passes out under %USER%'s thighs.")


/datum/interaction/lewd/thighs_vagina
	name = "Thigh Smother (Vagina)"
	description = "Smother them with your pussy."
	interaction_requires = list(INTERACTION_REQUIRE_TARGET_MOUTH)
	user_required_parts = list(ORGAN_SLOT_VAGINA = REQUIRE_GENITAL_EXPOSED)
	cum_genital = list(CLIMAX_POSITION_USER = CLIMAX_VAGINA)
	cum_target = list(CLIMAX_POSITION_USER = CLIMAX_TARGET_MOUTH)
	message = null
	sound_possible = list(
		'modular_zzplurt/sound/interactions/bj10.ogg',
		'modular_zzplurt/sound/interactions/bj3.ogg',
		'modular_zzplurt/sound/interactions/foot_wet1.ogg',
		'modular_zzplurt/sound/interactions/foot_dry3.ogg'
	)
	sound_range = 1
	sound_use = TRUE
	user_pleasure = 4
	target_pleasure = 0
	user_arousal = 6
	target_arousal = 2

/datum/interaction/lewd/thighs_vagina/allow_act(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE

	// Check if smothering is enabled in preferences
	if(!user.client?.prefs?.read_preference(/datum/preference/toggle/erp/smothering) && !(!ishuman(user) && !user.client && !SSinteractions.is_blacklisted(user)))
		return FALSE
	if(!target.client?.prefs?.read_preference(/datum/preference/toggle/erp/smothering) && !(!ishuman(target) && !target.client && !SSinteractions.is_blacklisted(target)))
		return FALSE

	return TRUE

/datum/interaction/lewd/thighs_vagina/act(mob/living/user, mob/living/target)
// same system from above. Will join them into one with a parent switch case, or at least I'll try.
	switch(resolve_intent_name(user))
		if("harm")
			target_pain = 3
			message = list(
				"grinds their hips down hard onto %TARGET%'s face, crushing their nose.",
				"presses their full weight onto %TARGET%'s face, blocking their airways.",
				"forces %TARGET%'s face into their crotch, smothering them completely."
			)
		if("grab")
			target_arousal += 3
			target_pleasure += 2
			user_arousal += 2
			message = list(
				"wraps their legs around %TARGET%'s head and pulls them into their crotch.",
				"presses their thighs tight against %TARGET%'s face, smothering them.",
				"grinds their wet pussy into %TARGET%'s face, blocking their airways."
			)
		else // help
			message = list(
				"presses their weight down onto %TARGET%'s face, blocking their vision completely.",
				"rides %TARGET%'s face, grinding their wet pussy all over it.",
				"grinds their pussy into %TARGET%'s face."
			)

	// Check for choke slut trait (I dont think I can modularize this with my skills lowkey)
	if(HAS_TRAIT(target, TRAIT_CHOKE_SLUT))
		target_arousal += 8
		target_pleasure += 4
		to_chat(target, span_purple("You can barely breathe with their thighs on your face... it's incredible!"))

	. = ..()

/datum/interaction/lewd/thighs_vagina/post_interaction(mob/living/user, mob/living/target)
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
		message = list("%TARGET% passes out under %USER%'s thighs.")


/datum/interaction/lewd/thighfuck
	name = "Thighfuck"
	description = "Fuck their thighs."
	interaction_requires = list(INTERACTION_REQUIRE_TARGET_BOTTOMLESS)
	user_required_parts = list(ORGAN_SLOT_PENIS = REQUIRE_GENITAL_EXPOSED)
	cum_genital = list(CLIMAX_POSITION_USER = CLIMAX_PENIS)
	cum_message_text_overrides = list(CLIMAX_POSITION_USER = list(
		"%CUMMING% cums all over %CAME_IN%'s thighs",
		"%CUMMING% shoots their load onto %CAME_IN%'s legs",
		"%CUMMING% covers %CAME_IN%'s thighs in cum"
	))
	cum_self_text_overrides = list(CLIMAX_POSITION_USER = list(
		"You cum all over %CAME_IN%'s thighs",
		"You shoot your load onto %CAME_IN%'s legs",
		"You cover %CAME_IN%'s thighs in cum"
	))
	cum_partner_text_overrides = list(CLIMAX_POSITION_USER = list(
		"%CUMMING% cums all over your thighs",
		"%CUMMING% shoots their load onto your legs",
		"%CUMMING% covers your thighs in cum"
	))
	message = list(
		"fucks %TARGET%'s thighs",
		"slides their cock between %TARGET%'s legs",
		"thrusts between %TARGET%'s thighs",
		"pounds against %TARGET%'s legs"
	)
	user_messages = list(
		"You feel %TARGET%'s thighs squeezing your cock",
		"The warmth between %TARGET%'s legs feels amazing",
		"%TARGET%'s soft thighs feel great around your shaft"
	)
	target_messages = list(
		"You feel %USER%'s cock sliding between your thighs",
		"%USER%'s shaft rubs between your legs",
		"The warmth of %USER%'s cock presses against your thighs"
	)
	sound_possible = list(
		'modular_zzplurt/sound/interactions/bang1.ogg',
		'modular_zzplurt/sound/interactions/bang2.ogg',
		'modular_zzplurt/sound/interactions/bang3.ogg'
	)
	sound_range = 1
	sound_use = TRUE
	user_pleasure = 4
	target_pleasure = 0
	user_arousal = 6
	target_arousal = 4

/datum/interaction/lewd/thighjob
	name = "Give Thighjob"
	description = "Pleasure them with your thighs."
	interaction_requires = list(INTERACTION_REQUIRE_SELF_BOTTOMLESS)
	target_required_parts = list(ORGAN_SLOT_PENIS = REQUIRE_GENITAL_EXPOSED)
	cum_genital = list(CLIMAX_POSITION_TARGET = CLIMAX_PENIS)
	cum_message_text_overrides = list(CLIMAX_POSITION_TARGET = list(
		"%CUMMING% cums all over %CAME_IN%'s thighs",
		"%CUMMING% shoots their load onto %CAME_IN%'s legs",
		"%CUMMING% covers %CAME_IN%'s thighs in cum"
	))
	cum_self_text_overrides = list(CLIMAX_POSITION_TARGET = list(
		"%CUMMING% cums all over your thighs",
		"%CUMMING% shoots their load onto your legs",
		"%CUMMING% covers your thighs in cum"
	))
	cum_partner_text_overrides = list(CLIMAX_POSITION_TARGET = list(
		"You cum all over %CAME_IN%'s thighs",
		"You shoot your load onto %CAME_IN%'s legs",
		"You cover %CAME_IN%'s thighs in cum"
	))
	message = list(
		"squeezes %TARGET%'s cock between their thighs",
		"works %TARGET%'s shaft with their legs",
		"pleasures %TARGET% with their thighs",
		"rubs %TARGET%'s cock between their legs"
	)
	user_messages = list(
		"You feel %TARGET%'s cock throbbing between your thighs",
		"The warmth of %TARGET%'s shaft feels nice between your legs",
		"You squeeze %TARGET%'s cock with your thighs"
	)
	target_messages = list(
		"%USER%'s warm thighs squeeze your cock",
		"Your shaft slides between %USER%'s legs",
		"The softness of %USER%'s thighs feels amazing"
	)
	sound_possible = list(
		'modular_zzplurt/sound/interactions/bang1.ogg',
		'modular_zzplurt/sound/interactions/bang2.ogg',
		'modular_zzplurt/sound/interactions/bang3.ogg'
	)
	sound_range = 1
	sound_use = TRUE
	user_pleasure = 0
	target_pleasure = 4
	user_arousal = 4
	target_arousal = 6
