/// Void's Blessing Tech Tree
/// Research nodes related to harnessing the power of the void

/datum/techweb_node/voids_blessing
	id = "voids_blessing"
	display_name = "Void's Blessing"
	description = "Harness the power of the void to extract materials from nothingness."
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)
	prereq_ids = list(TECHWEB_NODE_MINING)
	design_ids = list(
		"void_miner",
		"entropic_converter",
		"void_infuser_board",
	)

/* Temporarily disabled: Void's Influence node uses WIP machines

/datum/techweb_node/voids_influence
    id = "voids_influence"
    display_name = "Void's Influence"
    description = "Further harness the void to manipulate radiation and space."
    research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
    prereq_ids = list("voids_blessing")
    design_ids = list(
        "void_radiation_collector",
        "void_bluespace_sender"
    )

*/
/// Tier 5 (void) stock parts. Requires Bluespace Parts and completing Voidshard Analysis.
/datum/techweb_node/parts_void
	id = "parts_void"
	display_name = "Void Parts"
	description = "Components touched by the void—cold, precise, and hungry. Requires voidshard analysis and tier 4 parts research."
	prereq_ids = list(TECHWEB_NODE_PARTS_BLUESPACE)
	required_experiments = list(/datum/experiment/scanning/voidshard_analysis)
	design_ids = list(
		"void_capacitor",
		"void_scanning_module",
		"void_servo",
		"void_micro_laser",
		"void_matter_bin",
		"void_cell",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_5_POINTS)
	announce_channels = list(RADIO_CHANNEL_ENGINEERING, RADIO_CHANNEL_SCIENCE)

