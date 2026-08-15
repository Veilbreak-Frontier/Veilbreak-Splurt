/turf/afterShuttleMove(turf/oldT, rotation)
	. = ..()
	var/area/our_area = loc
	if(our_area?.static_lighting && !space_lit && !lighting_object)
		lighting_build_overlay()
		reconsider_lights()
