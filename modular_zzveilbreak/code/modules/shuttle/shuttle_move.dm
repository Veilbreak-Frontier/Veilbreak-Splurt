/area/shuttle/Initialize(mapload)
	. = ..()
	if(static_lighting)
		static_lighting = FALSE
		for(var/turf/T in contents)
			T.lighting_build_overlay()
			T.reconsider_lights()

/turf/afterShuttleMove(turf/oldT, rotation)
	. = ..()
	var/area/A = loc
	if(!A.static_lighting)
		lighting_build_overlay()
		reconsider_lights()
