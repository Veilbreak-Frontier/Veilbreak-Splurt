/// Succubus antagonist: hunts for fluids, can mark a target. Mark persists until removed.
/// No hard-coded sprites - can be given to anyone.
/datum/antagonist/succubus
	name = "Succubus"
	roundend_category = "succubi"
	antagpanel_category = ANTAG_GROUP_CREW
	show_in_antagpanel = TRUE
	show_name_in_check_antagonists = TRUE
	pref_flag = ROLE_SUCCUBUS
	antag_hud_name = "succubus"
	antag_flags = ANTAG_SKIP_GLOBAL_LIST
	/// Current marked victim (one at a time); null if none
	var/datum/succubus_mark/current_mark
	/// Set to TRUE once any of your marks reaches level 5 at least once
	var/has_reached_level5 = FALSE

/datum/antagonist/succubus/on_gain()
	setup_succubus_objectives()
	. = ..()
	grant_mark_abilities()

/datum/antagonist/succubus/on_removal()
	remove_mark_abilities()
	if(current_mark)
		qdel(current_mark)
		current_mark = null
	. = ..()

/datum/antagonist/succubus/on_body_transfer(mob/living/old_body, mob/living/new_body)
	. = ..()
	remove_mark_abilities()
	grant_mark_abilities()

/datum/antagonist/succubus/proc/grant_mark_abilities()
	var/mob/living/L = owner?.current
	if(!L)
		return
	var/datum/action/innate/succubus_mark/MA = new(src)
	MA.Grant(L)
	var/datum/action/innate/succubus_remove_mark/RM = new(src)
	RM.Grant(L)
	var/datum/action/innate/succubus_summon_victim/SV = new(src)
	SV.Grant(L)

/datum/antagonist/succubus/proc/remove_mark_abilities()
	var/mob/living/L = owner?.current
	if(!L)
		return
	for(var/datum/action/innate/succubus_mark/A in L.actions)
		A.Remove(L)
	for(var/datum/action/innate/succubus_remove_mark/A in L.actions)
		A.Remove(L)
	for(var/datum/action/innate/succubus_summon_victim/A in L.actions)
		A.Remove(L)

/datum/antagonist/succubus/admin_add(datum/mind/new_owner, mob/admin)
	. = ..()
	message_admins("[key_name_admin(admin)] made [key_name_admin(new_owner)] into [name].")
	log_admin("[key_name(admin)] made [key_name(new_owner)] into [name].")

/datum/antagonist/succubus/greet()
	. = ..()
	to_chat(owner.current, span_purple("You are a succubus, hungering for fluids. Mark a target to feed on their pleasure; each time they orgasm, your mark becomes stronger."))
	owner.announce_objectives()

/datum/antagonist/succubus/roundend_report()
	var/list/report = list()
	report += "[printplayer(owner)]"
	if(current_mark)
		report += "Had marked [current_mark.victim_mind?.name || "a victim"] (Level [current_mark.level])."
	else
		report += "Had no active mark."
	return report.Join("<br>")

/// Succubus objectives

/datum/antagonist/succubus/proc/setup_succubus_objectives()
	var/datum/objective/succubus_level5/level5 = new
	level5.owner = owner
	objectives += level5

	var/datum/objective/succubus_servant_alive/servant = new
	servant.owner = owner
	objectives += servant

	for(var/datum/objective/O in objectives)
		O.update_explanation_text()

/// Reach mark level 5 at least once
/datum/objective/succubus_level5
	name = "Deepen your mark"

/datum/objective/succubus_level5/update_explanation_text()
	explanation_text = "Cause your mark to reach level [SUCCUBUS_MARK_MAX_LEVEL] at least once."

/datum/objective/succubus_level5/check_completion()
	var/datum/antagonist/succubus/S = owner.has_antag_datum(/datum/antagonist/succubus)
	if(!S)
		return FALSE
	return S.has_reached_level5

/// Have a fully subverted servant alive and still serving at round end
/datum/objective/succubus_servant_alive
	name = "Keep your servant"

/datum/objective/succubus_servant_alive/update_explanation_text()
	explanation_text = "Ensure at least one fully subverted marked servant is alive and still serving you at the end of the shift."

/datum/objective/succubus_servant_alive/check_completion()
	var/datum/antagonist/succubus/S = owner.has_antag_datum(/datum/antagonist/succubus)
	if(!S)
		return FALSE

	for(var/datum/succubus_mark/mark as anything in GLOB.succubus_marks_by_victim)
		if(!mark || mark.owner_mind != owner)
			continue
		if(mark.subversion_progress < 100)
			continue
		var/mob/living/carbon/human/victim = mark.victim_mind?.current
		if(!victim || victim.stat == DEAD)
			continue
		if(!HAS_TRAIT(victim, TRAIT_SUCCUBUS_SERVANT))
			continue
		return TRUE

	return FALSE
