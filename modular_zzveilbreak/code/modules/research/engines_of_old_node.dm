/datum/techweb_node/engines_of_old
	id = "engines_of_old"
	display_name = "Engines of Old"
	description = "Legacy engineering marvels from the past: Antimatter Engines, Particle Accelerators, and Radiation Collectors."
	prereq_ids = list(TECHWEB_NODE_PARTS_UPG)
	design_ids = list(
		"am_control_unit",
		"particle_control",
		"rad_collector",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_ENGINEERING)
