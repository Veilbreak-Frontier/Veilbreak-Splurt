/// Runs once at init to patch globals that we keep out of /code for Veilbreak packaging.
SUBSYSTEM_DEF(veilbreak_early)
	name = "Veilbreak Early"
	flags = SS_NO_FIRE
	priority = FIRE_PRIORITY_DEFAULT

/datum/controller/subsystem/veilbreak_early/Initialize()
	// Splurt roundstart backpack options (defines live in upstream_merge_compat_early.dm)
	if(!(SNAIL_SHELL in GLOB.backpacklist))
		GLOB.backpacklist += SNAIL_SHELL
	if(!(SLOOG_SHELL in GLOB.backpacklist))
		GLOB.backpacklist += SLOOG_SHELL
	return SS_INIT_SUCCESS
