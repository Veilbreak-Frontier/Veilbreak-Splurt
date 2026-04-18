/datum/power/tenacious
	name = "Tenacious"
	desc = "Try to remember some of the basics of CQC."
	is_accessible = FALSE
	power_traits = list(TRAIT_POWER_TENACIOUS)

/datum/power/prestidigitation
	name = "Prestidigitation"
	desc = "Allows a Sorcerous individual to perform magical tricks"
	root_power = /datum/power/prestidigitation
	power_type = TRAIT_PATH_SUBTYPE_THAUMATURGE
	is_accessible = FALSE

/datum/power/prestidigitation/add(mob/living/carbon/human/target)
	var/datum/action/new_action = new /datum/action/cooldown/spell/prestidigitation(target.mind || target)
	new_action.Grant(target)

/datum/power/meditate
	name = "Meditate"
	desc = "ooughhh im meditating"
	is_accessible = FALSE
	power_type = TRAIT_PATH_SUBTYPE_PSYKER

/datum/power/meditate/add(mob/living/carbon/human/target)
	var/datum/action/new_action = new /datum/action/cooldown/spell/meditate(target.mind || target)
	new_action.Grant(target)
