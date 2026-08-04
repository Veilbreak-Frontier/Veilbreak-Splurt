/datum/supply_pack/engineering/antimatter
	name = "Antimatter Engine Crate"
	desc = "Contains everything required to assemble a functional Antimatter Engine: one control unit, nine shielding containers, and two containment jars."
	cost = CARGO_CRATE_VALUE * 15
	access_view = ACCESS_ENGINE_EQUIP
	crate_type = /obj/structure/closet/crate/engineering/antimatter
	contains = list(
		/obj/machinery/power/am_control_unit,
		/obj/item/am_containment = 2,
		/obj/item/am_shielding_container = 9,
	)
	crate_name = "antimatter engine crate"

/datum/supply_pack/engineering/am_jar
	name = "Antimatter Containment Jar Crate"
	desc = "Two Antimatter containment jars stuffed into a single crate."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/obj/item/am_containment = 2)
	crate_name = "antimatter jar crate"

/datum/supply_pack/engineering/am_core
	name = "Antimatter Control Crate"
	desc = "The brains of the Antimatter engine, this device is sure to teach the station's powergrid the true meaning of real power."
	cost = CARGO_CRATE_VALUE * 8
	contains = list(/obj/machinery/power/am_control_unit)
	crate_name = "antimatter control crate"

/datum/supply_pack/engineering/am_shielding
	name = "Antimatter Shielding Crate"
	desc = "Contains nine Antimatter shields, digitalized into storage containers."
	cost = CARGO_CRATE_VALUE * 5
	contains = list(/obj/item/am_shielding_container = 9)
	crate_name = "antimatter shielding crate"
