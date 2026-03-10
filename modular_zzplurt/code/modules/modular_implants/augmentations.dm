/obj/item/autosurgeon/combi
	name = "Combined toolset implant"
	desc = "A compact and functional combination of tool implant and surgical implant. What it lacks in speed and precision it makes up for in function. A Snake Oil Biosolutions product."
	starting_organ = /obj/item/organ/cyberimp/arm/toolkit/surgery/combi


/obj/item/organ/cyberimp/arm/toolkit/surgery/combi
	name = "Combined toolset implant"
	desc = "A compact and functional combination of tool implant and surgical implant. What it lacks in speed and precision it makes up for in function. A Snake Oil Biosolutions product."
	actions_types = list(/datum/action/item_action/organ_action/toggle/toolkit)
	items_to_create = list(
		/obj/item/retractor/cruel,
		/obj/item/hemostat/cruel,
		/obj/item/cautery/cruel,
		/obj/item/blood_filter/cruel,
		/obj/item/scalpel/cruel,
		/obj/item/circular_saw/cruel,
		/obj/item/surgical_processor,
		/obj/item/bonesetter/cruel,
		/obj/item/multitool/cyborg,
		/obj/item/screwdriver/omni_drill,
		/obj/item/weldingtool/electric/arc_welder,
		/obj/item/crowbar,

	)

// not used yet, concept im working on

/*
/obj/item/autosurgeon/bio
	starting_organ = /obj/item/organ/cyberimp/arm/toolkit/surgery/bio


/obj/item/organ/cyberimp/arm/toolkit/surgery/bio
	name = "Compact Biomass Tumor"
	desc = "A strange genetic mutation in the arm. seems to contain bone fragments and sinew....gross"
	actions_types = list(/datum/action/item_action/organ_action/toggle/toolkit)
	items_to_create = list(
		/obj/item/towel, // bedsheet for surgery prep, but not bedsheet
		/obj/item/retractor/ashwalker,
		/obj/item/hemostat/ashwalker,
		/obj/item/cautery/ashwalker,
		/obj/item/scalpel/ashwalker,
		/obj/item/circular_saw/ashwalker,
		/obj/item/bonesetter/ashwalker,


	)
*/
