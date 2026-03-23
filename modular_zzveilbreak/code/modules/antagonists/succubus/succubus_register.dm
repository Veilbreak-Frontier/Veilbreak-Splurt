/// Global: victim mind -> succubus mark datum
GLOBAL_LIST_EMPTY(succubus_marks_by_victim)

/// Register succubus with the antag panel and preferences
/proc/register_succubus_antag()
	GLOB.non_ruleset_antagonists[ROLE_SUCCUBUS] = /datum/antagonist/succubus

// Run at init
register_succubus_antag()
