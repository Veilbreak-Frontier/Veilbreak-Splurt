/// Bubber antag panel "reroll" called SSgamemode.reroll_antagonist — proc was never implemented on storyteller SS.
/datum/controller/subsystem/gamemode/proc/reroll_antagonist(antag_name)
	SHOULD_NOT_SLEEP(TRUE)
	log_game("reroll_antagonist invoked for [antag_name] but storyteller has no reassignment hook (no-op).")
