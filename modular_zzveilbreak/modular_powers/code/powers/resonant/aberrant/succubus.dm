// Succubus power class granting full Succubus antagonist status and abilities for 10 power points.
/datum/power/aberrant/succubus
	name = "Succubus"
	desc = "Embrace your demonic essence, becoming a Succubus. Grants all succubus abilities, allowing you to mark targets, subvert victims, and summon marked servants."
	security_record_text = "Subject displays supernatural demonic corruption and seduction tendencies."
	value = 10
	required_powers = list(/datum/power/aberrant_root)
	required_allow_subtypes = TRUE

	menu_icon = 'modular_zzveilbreak/icons/mob/succubus.dmi'
	menu_icon_state = "apply"

/datum/power/aberrant/succubus/add(client/client_source)
	apply_succubus()

/datum/power/aberrant/succubus/post_add()
	apply_succubus()
	. = ..()

/datum/power/aberrant/succubus/proc/apply_succubus()
	if(power_holder?.mind && !power_holder.mind.has_antag_datum(/datum/antagonist/succubus))
		power_holder.mind.add_antag_datum(/datum/antagonist/succubus)

/datum/power/aberrant/succubus/remove()
	if(power_holder?.mind)
		power_holder.mind.remove_antag_datum(/datum/antagonist/succubus)
