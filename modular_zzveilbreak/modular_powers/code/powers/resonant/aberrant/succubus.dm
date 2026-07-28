// Succubus power class granting full Succubus antagonist status and abilities for 10 power points.
/datum/power/void/succubus
	name = "Succubus"
	desc = "Embrace your demonic essence, becoming a Succubus. Grants all succubus abilities, allowing you to mark targets, subvert victims, and summon marked servants."
	security_record_text = "Subject displays supernatural demonic corruption and seduction tendencies."
	value = 10
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
	if(power_holder?.mind && !power_holder.mind.has_antag_datum(/datum/antagonist/succubus))
		power_holder.mind.add_antag_datum(/datum/antagonist/succubus)

/datum/power/void/succubus/remove()
	if(power_holder?.mind)
		power_holder.mind.remove_antag_datum(/datum/antagonist/succubus)

