/*
	Screw the rules I have money.
*/

/proc/get_bank_account_for_rich_power(mob/living/carbon/human/human_holder)
	if(!human_holder)
		return null
	if(human_holder.account_id)
		return SSeconomy.bank_accounts_by_id["[human_holder.account_id]"]
	var/obj/item/card/id/id_card = human_holder.get_idcard()
	if(!id_card?.registered_account)
		return null
	if(!human_holder.account_id)
		human_holder.account_id = id_card.registered_account.account_id
	return id_card.registered_account

/datum/power/expert/rich
	name = "Rich"
	desc = "Whether through good savings, connections or just nepotism; you have way more spendable cash on hand than your peers. You start the shift with 2500 extra credits in your account."
	value = 5
	security_record_text = "Subject has access to a high amount of wealth and resources."
	// how rich are we?
	var/riches = 2500

/datum/power/expert/rich/add_unique(client/client_source)
	var/mob/living/carbon/human/human_holder = power_holder
	var/datum/bank_account/account = get_bank_account_for_rich_power(human_holder)
	if(!account)
		return
	account.account_balance += riches

