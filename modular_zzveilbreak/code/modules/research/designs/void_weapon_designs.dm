/// Protolathe designs for modular void weaponry.

/datum/design/void_piercer
	name = "Void Piercer"
	desc = "A void-tuned self-recharging energy weapon that fires searing piercing pulses."
	id = "void_piercer"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 1.5,
		/datum/material/uranium = SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/gun/energy/void_piercer
	category = list(
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_RANGED
	)
