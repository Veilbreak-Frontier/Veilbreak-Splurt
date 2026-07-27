/datum/computer_file/program/civilianbounties/add_bounties(mob/user, cooldown_reduction = 0)
    var/datum/bank_account/id_account = computer.stored_id?.registered_account
    if(!id_account)
        return
    if((id_account.civilian_bounty || id_account.bounties) && !COOLDOWN_FINISHED(id_account, bounty_timer))
        var/time_left = DisplayTimeText(COOLDOWN_TIMELEFT(id_account, bounty_timer), round_seconds_to = 1)
        computer.balloon_alert(user, "try again in [time_left]!")
        return FALSE
    if(!computer.stored_id.trim)
        computer.say("Requesting ID card has no job assignment registered!")
        return FALSE
    var/list/datum/bounty/crumbs = computer.stored_id.trim.generate_bounty_list()
    COOLDOWN_START(id_account, bounty_timer, (5 MINUTES) - cooldown_reduction)
    id_account.bounties = crumbs
    return TRUE

/datum/computer_file/program/civilianbounties/pick_bounty(datum/bounty/choice)
    var/datum/bank_account/id_account = computer.stored_id?.registered_account
    if(!id_account?.bounties?[choice])
        playsound(computer.loc, 'sound/machines/synth/synth_no.ogg', 40, TRUE)
        return
    id_account.set_bounty(id_account.bounties[choice], computer.stored_id)
    id_account.bounties = null
    SSblackbox.record_feedback("tally", "bounties_assigned", 1, id_account.civilian_bounty.type)
    return id_account.civilian_bounty
