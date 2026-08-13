/obj/docking_port/mobile/postregister(replace = FALSE)
	. = ..()
	var/list/turfs = return_ordered_turfs(x, y, z, dir)
	for(var/i in 1 to length(turfs))
		var/turf/T = turfs[i]
		if(T)
			T.reconsider_lights()
