#define CHOICE_TRANSFER "Initiate Crew Transfer"
#define CHOICE_CONTINUE "Continue Playing"

/datum/vote/transfer_vote
	name = "Transfer"
	default_choices = list(
		CHOICE_TRANSFER,
		CHOICE_CONTINUE,
	)
	default_message = "Vote to initiate a crew transfer."

/datum/vote/transfer_vote/toggle_votable()
	CONFIG_SET(flag/allow_vote_transfer, !CONFIG_GET(flag/allow_vote_transfer))

/datum/vote/transfer_vote/is_config_enabled()
	return CONFIG_GET(flag/autotransfer) && CONFIG_GET(flag/allow_vote_transfer)

/datum/vote/transfer_vote/can_be_initiated(forced)
	. = ..()
	if(. != VOTE_AVAILABLE)
		return .

	if(forced)
		return VOTE_AVAILABLE

	if(!CONFIG_GET(flag/autotransfer) || !CONFIG_GET(flag/allow_vote_transfer))
		return "Transfer voting is disabled."

	return VOTE_AVAILABLE

/datum/vote/transfer_vote/finalize_vote(winning_option)
	if(winning_option != CHOICE_CONTINUE && winning_option != CHOICE_TRANSFER)
		CRASH("[type] wasn't passed a valid winning choice. (Got: [winning_option || "null"])")

	if(winning_option == CHOICE_TRANSFER)
		SSshuttle.autoEnd()
		var/obj/machinery/computer/communications/comms_console = locate() in GLOB.shuttle_caller_list
		if(comms_console)
			comms_console.post_status("shuttle")

	var/total_clients = 0
	var/in_round = 0
	var/observers = 0

	for(var/client/C in GLOB.clients)
		total_clients++
		if(!C.mob)
			observers++
			continue
		if(isobserver(C.mob))
			observers++
		else
			in_round++

	var/status_emoji = (winning_option == CHOICE_CONTINUE) ? "🔄" : "🚀"
	var/duration_text = "00:00:00"
	var/datum/controller/subsystem/ticker/T = SSticker

	if(T && T.round_start_time)
		var/elapsed_time = world.time - T.round_start_time
		duration_text = time2text(elapsed_time, "hh:mm:ss")

	var/msg_text = "> ### [status_emoji] [GLOB.round_id ? "Round #[GLOB.round_id]" : "Current Round"] — Endgame Vote\n> \n> 📊 **Outcome:** `[winning_option]`\n> ⏱️ **Duration:** `[duration_text]`\n> 👥 **Players:** `[total_clients]` ( **IR:** `[in_round]` | **OBS:** `[observers]` )"

	for(var/channel_tag in CONFIG_GET(str_list/channel_announce_end_game))
		send2chat(new /datum/tgs_message_content(msg_text), channel_tag)

#undef CHOICE_TRANSFER
#undef CHOICE_CONTINUE
