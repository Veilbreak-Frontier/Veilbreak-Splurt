/// Mark a living human as your target. Only one mark at a time.
/datum/action/innate/succubus_mark
	name = "Mark Target"
	desc = "Mark a target to feed on their pleasure. Their orgasms will strengthen the bond."
	button_icon = 'modular_zzveilbreak/icons/mob/succubus.dmi'
	button_icon_state = "apply"
	background_icon_state = "bg_default"

/datum/action/innate/succubus_mark/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	var/datum/antagonist/succubus/S = target
	if(!istype(S) || !owner)
		return
	if(S.current_mark)
		to_chat(owner, span_warning("You already have a mark. Remove it first."))
		return
	var/mob/living/carbon/human/victim = input(owner, "Choose a target to mark.", "Mark Target") as null|mob in view(1, owner)
	if(!victim || !istype(victim) || victim == owner)
		return
	if(!victim.mind)
		to_chat(owner, span_warning("[victim] has no mind to mark."))
		return
	if(victim.mind.has_antag_datum(/datum/antagonist/succubus))
		to_chat(owner, span_warning("You cannot mark another succubus."))
		return
	if(GLOB.succubus_marks_by_victim[victim.mind])
		to_chat(owner, span_warning("[victim] is already marked by another."))
		return
	var/datum/succubus_mark/mark = new(S.owner, victim.mind)
	GLOB.succubus_marks_by_victim[victim.mind] = mark
	S.current_mark = mark
	mark.apply_effects_for_level(1)
	to_chat(owner, span_pink("You mark [victim.name]. Their pleasure will feed your bond."))
	to_chat(victim, span_pink("You feel a subtle warmth; you have been marked."))

/// Remove your mark from the current victim.
/datum/action/innate/succubus_remove_mark
	name = "Remove Mark"
	desc = "Remove your mark from the current victim."
	button_icon = 'modular_zzveilbreak/icons/mob/succubus.dmi'
	button_icon_state = "remove"

/datum/action/innate/succubus_remove_mark/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	var/datum/antagonist/succubus/S = target
	if(!istype(S) || !S.current_mark)
		to_chat(owner, span_warning("You have no mark to remove."))
		return
	var/datum/succubus_mark/M = S.current_mark
	var/victim_name = M.victim_mind?.current?.name || "your victim"
	qdel(M)
	to_chat(owner, span_pink("You remove your mark from [victim_name]."))

/// Summon marked victim to your location (level 5 only). Puts them one tile away.
/datum/action/innate/succubus_summon_victim
	name = "Summon Victim"
	desc = "Teleport your marked victim to your location (one tile away). Requires mark level 5."
	button_icon = 'modular_zzveilbreak/icons/mob/succubus.dmi'
	button_icon_state = "transfer"

/datum/action/innate/succubus_summon_victim/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE
	var/datum/antagonist/succubus/S = target
	return S?.current_mark && S.current_mark.level >= SUCCUBUS_MARK_MAX_LEVEL

/datum/action/innate/succubus_summon_victim/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	var/datum/antagonist/succubus/S = target
	if(!istype(S) || !S.current_mark)
		to_chat(owner, span_warning("You have no mark."))
		return
	if(S.current_mark.level < SUCCUBUS_MARK_MAX_LEVEL)
		to_chat(owner, span_warning("Your mark must reach level [SUCCUBUS_MARK_MAX_LEVEL] to summon."))
		return
	var/mob/living/victim = S.current_mark.victim_mind?.current
	if(!victim)
		to_chat(owner, span_warning("Your victim is not in the world."))
		return
	var/turf/T = get_turf(owner)
	if(!T)
		return
	var/turf/target_turf = get_step(T, get_dir(victim, owner)) || T
	if(target_turf == T)
		target_turf = get_step(T, pick(GLOB.cardinals))
	if(!target_turf)
		target_turf = T
	do_teleport(victim, target_turf, null, null, null, null, null, TRUE)
	to_chat(owner, span_pink("You summon [victim.name] to you."))
	to_chat(victim, span_pink("You are pulled through space to [owner]."))
