/// Protolathe designs for tier 5 (void) stock parts - Veilbreak
/// Unlocked by Void Parts research (Bluespace Parts + Voidshard Analysis).

/datum/design/void_capacitor
	name = "Void Capacitor"
	desc = "A capacitor channeling the void—cold, hungry, and impossibly efficient at storing charge."
	id = "void_capacitor"
	build_type = PROTOLATHE
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 3.3,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 2.7,
		/datum/material/gold = SMALL_MATERIAL_AMOUNT * 2.1,
		/datum/material/diamond = SMALL_MATERIAL_AMOUNT * 1.5,
	)
	build_path = /obj/item/stock_parts/capacitor/void
	category = list(
		RND_CATEGORY_STOCK_PARTS + RND_SUBCATEGORY_STOCK_PARTS_5
	)
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/void_scanning_module
	name = "Void Scanning Module"
	desc = "A module that peers into the void to resolve signals and matter at the edge of nothing."
	id = "void_scanning_module"
	build_type = PROTOLATHE
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 3.3,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 2.7,
		/datum/material/diamond = SMALL_MATERIAL_AMOUNT * 0.9,
		/datum/material/bluespace = SMALL_MATERIAL_AMOUNT * 0.9,
	)
	build_path = /obj/item/stock_parts/scanning_module/void
	category = list(
		RND_CATEGORY_STOCK_PARTS + RND_SUBCATEGORY_STOCK_PARTS_5
	)
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/void_servo
	name = "Void Servo"
	desc = "A servo that seems to move through the void—barely there, yet capable of impossible precision."
	id = "void_servo"
	build_type = PROTOLATHE
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 2.7,
		/datum/material/diamond = SMALL_MATERIAL_AMOUNT * 0.3,
		/datum/material/titanium = SMALL_MATERIAL_AMOUNT * 0.3,
		/datum/material/uranium = SMALL_MATERIAL_AMOUNT * 0.3,
	)
	build_path = /obj/item/stock_parts/servo/void
	category = list(
		RND_CATEGORY_STOCK_PARTS + RND_SUBCATEGORY_STOCK_PARTS_5
	)
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/void_micro_laser
	name = "Void Micro-Laser"
	desc = "A micro-laser that draws on the void—its beam feels less like light and more like absence."
	id = "void_micro_laser"
	build_type = PROTOLATHE
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 2.7,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 2.7,
		/datum/material/diamond = SMALL_MATERIAL_AMOUNT * 1.5,
		/datum/material/uranium = SMALL_MATERIAL_AMOUNT * 1.5,
	)
	build_path = /obj/item/stock_parts/micro_laser/void
	category = list(
		RND_CATEGORY_STOCK_PARTS + RND_SUBCATEGORY_STOCK_PARTS_5
	)
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/void_matter_bin
	name = "Void Matter Bin"
	desc = "A matter bin that stores material in a pocket of void—nothing is lost, only elsewhere."
	id = "void_matter_bin"
	build_type = PROTOLATHE
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 3.3,
		/datum/material/diamond = SMALL_MATERIAL_AMOUNT * 1.5,
		/datum/material/bluespace = SMALL_MATERIAL_AMOUNT * 2.1,
	)
	build_path = /obj/item/stock_parts/matter_bin/void
	category = list(
		RND_CATEGORY_STOCK_PARTS + RND_SUBCATEGORY_STOCK_PARTS_5
	)
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/void_cell
	name = "Void Power Cell"
	desc = "A power cell that seems to hold charge in the void—deep capacity and a faint chill."
	id = "void_cell"
	build_type = PROTOLATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 1.5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 9,
		/datum/material/plasma = SHEET_MATERIAL_AMOUNT * 5.4,
		/datum/material/diamond = SHEET_MATERIAL_AMOUNT * 1.5,
		/datum/material/bluespace = SHEET_MATERIAL_AMOUNT * 1.5,
	)
	build_path = /obj/item/stock_parts/power_store/cell/void/empty
	category = list(
		RND_CATEGORY_STOCK_PARTS + RND_SUBCATEGORY_STOCK_PARTS_5
	)
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE
