// Succubus power class granting full Succubus antagonist status and abilities for 10 power points.
/datum/power/void/succubus
	name = "Succubus"
	desc = "Embrace your demonic essence, becoming a Succubus. Grants all succubus abilities, allowing you to mark targets, subvert victims, and summon marked servants."
	security_record_text = "Subject displays supernatural demonic corruption and seduction tendencies."
	value = 0
	archetype = POWER_ARCHETYPE_VOID
	path = POWER_PATH_VOID

	menu_icon = 'modular_zzveilbreak/icons/mob/succubus.dmi'
	menu_icon_state = "apply"

/datum/power/void/succubus/add(client/client_source)
	apply_succubus()

/datum/power/void/succubus/post_add()
	apply_succubus()
	. = ..()

/datum/power/void/succubus/proc/apply_succubus()
	if(!power_holder)
		return
	if(power_holder.mind)
		UnregisterSignal(power_holder, list(COMSIG_MOB_LOGIN, COMSIG_MOB_MIND_TRANSFERRED_INTO))
		if(!power_holder.mind.has_antag_datum(/datum/antagonist/succubus))
			power_holder.mind.add_antag_datum(/datum/antagonist/succubus)
	else
		RegisterSignal(power_holder, list(COMSIG_MOB_LOGIN, COMSIG_MOB_MIND_TRANSFERRED_INTO), PROC_REF(on_mind_gained))

/datum/power/void/succubus/proc/on_mind_gained(datum/source)
	SIGNAL_HANDLER
	apply_succubus()

/datum/power/void/succubus/remove()
	if(power_holder)
		UnregisterSignal(power_holder, list(COMSIG_MOB_LOGIN, COMSIG_MOB_MIND_TRANSFERRED_INTO))
		if(power_holder.mind)
			power_holder.mind.remove_antag_datum(/datum/antagonist/succubus)

