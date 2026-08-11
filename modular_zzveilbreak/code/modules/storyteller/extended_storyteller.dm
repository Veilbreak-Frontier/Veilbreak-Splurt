var/global/storyteller_vote_ready = FALSE

/datum/storyteller_data/tracks/low_chaos
	threshold_mundane = 1200
	threshold_moderate = 1500
	threshold_major = 999999999
	threshold_crewset = 999999999
	threshold_ghostset = 999999999

/datum/storyteller/low
	name = "Low Chaos"
	desc = "A peaceful mode with no antagonists or major destruction. Spawns non-destructive events and environmental anomalies to keep station life interesting without player antagonists or catastrophic threats."
	disable_distribution = FALSE
	guarantees_roundstart_crewset = FALSE
	track_data = /datum/storyteller_data/tracks/low_chaos
	votable = TRUE
	storyteller_type = STORYTELLER_TYPE_ALWAYS_AVAILABLE

/datum/storyteller/low/calculate_weights(track)
	..()
	for(var/datum/round_event_control/event as anything in SSgamemode.event_pools[track])
		if(isnull(event))
			continue
		if(ispath(event.typepath, /datum/round_event/ghost_role) || istype(event, /datum/round_event_control/antagonist))
			event.calculated_weight = 0
			continue
		var/list/event_tags = event.tags
		if(LAZYLEN(event_tags))
			if((TAG_CREW_ANTAG in event_tags) || (TAG_TEAM_ANTAG in event_tags) || (TAG_OUTSIDER_ANTAG in event_tags) || (TAG_COMBAT in event_tags))
				event.calculated_weight = 0
				continue
		if(istype(event, /datum/round_event_control/anomaly))
			event.calculated_weight = max(event.calculated_weight, event.weight)

/datum/storyteller/extended
	name = "Extended"
	desc = "Extended is the absence of a Storyteller. It will not spawn any events or run any antagonists."
	welcome_text = "Peaceful shift with no storyteller events or antagonists."
	disable_distribution = TRUE
	guarantees_roundstart_crewset = FALSE
	votable = TRUE
	storyteller_type = STORYTELLER_TYPE_ALWAYS_AVAILABLE

/datum/controller/subsystem/gamemode
	voted_storyteller = /datum/storyteller/low

/datum/controller/subsystem/gamemode/storyteller_vote_can_override()
	return FALSE

/datum/vote/storyteller/create_vote()
	SSgamemode.voted_storyteller = null
	default_choices = SSgamemode.storyteller_vote_choices()
	. = ..()
	if(length(choices) == 1)
		var/de_facto_winner = choices[1]
		SSgamemode.storyteller_vote_result(de_facto_winner)
		to_chat(world, span_boldannounce("The storyteller vote has been skipped because there is only one storyteller left to vote for. The storyteller has been changed to [de_facto_winner]."))
		return FALSE

/datum/vote/storyteller/can_be_initiated(mob/by_who, forced = FALSE)
	. = ..()
	if(forced)
		return VOTE_AVAILABLE
	if(SSgamemode.storyteller_voted)
		default_message = "The next Storyteller has already been selected."
		return "The next Storyteller has already been selected."
	return VOTE_AVAILABLE

/datum/controller/subsystem/ticker
	var/vote_started = FALSE

/datum/controller/subsystem/ticker/fire()
	. = ..()
	if(current_state == GAME_STATE_PREGAME && !vote_started)
		vote_started = TRUE
		addtimer(CALLBACK(src, PROC_REF(start_storyteller_vote)), 5 SECONDS)

/datum/controller/subsystem/ticker/proc/start_storyteller_vote()
	if(current_state != GAME_STATE_PREGAME)
		return
	SSgamemode.storyteller_voted = FALSE
	SSgamemode.voted_storyteller = null
	storyteller_vote_ready = TRUE
	to_chat(world, span_notice("Storyteller vote starting now."))
	SSvote.initiate_vote(/datum/vote/storyteller, "Storyteller Vote", forced = TRUE)

/datum/controller/subsystem/vote/initiate_vote(vote_type, vote_initiator_name, mob/vote_initiator, forced = FALSE)
	if(vote_type == /datum/vote/storyteller && forced && !storyteller_vote_ready)
		return FALSE
	. = ..()
