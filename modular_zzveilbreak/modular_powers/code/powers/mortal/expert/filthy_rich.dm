/*
	Screw the rules I have EVEN MORE money.
	Why are you even on this ship if you make this much bank.
*/

/datum/power/expert/filthy_rich
	name = "Filthy Rich"
	desc = "With this much disposable money it's even a question as to why you even work anymore. You start with 10000 extra credits (includes the amount from being Rich already). And probably tons more in off-shore savings accounts."
	security_record_text = "Subject has an exorbant amount of wealth and resources at their disposal."
	value = 8
	required_powers = list(/datum/power/expert/rich)

	// we just make it the same as rich but reduced because we are lazy.
	var/riches = 7500
	var/riches_applied = FALSE

/datum/power/expert/filthy_rich/add_unique(client/client_source)
	var/mob/living/carbon/human/human_holder = power_holder
	if(try_grant_rich_power_credits(src, human_holder, riches))
		return
	if(!human_holder)
		return
	RegisterSignal(human_holder, COMSIG_HUMAN_CHARACTER_SETUP_FINISHED, PROC_REF(on_character_setup_finished))

/datum/power/expert/filthy_rich/proc/on_character_setup_finished(mob/living/carbon/human/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_HUMAN_CHARACTER_SETUP_FINISHED)
	try_grant_rich_power_credits(src, source, riches)

/datum/power/expert/filthy_rich/remove()
	if(power_holder)
		UnregisterSignal(power_holder, COMSIG_HUMAN_CHARACTER_SETUP_FINISHED)
	return ..()
