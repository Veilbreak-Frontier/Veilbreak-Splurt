/obj/item/storage/bag/xeno
	desc = "A bag for the storage and transport of anomalous materials. Crossbred slime extracts take up much more internal packing than raw cores."

/obj/item/storage/bag/xeno/bluespace
	name = "bluespace science bag"
	desc = "A science bag woven through with bluespace microcapillaries. It holds a large stockpile of raw slime cores, while crossbred extracts still consume several times the packing volume of a core."
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "xenobag"
	worn_icon_state = "xenobag"
	color = "#c4d4ff"
	resistance_flags = FIRE_PROOF
	storage_type = /datum/storage/bag/xeno/bluespace

/datum/design/bluespace_science_bag
	name = "Bluespace Science Bag"
	desc = "Allows printing a bluespace science bag for xenobiology—expanded capacity for cores and crossbred extracts alike."
	id = "bluespace_science_bag"
	build_type = PROTOLATHE
	materials = list(
		/datum/material/plastic = SHEET_MATERIAL_AMOUNT,
		/datum/material/bluespace = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/gold = SMALL_MATERIAL_AMOUNT * 5,
	)
	build_path = /obj/item/storage/bag/xeno/bluespace
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_SCIENCE,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE
