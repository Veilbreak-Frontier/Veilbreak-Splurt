/turf/open/space/is_blocked_turf(exclude_mobs = FALSE, source_atom = null, ignore_atoms, type_list = FALSE)
	if(type_list && isnull(ignore_atoms) && !exclude_mobs && isnull(source_atom))
		return ..(exclude_mobs = TRUE)
	return ..()

/turf/open/space/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	var/has_lattice = locate(/obj/structure/lattice, src) != null
	var/plating_cost = has_lattice ? 1 : 3

	if(the_rcd.mode == RCD_TURF)
		if(the_rcd.rcd_design_path == /turf/open/floor/plating/rcd)
			return list("delay" = 0, "cost" = plating_cost)
		if(the_rcd.rcd_design_path == /obj/structure/lattice/catwalk)
			return list("delay" = 0, "cost" = has_lattice ? 2 : 4)

	var/turf/open/floor/prototype = new /turf/open/floor/plating()
	var/list/floor_results = prototype.rcd_vals(user, the_rcd)
	qdel(prototype)

	if(floor_results)
		floor_results["cost"] += plating_cost
		return floor_results

	return FALSE

/turf/open/space/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, list/rcd_data)
	if(the_rcd.mode == RCD_TURF)
		if(rcd_data[RCD_DESIGN_PATH] == /turf/open/floor/plating/rcd)
			place_on_top(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
			return TRUE
		if(rcd_data[RCD_DESIGN_PATH] == /obj/structure/lattice/catwalk)
			var/obj/structure/lattice/lattice = locate(/obj/structure/lattice, src)
			if(lattice)
				qdel(lattice)
			new /obj/structure/lattice/catwalk(src)
			return TRUE

	var/turf/open/floor/new_floor = place_on_top(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
	if(istype(new_floor, /turf/open/floor))
		return new_floor.rcd_act(user, the_rcd, rcd_data)
	return FALSE
