/obj/machinery/vending/wardrobe/robo_wardrobe
	product_categories = list(
		list(
			"name" = "Clothing",
			"icon" = FA_ICON_SHIRT,
			"products" = list(
				/obj/item/clothing/glasses/welding/steampunk_goggles = 2,
				/obj/item/clothing/gloves/color/black = 2,
				/obj/item/clothing/head/beret/science/fancy/robo = 2,
				/obj/item/clothing/head/playbunnyears/roboticist = 2,
				/obj/item/clothing/suit/toggle/jacket/zubber/bomber/science/robotics = 2,
				/obj/item/clothing/suit/toggle/labcoat/roboticist/doctor_tailcoat = 2,
				/obj/item/clothing/under/rank/rnd/roboticist/skyrat/sleek = 2,
				/obj/item/clothing/under/rank/rnd/scientist/roboticist_bunnysuit = 2,
				/obj/item/clothing/suit/toggle/labcoat/skyrat/fancy/roboticist = 3,
				/obj/item/storage/backpack/duffelbag/science/robo = 2,
				/obj/item/storage/backpack/messenger/science/robo = 2,
				/obj/item/storage/backpack/satchel/science/robo = 2,
				/obj/item/storage/backpack/science/robo = 2,
				/obj/item/clothing/under/rank/rnd/roboticist/alt = 2,
				/obj/item/clothing/under/rank/rnd/roboticist/skirt/alt = 2,
			),
		),
		list(
			"name" = "Surgery",
			"icon" = FA_ICON_VIAL,
			"products" = list(
				/obj/item/bonesetter = 2,
				/obj/item/clothing/mask/breath = 2,
				/obj/item/tank/internals/anesthetic = 2,
				/obj/item/reagent_containers/syringe = 2,
				/obj/item/reagent_containers/cup/bottle/morphine = 2,
				/obj/item/reagent_containers/spray/dinitrogen_plasmide = 2,
				/obj/item/reagent_containers/spray/hercuri/chilled = 2,
				/obj/item/stack/medical/wrap/gauze = 4,
				/obj/item/healthanalyzer/no_medibot = 2,
				/obj/item/healthanalyzer/simple = 2,
				/obj/item/storage/pill_bottle/liquid_solder = 1,
				/obj/item/storage/pill_bottle/nanite_slurry = 1,
				/obj/item/storage/pill_bottle/system_cleaner = 1,
				/obj/item/reagent_containers/blood/oil = 2,
				/obj/item/paper/pamphlet/roboticist_reminder = 4,
			),
		)
	)

/obj/machinery/vending/wardrobe/robo_wardrobe/Initialize(mapload)
	. = ..()

/obj/machinery/vending/wardrobe/robo_wardrobe/New()
	. = ..()
