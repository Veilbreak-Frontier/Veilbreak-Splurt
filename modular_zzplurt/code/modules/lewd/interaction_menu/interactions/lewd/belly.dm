/datum/interaction/lewd/bellyfuck
	name = "Bellyfuck"
	description = "Fuck their belly."
	interaction_requires = list(INTERACTION_REQUIRE_TARGET_TOPLESS)
	user_required_parts = list(ORGAN_SLOT_PENIS = REQUIRE_GENITAL_EXPOSED)
	cum_genital = list(CLIMAX_POSITION_USER = CLIMAX_PENIS)
	cum_message_text_overrides = list(CLIMAX_POSITION_USER = list(
		"%CUMMING% cums all over %CAME_IN%'s belly",
		"%CUMMING% shoots their load onto %CAME_IN%'s stomach",
		"%CUMMING% covers %CAME_IN%'s navel in cum"
	))
	cum_self_text_overrides = list(CLIMAX_POSITION_USER = list(
		"You cum all over %CAME_IN%'s belly",
		"You shoot your load onto %CAME_IN%'s stomach",
		"You cover %CAME_IN%'s navel in cum"
	))
	cum_partner_text_overrides = list(CLIMAX_POSITION_USER = list(
		"%CUMMING% cums all over your belly",
		"%CUMMING% shoots their load onto your stomach",
		"%CUMMING% covers your navel in cum"
	))
	message = list(
		"rubs their cock against %TARGET%'s belly",
		"fucks %TARGET%'s navel",
		"grinds their cock on %TARGET%'s stomach",
		"thrusts against %TARGET%'s belly"
	)
	user_messages = list(
		"You feel %TARGET%'s warm skin against your cock",
		"The softness of %TARGET%'s belly feels good against your shaft",
		"%TARGET%'s belly feels amazing against your cock"
	)
	target_messages = list(
		"You feel %USER%'s cock rubbing against your belly",
		"%USER%'s shaft slides across your stomach",
		"The warmth of %USER%'s cock presses against your navel"
	)
	sound_possible = list(
		'modular_zzplurt/sound/interactions/bang1.ogg',
		'modular_zzplurt/sound/interactions/bang2.ogg',
		'modular_zzplurt/sound/interactions/bang3.ogg'
	)
	sound_range = 1
	sound_use = TRUE
	user_pleasure = 3
	target_pleasure = 0
	user_arousal = 5
	target_arousal = 2

/datum/interaction/lewd/nuzzle_belly
	name = "Nuzzle Belly"
	description = "Nuzzle their belly."
	interaction_requires = list(INTERACTION_REQUIRE_TARGET_TOPLESS)
	message = list(
		"nuzzles %TARGET%'s belly",
		"rubs their face against %TARGET%'s stomach",
		"presses their cheek to %TARGET%'s navel",
		"snuggles against %TARGET%'s tummy"
	)
	user_messages = list(
		"You feel %TARGET%'s warm skin against your face",
		"The softness of %TARGET%'s belly feels nice against your cheek",
		"%TARGET%'s stomach is warm and inviting"
	)
	target_messages = list(
		"You feel %USER%'s face nuzzling your belly",
		"%USER%'s cheek rubs softly against your stomach",
		"The warmth of %USER%'s face presses against your navel"
	)
	sound_possible = list(
		'modular_zzplurt/sound/interactions/thudswoosh.ogg'
	)
	sound_range = 1
	sound_use = TRUE
	user_pleasure = 0
	target_pleasure = 0
	user_arousal = 2
	target_arousal = 3

/datum/interaction/lewd/deflate_belly
	name = "Deflate Belly"
	description = "Deflate belly."
	user_required_parts = list(ORGAN_SLOT_BELLY = REQUIRE_GENITAL_ANY)
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HUMAN)
	usage = INTERACTION_SELF
	message = list(
		"deflates their belly",
		"lets out air from their belly",
		"makes their belly smaller"
	)
	sound_range = 1
	sound_use = FALSE
	user_pleasure = 0
	user_arousal = 0

/datum/interaction/lewd/deflate_belly/post_interaction(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	var/obj/item/organ/genital/belly/gut = user.get_organ_slot(ORGAN_SLOT_BELLY)
	if(gut)
		gut.set_size(max(gut.genital_size - 1, BELLY_MIN_SIZE))
		user.update_body()

/datum/interaction/lewd/inflate_belly
	name = "Inflate Belly"
	description = "Inflate belly."
	user_required_parts = list(ORGAN_SLOT_BELLY = REQUIRE_GENITAL_ANY)
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HUMAN)
	usage = INTERACTION_SELF
	message = list(
		"inflates their belly",
		"makes their belly bigger",
		"expands their belly"
	)
	sound_range = 1
	sound_use = FALSE
	user_pleasure = 0
	user_arousal = 0

/datum/interaction/lewd/inflate_belly/post_interaction(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	var/obj/item/organ/genital/belly/gut = user.get_organ_slot(ORGAN_SLOT_BELLY)
	if(gut)
		gut.set_size(min(gut.genital_size + 1, BELLY_MAX_SIZE))
		user.update_body()

// Belly smothering interactions - smother target's face with belly
/datum/interaction/lewd/belly_smother
	name = "Belly Smother"
	description = "Smother their face with your belly. (Warning: Causes oxygen damage)"
	interaction_requires = list(INTERACTION_REQUIRE_TARGET_MOUTH)
	user_required_parts = list(ORGAN_SLOT_BELLY = REQUIRE_GENITAL_ANY)
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

/datum/interaction/lewd/belly_smother/act(mob/living/user, mob/living/target)
	message = null
	target_arousal = 6
	target_pleasure = 4
	user_arousal = 4
	user_pleasure = 4

	switch(resolve_intent_name(user))
		if("harm")
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
		else
			message = list(
				"gently lowers their belly onto %TARGET%'s face.",
				"carefully covers %TARGET%'s face with their belly.",
				"lays their belly over %TARGET%'s nose and mouth."
			)

	if(HAS_TRAIT(target, TRAIT_CHOKE_SLUT))
		target_arousal += 6
		target_pleasure += 4
		to_chat(target, span_purple("The weight on your face is overwhelming... and so hot!"))

	. = ..()

/datum/interaction/lewd/belly_smother/post_interaction(mob/living/user, mob/living/target)
	. = ..()
	if(user.client?.prefs?.read_preference(/datum/preference/choiced/erp_status_extmharm) != "No" || target.client?.prefs?.read_preference(/datum/preference/choiced/erp_status_extmharm) != "No")
		var/stat_before = target.stat
		target.adjust_oxy_loss(3)
		if(target.stat == UNCONSCIOUS && stat_before != UNCONSCIOUS)
			message = list("%TARGET% passes out under %USER%'s belly.")

/datum/interaction/lewd/belly_sit
	name = "Sit on Belly"
	description = "Sit on your partner's face using your belly. (Warning: Causes oxygen damage)"
	interaction_requires = list(INTERACTION_REQUIRE_TARGET_MOUTH)
	user_required_parts = list(ORGAN_SLOT_BELLY = REQUIRE_GENITAL_ANY)
	target_arousal = 4
	target_pleasure = 6
	target_pain = 0
	user_arousal = 6
	user_pleasure = 4
	user_pain = 0
	sound_possible = list(
		'modular_zzplurt/sound/interactions/squelch1.ogg',
		'modular_zzplurt/sound/interactions/squelch2.ogg'
	)
	sound_range = 1
	sound_use = TRUE

/datum/interaction/lewd/belly_sit/act(mob/living/user, mob/living/target)
	message = null
	target_arousal = 4
	target_pleasure = 6
	user_arousal = 6
	user_pleasure = 4

	switch(resolve_intent_name(user))
		if("harm")
			target_pain = 4
			message = list(
				"drops their heavy belly onto %TARGET%'s face, crushing them.",
				"presses their full belly weight onto %TARGET%'s face, smothering them.",
				"uses %TARGET%'s face as a seat, pressing down hard."
			)
		if("grab")
			target_arousal += 2
			target_pleasure += 2
			user_arousal += 2
			message = list(
				"pulls %TARGET%'s face into their belly, pressing down.",
				"wraps their legs around %TARGET%'s head and settles their weight.",
				"presses their belly against %TARGET%'s face."
			)
		else
			message = list(
				"gently lowers their belly onto %TARGET%'s face.",
				"carefully sits on %TARGET%'s face with their belly.",
				"positions their belly over %TARGET%'s face comfortably."
			)

	if(HAS_TRAIT(target, TRAIT_CHOKE_SLUT))
		target_arousal += 6
		target_pleasure += 4
		to_chat(target, span_purple("Your face is trapped under their weight... you can't get enough air... but it's amazing!"))

	. = ..()

/datum/interaction/lewd/belly_sit/post_interaction(mob/living/user, mob/living/target)
	. = ..()
	if(user.client?.prefs?.read_preference(/datum/preference/choiced/erp_status_extmharm) != "No" || target.client?.prefs?.read_preference(/datum/preference/choiced/erp_status_extmharm) != "No")
		var/stat_before = target.stat
		target.adjust_oxy_loss(2)
		if(target.stat == UNCONSCIOUS && stat_before != UNCONSCIOUS)
			message = list("%TARGET% passes out under %USER%'s belly.")
