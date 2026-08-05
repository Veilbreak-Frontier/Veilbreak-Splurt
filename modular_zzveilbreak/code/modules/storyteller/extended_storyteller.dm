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
		// Block any antagonist events or ghost role events
		if(ispath(event.typepath, /datum/round_event/ghost_role) || istype(event, /datum/round_event_control/antagonist))
			event.calculated_weight = 0
			continue

		var/list/event_tags = event.tags
		if(LAZYLEN(event_tags))
			if((TAG_CREW_ANTAG in event_tags) || (TAG_TEAM_ANTAG in event_tags) || (TAG_OUTSIDER_ANTAG in event_tags) || (TAG_COMBAT in event_tags))
				event.calculated_weight = 0
				continue

		// Ensure anomalies spawn with full weight in low chaos mode
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

// Disable other storytellers from being votable so votes at shift start are between Extended and Low Chaos
/datum/storyteller/medium
	votable = FALSE

/datum/storyteller/medium/opfor
	votable = FALSE

/datum/storyteller/high
	votable = FALSE

/datum/storyteller/high/opfor
	votable = FALSE

/datum/storyteller/low/opfor
	votable = FALSE
