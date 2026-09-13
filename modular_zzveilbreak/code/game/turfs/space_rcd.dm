/turf/open/space/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	var/has_lattice = locate(/obj/structure/lattice, src) != null
	var/plating_cost = has_lattice ? 1 : 3

	if(the_rcd.mode == RCD_TURF)
		if(the_rcd.rcd_design_path == /turf/open/floor/plating/rcd)
			return list("delay" = 0, "cost" = plating_cost)
		else if(the_rcd.rcd_design_path == /obj/structure/lattice/catwalk)
			return list("delay" = 0, "cost" = has_lattice ? 2 : 4)

	var/list/floor_results = /turf/open/floor::rcd_vals(user, the_rcd)
	if(floor_results)
		floor_results["cost"] += plating_cost
		return floor_results

	return FALSE

/turf/open/space/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, list/rcd_data)
	if(the_rcd.mode == RCD_TURF)
		if(rcd_data[RCD_DESIGN_PATH] == /turf/open/floor/plating/rcd)
			place_on_top(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
			return TRUE
		else if(rcd_data[RCD_DESIGN_PATH] == /obj/structure/lattice/catwalk)
			var/obj/structure/lattice/lattice = locate(/obj/structure/lattice, src)
			if(lattice)
				qdel(lattice)
			new /obj/structure/lattice/catwalk(src)
			return TRUE

	var/turf/open/floor/F = place_on_top(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
	if(F)
		return F.rcd_act(user, the_rcd, rcd_data)
	return FALSE

/obj/structure/lattice/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.mode == RCD_TURF)
		return list("delay" = 0, "cost" = the_rcd.rcd_design_path == /obj/structure/lattice/catwalk ? 2 : 1)
	var/turf/T = get_turf(src)
	if(T)
		return T.rcd_vals(user, the_rcd)
	return FALSE

/obj/structure/lattice/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, list/rcd_data)
	if(rcd_data[RCD_DESIGN_MODE] == RCD_TURF)
		var/design_structure = rcd_data[RCD_DESIGN_PATH]
		if(design_structure == /turf/open/floor/plating/rcd)
			var/turf/T = src.loc
			if(isgroundlessturf(T))
				T.place_on_top(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
				qdel(src)
				return TRUE
		if(design_structure == /obj/structure/lattice/catwalk)
			replace_with_catwalk()
			return TRUE
	var/turf/T = get_turf(src)
	if(T)
		return T.rcd_act(user, the_rcd, rcd_data)
	return FALSE
