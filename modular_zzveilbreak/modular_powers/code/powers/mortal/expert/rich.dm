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

/// Attempts to grant starting credits for a rich-type power. Returns TRUE if granted.
/proc/try_grant_rich_power_credits(datum/power/power_source, mob/living/carbon/human/human_holder, amount)
	if(!power_source || !human_holder || power_source.riches_applied)
		return FALSE
	var/datum/bank_account/account = get_bank_account_for_rich_power(human_holder)
	if(!account)
		return FALSE
	account.adjust_money(amount, "Power: [power_source.name]")
	power_source.riches_applied = TRUE
	return TRUE

/datum/power/expert/rich
	name = "Rich"
	desc = "Whether through good savings, connections or just nepotism; you have way more spendable cash on hand than your peers. You start the shift with 2500 extra credits in your account."
	value = 5
	security_record_text = "Subject has access to a high amount of wealth and resources."
	/// how rich are we?
	var/riches = 2500
	/// Whether starting credits were already granted.
	var/riches_applied = FALSE

/datum/power/expert/rich/add_unique(client/client_source)
	var/mob/living/carbon/human/human_holder = power_holder
	if(try_grant_rich_power_credits(src, human_holder, riches))
		return
	if(!human_holder)
		return
	RegisterSignal(human_holder, COMSIG_HUMAN_CHARACTER_SETUP_FINISHED, PROC_REF(on_character_setup_finished))

/datum/power/expert/rich/proc/on_character_setup_finished(mob/living/carbon/human/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_HUMAN_CHARACTER_SETUP_FINISHED)
	try_grant_rich_power_credits(src, source, riches)

/datum/power/expert/rich/remove()
	if(power_holder)
		UnregisterSignal(power_holder, COMSIG_HUMAN_CHARACTER_SETUP_FINISHED)
	return ..()
