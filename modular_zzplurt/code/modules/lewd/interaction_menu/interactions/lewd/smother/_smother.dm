// Base type for smothering interactions
// These interactions involve restricting the target's breathing for pleasure
/datum/interaction/lewd/smother
	lewd = TRUE
	color = "pink"
	category = INTERACTION_CAT_LEWD
	/// Base oxygen damage applied per interaction
	var/oxy_damage = 3
	/// Whether this interaction requires the target's mouth to be free
	var/requires_target_mouth = TRUE

/datum/interaction/lewd/smother/allow_act(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE

	// Check if smothering is enabled in preferences
	if(!user.client?.prefs?.read_preference(/datum/preference/toggle/erp/smothering) && !(!ishuman(user) && !user.client && !SSinteractions.is_blacklisted(user)))
		return FALSE
	if(!target.client?.prefs?.read_preference(/datum/preference/toggle/erp/smothering) && !(!ishuman(target) && !target.client && !SSinteractions.is_blacklisted(target)))
		return FALSE

	return TRUE

/datum/interaction/lewd/smother/act(mob/living/user, mob/living/target)
	. = ..()

	// Apply oxygen damage if target can breathe
	if(!HAS_TRAIT(target, TRAIT_NOBREATH) && oxy_damage)
		// Check if target already has significant oxy loss - convert to RP only if so
		var/actual_damage = oxy_damage
		if(target.get_oxy_loss() > 40)
			actual_damage = 0

		if(actual_damage)
			target.apply_damage(actual_damage, OXY)

		// Apply arousal for choke sluts
		if(HAS_TRAIT(target, TRAIT_CHOKE_SLUT))
			target.adjust_arousal(oxy_damage * 2)

