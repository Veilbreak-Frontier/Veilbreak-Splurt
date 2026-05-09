/// Animals other than bots may still expose an ID for nanites / armaments via overrides.
/mob/living/simple_animal/proc/get_simple_access_id()
	return null

/mob/living/simple_animal/bot/get_simple_access_id()
	return access_card
