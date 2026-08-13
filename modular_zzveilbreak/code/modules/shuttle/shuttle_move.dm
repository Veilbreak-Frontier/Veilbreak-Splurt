/obj/docking_port/mobile/cleanup_runway(obj/docking_port/stationary/new_dock, list/old_turfs, list/new_turfs, list/areas_to_move, list/underlying_areas, list/moved_atoms, rotation, movement_direction, area/fallback_area)
	. = ..()
	for(var/i in 1 to length(new_turfs))
		var/turf/T = new_turfs[i]
		if(T)
			T.reconsider_lights()
