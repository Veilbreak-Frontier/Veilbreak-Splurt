/// Tier 5 (void) stock parts - Veilbreak
/// Void-touched components; requires Bluespace Parts + Voidshard Analysis to research.
/// Icon source: modular_zzveilbreak/icons/obj/quantum_parts.dmi

/obj/item/stock_parts/capacitor/void
	name = "void capacitor"
	desc = "A capacitor channeling the void—cold, hungry, and impossibly efficient at storing charge."
	icon = 'modular_zzveilbreak/icons/obj/quantum_parts.dmi'
	icon_state = "void_capacitor"
	rating = 5
	energy_rating = 20
	custom_materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 1.1,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 0.9,
		/datum/material/gold = SMALL_MATERIAL_AMOUNT * 0.7,
		/datum/material/diamond = SMALL_MATERIAL_AMOUNT * 0.5,
	)

/datum/stock_part/capacitor/tier5
	tier = 5
	physical_object_type = /obj/item/stock_parts/capacitor/void

/obj/item/stock_parts/scanning_module/void
	name = "void scanning module"
	desc = "A module that peers into the void to resolve signals and matter at the edge of nothing."
	icon = 'modular_zzveilbreak/icons/obj/quantum_parts.dmi'
	icon_state = "void_scanning_module"
	rating = 5
	energy_rating = 20
	custom_materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 1.1,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 0.9,
		/datum/material/diamond = SMALL_MATERIAL_AMOUNT * 0.3,
		/datum/material/bluespace = SMALL_MATERIAL_AMOUNT * 0.3,
	)

/datum/stock_part/scanning_module/tier5
	tier = 5
	physical_object_type = /obj/item/stock_parts/scanning_module/void

/obj/item/stock_parts/servo/void
	name = "void servo"
	desc = "A servo that seems to move through the void—barely there, yet capable of impossible precision."
	icon = 'modular_zzveilbreak/icons/obj/quantum_parts.dmi'
	icon_state = "void_servo"
	rating = 5
	energy_rating = 20
	custom_materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 0.9,
		/datum/material/diamond = SMALL_MATERIAL_AMOUNT * 0.1,
		/datum/material/titanium = SMALL_MATERIAL_AMOUNT * 0.1,
		/datum/material/uranium = SMALL_MATERIAL_AMOUNT * 0.1,
	)

/datum/stock_part/servo/tier5
	tier = 5
	physical_object_type = /obj/item/stock_parts/servo/void

/obj/item/stock_parts/micro_laser/void
	name = "void micro-laser"
	desc = "A micro-laser that draws on the void—its beam feels less like light and more like absence."
	icon = 'modular_zzveilbreak/icons/obj/quantum_parts.dmi'
	icon_state = "void_micro_laser"
	rating = 5
	energy_rating = 20
	custom_materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 0.9,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 0.9,
		/datum/material/diamond = SMALL_MATERIAL_AMOUNT * 0.5,
		/datum/material/uranium = SMALL_MATERIAL_AMOUNT * 0.5,
	)

/datum/stock_part/micro_laser/tier5
	tier = 5
	physical_object_type = /obj/item/stock_parts/micro_laser/void

/obj/item/stock_parts/matter_bin/void
	name = "void matter bin"
	desc = "A matter bin that stores material in a pocket of void—nothing is lost, only elsewhere."
	icon = 'modular_zzveilbreak/icons/obj/quantum_parts.dmi'
	icon_state = "void_matter_bin"
	rating = 5
	energy_rating = 20
	custom_materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 1.1,
		/datum/material/diamond = SMALL_MATERIAL_AMOUNT * 0.5,
		/datum/material/bluespace = SMALL_MATERIAL_AMOUNT * 0.7,
	)

/datum/stock_part/matter_bin/tier5
	tier = 5
	physical_object_type = /obj/item/stock_parts/matter_bin/void

/obj/item/stock_parts/power_store/cell/void
	name = "void power cell"
	desc = "A power cell that seems to hold charge in the void—deep capacity and a faint chill."
	icon = 'modular_zzveilbreak/icons/obj/quantum_parts.dmi'
	icon_state = "void_cell"
	maxcharge = STANDARD_CELL_CHARGE * 50
	custom_materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/plasma = SHEET_MATERIAL_AMOUNT * 1.8,
		/datum/material/diamond = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/bluespace = HALF_SHEET_MATERIAL_AMOUNT,
	)
	chargerate = STANDARD_CELL_RATE * 3

/obj/item/stock_parts/power_store/cell/void/empty
	empty = TRUE
