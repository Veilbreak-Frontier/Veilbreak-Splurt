/area/Initialize(mapload)
	. = ..()
	if(static_lighting)
		for(var/obj/docking_port/mobile/shuttle as anything in SSshuttle.mobile_docking_ports)
			if(shuttle.shuttle_areas[src])
				static_lighting = FALSE
				for(var/turf/T in contents)
					if(!T.lighting_object)
						T.lighting_build_overlay()
					T.reconsider_lights()
				break

/turf/afterShuttleMove(turf/oldT, rotation)
	. = ..()
	var/area/A = loc
	if(A.static_lighting)
		A.static_lighting = FALSE
		lighting_build_overlay()
	if(lighting_corner_NE)
		lighting_corner_NE.vis_update()
	if(lighting_corner_SE)
		lighting_corner_SE.vis_update()
	if(lighting_corner_SW)
		lighting_corner_SW.vis_update()
	if(lighting_corner_NW)
		lighting_corner_NW.vis_update()
	for(var/obj/machinery/light/L in contents)
		L.update_light()
