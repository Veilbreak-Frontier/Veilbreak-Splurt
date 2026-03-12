/obj/item/autosurgeon/combi
	name = "Combined toolset implant"
	desc = "A compact and functional combination of tool implant and surgical implant. What it lacks in speed and precision it makes up for in function. A Snake Oil Biosolutions product."
	uses = 1
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

/obj/item/storage/medkit/sob
	name = "SOB medical kit"
	desc = "void your life warranty"
	icon_state = "medkit_sob"
	inhand_icon_state = "medkit-toxin"
	damagetype_healed = HEAL_ALL_DAMAGE
	storage_type = /datum/storage/medkit/surgery

/obj/item/storage/medkit/sob/get_medbot_skin()
	return "tox"

/obj/item/storage/medkit/sob/PopulateContents()
	if(empty)
		return
	var/static/list/items_inside = list(
		/obj/item/cautery = 1,
		/obj/item/scalpel = 1,
		/obj/item/healthanalyzer/advanced = 1,
		/obj/item/hemostat = 1,
		/obj/item/reagent_containers/medigel/sterilizine = 1,
		/obj/item/storage/box/bandages = 1,
		/obj/item/surgical_drapes = 1,
		/obj/item/reagent_containers/hypospray/medipen/atropine = 2,
		/obj/item/stack/medical/gauze = 2,
		/obj/item/stack/medical/suture/medicated = 2,
		/obj/item/stack/medical/mesh/advanced = 2,
		/obj/item/reagent_containers/applicator/patch/libital = 4,
		/obj/item/reagent_containers/applicator/patch/aiuri = 4,
	)
	generate_items_inside(items_inside,src)
