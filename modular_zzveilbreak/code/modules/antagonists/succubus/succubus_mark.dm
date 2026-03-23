/// Tracks a succubus's mark on a victim. Stored globally by victim mind; level increases on orgasm.
/datum/succubus_mark
	/// Mind of the succubus who owns this mark
	var/datum/mind/owner_mind
	/// Mind of the victim
	var/datum/mind/victim_mind
	/// Current level (1 to SUCCUBUS_MARK_MAX_LEVEL)
	var/level = 1
	/// Subversion progress 0-100 (level 2 effect)
	var/subversion_progress = 0
	/// Lust tolerance multiplier applied (reduced per level from 3+)
	var/lust_tolerance_mult = 1.0
	/// Victim's original lust_tolerance before we modified it
	var/base_lust_tolerance = 1.0
	/// Choker item ref if we added one (level 4)
	var/obj/item/clothing/neck/succubus_choker/choker_ref
	/// Fluid multiplier we applied to organs (so we can revert)
	var/applied_fluid_mult = 1.0

/datum/succubus_mark/New(datum/mind/owner, datum/mind/victim)
	owner_mind = owner
	victim_mind = victim
	RegisterSignal(victim, COMSIG_MIND_TRANSFERRED, PROC_REF(on_victim_transfer))
	if(victim.current)
		RegisterSignal(victim.current, COMSIG_HUMAN_PERFORM_CLIMAX, PROC_REF(on_victim_climax))

/datum/succubus_mark/Destroy()
	UnregisterSignal(victim_mind, COMSIG_MIND_TRANSFERRED)
	if(victim_mind?.current)
		UnregisterSignal(victim_mind.current, COMSIG_HUMAN_PERFORM_CLIMAX)
	remove_all_effects()
	GLOB.succubus_marks_by_victim -= victim_mind
	if(owner_mind)
		var/datum/antagonist/succubus/S = owner_mind.has_antag_datum(/datum/antagonist/succubus)
		if(S)
			S.current_mark = null
	owner_mind = null
	victim_mind = null
	return ..()

/datum/succubus_mark/proc/on_victim_transfer(datum/mind/source, mob/old_current)
	SIGNAL_HANDLER
	if(old_current)
		UnregisterSignal(old_current, COMSIG_HUMAN_PERFORM_CLIMAX)
	if(victim_mind?.current)
		RegisterSignal(victim_mind.current, COMSIG_HUMAN_PERFORM_CLIMAX, PROC_REF(on_victim_climax))

/datum/succubus_mark/proc/on_victim_climax(mob/living/carbon/human/victim)
	SIGNAL_HANDLER
	if(level >= SUCCUBUS_MARK_MAX_LEVEL)
		return
	level_up()

/datum/succubus_mark/proc/level_up()
	var/old_level = level
	level = min(level + 1, SUCCUBUS_MARK_MAX_LEVEL)
	if(level == SUCCUBUS_MARK_MAX_LEVEL && old_level < SUCCUBUS_MARK_MAX_LEVEL && owner_mind)
		var/datum/antagonist/succubus/S = owner_mind.has_antag_datum(/datum/antagonist/succubus)
		if(S)
			S.has_reached_level5 = TRUE
	apply_effects_for_level(level)
	var/victim_name = victim_mind?.current?.name || "Someone"
	var/antag_name = owner_mind?.current?.name || "Succubus"
	notify_level_up(victim_name, antag_name, level)

/datum/succubus_mark/proc/notify_level_up(victim_name, antag_name, current_level)
	var/victim_msg = get_level_up_message_victim(victim_name, antag_name, current_level)
	var/antag_msg = get_level_up_message_antag(victim_name, antag_name, current_level)
	for(var/mob/M in GLOB.player_list)
		if(!M.client)
			continue
		if(M == victim_mind?.current && victim_msg)
			to_chat(M, span_pink(victim_msg))
		else if(M == owner_mind?.current && antag_msg)
			to_chat(M, span_pink(antag_msg))

/datum/succubus_mark/proc/get_level_up_message_victim(victim_name, antag_name, current_level)
	var/text = level_up_flavor_text_victim(current_level)
	text = replacetext(text, "%VICTIM%", victim_name)
	text = replacetext(text, "%ANTAG%", antag_name)
	text = replacetext(text, "%LEVEL%", "[current_level]")
	return text

/datum/succubus_mark/proc/get_level_up_message_antag(victim_name, antag_name, current_level)
	var/text = level_up_flavor_text_antag(current_level)
	text = replacetext(text, "%VICTIM%", victim_name)
	text = replacetext(text, "%ANTAG%", antag_name)
	text = replacetext(text, "%LEVEL%", "[current_level]")
	return text

/datum/succubus_mark/proc/level_up_flavor_text_victim(current_level)
	switch(current_level)
		if(1)
			return "The mark on your body burns with pleasure. You feel like your body is producing more fluids to satisfy '%ANTAG%''s desires."
		if(2)
			return "You want to resist, but your body betrays you. You want to just give in to the pleasure and climax, you feel like its easier to orgasm."
		if(3)
			return "You start questioning why you are resisting in the first place. Is being '%ANTAG%''s plaything such a bad idea? You feel like you cant resist this for much longer... "
		if(4)
			return "You now wear '%ANTAG%''s collar, doesnt look like it will come off until they decide to take it off. "
		if(5)
			return "The mark burns deeper into your body. Its too late for you now, you are at the mercy of '%ANTAG%'."
	return "%VICTIM% and %ANTAG% are bound deeper."

/datum/succubus_mark/proc/level_up_flavor_text_antag(current_level)
	switch(current_level)
		if(1)
			return "Your mark on %VICTIM% stirs with fresh pleasure. (Level %LEVEL%)"
		if(2)
			return "Your hold over %VICTIM% deepens as their resistance fades. (Level %LEVEL%)"
		if(3)
			return "You feel %VICTIM% growing more devoted to you. (Level %LEVEL%)"
		if(4)
			return "%VICTIM% now bears your collar. (Level %LEVEL%)"
		if(5)
			return "You can now summon %VICTIM% at will. (Level %LEVEL%)"
	return "Your bond with %VICTIM% deepens. (Level %LEVEL%)"

/datum/succubus_mark/proc/apply_effects_for_level(new_level)
	var/mob/living/carbon/human/victim = victim_mind?.current
	if(!istype(victim))
		return
	// Level 1: increased fluid production (cumulative: apply once and keep)
	if(new_level >= 1)
		apply_fluid_boost()
	// Level 2+: reduced lust tolerance (scales with level)
	if(new_level >= 2)
		apply_lust_tolerance_reduction()
	// Level 3: subversion starts (periodic tick via status effect)
	if(new_level == 3)
		apply_subversion_status()
	// Level 4+: unremovable choker
	if(new_level >= 4 && !choker_ref)
		apply_choker()

/datum/succubus_mark/proc/apply_fluid_boost()
	var/mob/living/carbon/human/victim = victim_mind?.current
	if(!istype(victim) || applied_fluid_mult > 1.0)
		return
	var/mult = SUCCUBUS_MARK_FLUID_MULTIPLIER
	applied_fluid_mult = mult
	for(var/slot in list(ORGAN_SLOT_TESTICLES, ORGAN_SLOT_VAGINA, ORGAN_SLOT_BREASTS))
		var/obj/item/organ/genital/O = victim.get_organ_slot(slot)
		if(O && O.internal_fluid_maximum > 0)
			O.internal_fluid_maximum = round(O.internal_fluid_maximum * mult)
			O.reagents?.maximum_volume = O.internal_fluid_maximum

/datum/succubus_mark/proc/remove_fluid_boost()
	var/mob/living/carbon/human/victim = victim_mind?.current
	if(!istype(victim) || applied_fluid_mult <= 1.0)
		return
	var/mult = applied_fluid_mult
	applied_fluid_mult = 1.0
	for(var/slot in list(ORGAN_SLOT_TESTICLES, ORGAN_SLOT_VAGINA, ORGAN_SLOT_BREASTS))
		var/obj/item/organ/genital/O = victim.get_organ_slot(slot)
		if(O && O.internal_fluid_maximum > 0)
			O.internal_fluid_maximum = max(1, round(O.internal_fluid_maximum / mult))
			O.reagents?.maximum_volume = O.internal_fluid_maximum

/datum/succubus_mark/proc/apply_lust_tolerance_reduction()
	var/mob/living/carbon/human/victim = victim_mind?.current
	if(!ishuman(victim) || !victim.dna?.features || level < 2)
		return
	if(base_lust_tolerance <= 0)
		base_lust_tolerance = victim.dna.features["lust_tolerance"] || 1.0
	// Reduce lust tolerance by level (level 2 = 0.92, 3 = 0.84, 4 = 0.76, 5 = 0.68)
	var/reduction = (level - 1) * SUCCUBUS_MARK_LUST_TOLERANCE_REDUCTION_PER_LEVEL
	lust_tolerance_mult = 1.0 - reduction
	victim.dna.features["lust_tolerance"] = base_lust_tolerance * lust_tolerance_mult

/datum/succubus_mark/proc/remove_lust_tolerance_reduction()
	var/mob/living/carbon/human/victim = victim_mind?.current
	if(!ishuman(victim) || !victim.dna?.features)
		return
	victim.dna.features["lust_tolerance"] = base_lust_tolerance
	lust_tolerance_mult = 1.0
	base_lust_tolerance = 1.0

/datum/succubus_mark/proc/apply_choker()
	var/mob/living/carbon/human/victim = victim_mind?.current
	if(!istype(victim) || choker_ref)
		return
	var/obj/item/clothing/neck/succubus_choker/choker = new(victim)
	choker.mark_datum = src
	choker.victim_name = victim.name
	choker.antag_name = owner_mind?.current?.name || "Succubus"
	choker.update_choker_text()
	victim.equip_to_slot_if_possible(choker, ITEM_SLOT_NECK, disable_warning = TRUE)
	choker_ref = choker

/datum/succubus_mark/proc/apply_subversion_status()
	var/mob/living/carbon/human/victim = victim_mind?.current
	if(!istype(victim))
		return
	victim.apply_status_effect(/datum/status_effect/succubus_subversion, src)

/datum/succubus_mark/proc/remove_choker()
	if(choker_ref)
		if(choker_ref.loc)
			choker_ref.mark_datum = null
			qdel(choker_ref)
		choker_ref = null

/datum/succubus_mark/proc/remove_all_effects()
	remove_fluid_boost()
	remove_lust_tolerance_reduction()
	remove_choker()
	var/mob/living/carbon/human/victim = victim_mind?.current
	if(istype(victim))
		victim.remove_status_effect(/datum/status_effect/succubus_subversion)
