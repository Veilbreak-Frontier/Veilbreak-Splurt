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

/datum/power/expert/filthy_rich/add_unique(client/client_source)
	var/mob/living/carbon/human/human_holder = power_holder
	var/datum/bank_account/account = get_bank_account_for_rich_power(human_holder)
	if(!account)
		return
	account.account_balance += riches

