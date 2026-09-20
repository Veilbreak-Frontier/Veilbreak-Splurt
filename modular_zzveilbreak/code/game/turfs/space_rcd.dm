/turf/open/CanBuildHere()
	if(isspaceturf(src) && destination_z)
		return FALSE
	return TRUE

/turf/open/space/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(ITEM_INTERACT_ANY_BLOCKER & .)
		return .

	if(!istype(tool, /obj/item/stack/rods) && !ismetaltile(tool))
		return NONE

	if(!CanBuildHere())
		return NONE

	if(istype(tool, /obj/item/stack/rods))
		build_with_rods(tool, user)
		return ITEM_INTERACT_SUCCESS

	if(ismetaltile(tool))
		build_with_floor_tiles(tool, user)
		return ITEM_INTERACT_SUCCESS

	return NONE

/turf/open/openspace/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(ITEM_INTERACT_ANY_BLOCKER & .)
		return .

	var/is_buildable_tool = istype(tool, /obj/item/stack/rods) \
		|| ismetaltile(tool) \
		|| istype(tool, /obj/item/stack/thermoplastic) \
		|| istype(tool, /obj/item/stack/sheet/mineral/titanium)

	if(!is_buildable_tool)
		return NONE

	if(!CanBuildHere())
		return NONE

	if(istype(tool, /obj/item/stack/rods))
		build_with_rods(tool, user)
		return ITEM_INTERACT_SUCCESS

	if(ismetaltile(tool))
		build_with_floor_tiles(tool, user)
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/stack/thermoplastic))
		build_with_transport_tiles(tool, user)
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/stack/sheet/mineral/titanium))
		build_with_titanium(tool, user)
		return ITEM_INTERACT_SUCCESS

	return NONE

/turf/open/space/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, list/rcd_data)
	if(rcd_data[RCD_DESIGN_MODE] == RCD_TURF && rcd_data[RCD_DESIGN_PATH] == /turf/open/floor/plating/rcd)
		for(var/obj/structure/lattice/lat in src)
			qdel(lat)
		place_on_top(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
		return TRUE
	return ..()

/turf/open/openspace/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, list/rcd_data)
	if(rcd_data[RCD_DESIGN_MODE] == RCD_TURF && rcd_data[RCD_DESIGN_PATH] == /turf/open/floor/plating/rcd)
		for(var/obj/structure/lattice/lat in src)
			qdel(lat)
		place_on_top(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
		return TRUE
	return ..()

/obj/structure/lattice/catwalk/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.mode == RCD_DECONSTRUCT)
		return list("mode" = RCD_DECONSTRUCT, "delay" = 1 SECONDS, "cost" = 5)
	if(the_rcd.mode == RCD_TURF)
		return list("delay" = 0, "cost" = the_rcd.rcd_design_path == /obj/structure/lattice/catwalk ? 2 : 1)
	return FALSE

/obj/structure/lattice/catwalk/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, list/rcd_data)
	if(rcd_data[RCD_DESIGN_MODE] == RCD_DECONSTRUCT)
		var/turf/turf = loc
		for(var/obj/structure/cable/cable_coil in turf)
			cable_coil.deconstruct()
		qdel(src)
		return TRUE
	if(rcd_data[RCD_DESIGN_MODE] == RCD_TURF)
		var/design_structure = rcd_data[RCD_DESIGN_PATH]
		if(design_structure == /turf/open/floor/plating/rcd)
			var/turf/T = get_turf(src)
			if(isgroundlessturf(T))
				T.place_on_top(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
				qdel(src)
				return TRUE
		if(design_structure == /obj/structure/lattice/catwalk)
			replace_with_catwalk()
			return TRUE
	return FALSE
