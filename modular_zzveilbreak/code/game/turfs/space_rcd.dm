/turf/open/CanBuildHere()
	if(isspaceturf(src) && destination_z)
		return FALSE
	return TRUE

/turf/open/space/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()

	if(istype(tool, /obj/item/construction/rcd) || istype(tool, /obj/item/holosign_creator))
		return NONE

	if(ITEM_INTERACT_ANY_BLOCKER & .)
		return .

	if(istype(tool, /obj/item/stack/rods))
		if(!CanBuildHere())
			return .
		build_with_rods(tool, user)
		return ITEM_INTERACT_SUCCESS

	if(ismetaltile(tool))
		if(!CanBuildHere())
			return .
		build_with_floor_tiles(tool, user)
		return ITEM_INTERACT_SUCCESS

	return NONE

/turf/open/openspace/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()

	if(istype(tool, /obj/item/construction/rcd) || istype(tool, /obj/item/holosign_creator))
		return NONE

	if(ITEM_INTERACT_ANY_BLOCKER & .)
		return .

	if(istype(tool, /obj/item/stack/rods))
		if(!CanBuildHere())
			return .
		build_with_rods(tool, user)
		return ITEM_INTERACT_SUCCESS

	if(ismetaltile(tool))
		if(!CanBuildHere())
			return .
		build_with_floor_tiles(tool, user)
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/stack/thermoplastic))
		if(!CanBuildHere())
			return .
		build_with_transport_tiles(tool, user)
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/stack/sheet/mineral/titanium))
		if(!CanBuildHere())
			return .
		build_with_titanium(tool, user)
		return ITEM_INTERACT_SUCCESS

	return NONE
