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

/turf/open/space/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, list/rcd_data)
	log_world("RCD_DBG SPACE_RCD_ACT loc=[src.type] mode=[rcd_data[RCD_DESIGN_MODE]] path=[rcd_data[RCD_DESIGN_PATH]]")
	if(rcd_data[RCD_DESIGN_MODE] == RCD_TURF && rcd_data[RCD_DESIGN_PATH] == /turf/open/floor/plating/rcd)
		for(var/obj/structure/lattice/lat in src)
			log_world("RCD_DBG SPACE_RCD_ACT qdel=[lat.type]")
			qdel(lat)
		place_on_top(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
		log_world("RCD_DBG SPACE_RCD_ACT placed plating")
		return TRUE
	return ..()

/turf/open/openspace/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, list/rcd_data)
	log_world("RCD_DBG OPENSPACE_RCD_ACT loc=[src.type] mode=[rcd_data[RCD_DESIGN_MODE]] path=[rcd_data[RCD_DESIGN_PATH]]")
	if(rcd_data[RCD_DESIGN_MODE] == RCD_TURF && rcd_data[RCD_DESIGN_PATH] == /turf/open/floor/plating/rcd)
		for(var/obj/structure/lattice/lat in src)
			log_world("RCD_DBG OPENSPACE_RCD_ACT qdel=[lat.type]")
			qdel(lat)
		place_on_top(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
		log_world("RCD_DBG OPENSPACE_RCD_ACT placed plating")
		return TRUE
	return ..()

/obj/item/construction/rcd/rcd_create(atom/target, mob/user)
	log_world("RCD_DBG CREATE_ENTER target=[target.type] isopenturf=[isopenturf(target)] mode=[mode] path=[rcd_design_path]")
	var/result = ..()
	log_world("RCD_DBG CREATE_EXIT target=[target.type] result=[result]")
	return result

/obj/structure/lattice/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	log_world("RCD_DBG LAT_RCD_VALS src=[src.type] loc=[src.loc?.type] mode=[the_rcd.mode] path=[the_rcd.rcd_design_path]")
	var/result = ..()
	log_world("RCD_DBG LAT_RCD_VALS_EXIT src=[src.type] result=[result]")
	return result

/obj/structure/lattice/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, list/rcd_data)
	log_world("RCD_DBG LAT_RCD_ACT src=[src.type] loc=[src.loc?.type] groundless=[isgroundlessturf(src.loc)] mode=[rcd_data[RCD_DESIGN_MODE]] path=[rcd_data[RCD_DESIGN_PATH]]")
	var/result = ..()
	log_world("RCD_DBG LAT_RCD_ACT_EXIT src=[src.type] result=[result]")
	return result
