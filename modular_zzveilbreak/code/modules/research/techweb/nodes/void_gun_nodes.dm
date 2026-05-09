/// Void gun research tree

/datum/techweb_node/void_guns
	id = TECHWEB_NODE_VOID_GUNS
	display_name = "Void Guns"
	description = "Advanced void-tuned directed-energy firearms."
	prereq_ids = list(TECHWEB_NODE_ELECTRIC_WEAPONS, TECHWEB_NODE_EXOTIC_AMMO)
	design_ids = list(
		"void_piercer",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 80)
	announce_channels = list(RADIO_CHANNEL_SECURITY, RADIO_CHANNEL_SCIENCE)
