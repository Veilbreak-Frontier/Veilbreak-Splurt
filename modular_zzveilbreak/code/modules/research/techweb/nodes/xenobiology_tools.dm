/datum/techweb_node/xenobiology_tools
	id = "xenobiology_tools"
	display_name = "Xenobiology Tools"
	description = "Bluespace-accelerated containment for xenobiological cores and crossbred extracts."
	prereq_ids = list(TECHWEB_NODE_PARTS_BLUESPACE, TECHWEB_NODE_XENOBIOLOGY)
	design_ids = list(
		"bluespace_science_bag",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)
