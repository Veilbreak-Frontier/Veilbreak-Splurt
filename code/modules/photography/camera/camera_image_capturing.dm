/obj/effect/render_proxy
	vis_flags = VIS_INHERIT_ID | VIS_INHERIT_PLANE | VIS_INHERIT_LAYER

/obj/item/camera/proc/camera_get_icon(list/turfs, turf/center, psize_x = 96, psize_y = 96, datum/turf_reservation/clone_area, size_x, size_y, total_x, total_y)
	if(!istype(clone_area))
		return icon('icons/blanks/96x96.dmi', "nothing")

	var/turf/bottom_left = clone_area.bottom_left_turfs[1]
	var/cloned_center_x = round(bottom_left.x + ((total_x - 1) / 2))
	var/cloned_center_y = round(bottom_left.y + ((total_y - 1) / 2))
	var/turf/cloned_center = locate(cloned_center_x, cloned_center_y, bottom_left.z)

	var/list/proxies = list()
	var/mutable_appearance/backdrop = mutable_appearance('icons/hud/screen_gen.dmi', "flash")
	backdrop.blend_mode = BLEND_OVERLAY
	backdrop.color = "#292319"

	for(var/t in turfs)
		var/turf/T = t
		var/offset_x = T.x - center.x
		var/offset_y = T.y - center.y
		var/turf/newT = locate(cloned_center_x + offset_x, cloned_center_y + offset_y, bottom_left.z)

		if(!(newT in clone_area.reserved_turfs))
			continue

		var/obj/effect/render_proxy/T_P = new(newT)
		T_P.appearance = T.appearance
		T_P.render_source = "\ref[T]"
		proxies += T_P

		if(T.lighting_object)
			var/obj/effect/render_proxy/L_P = new(newT)
			L_P.appearance = T.lighting_object.current_underlay
			L_P.underlays += backdrop
			L_P.blend_mode = BLEND_MULTIPLY
			proxies += L_P

		for(var/atom/movable/AM in T)
			if(AM.invisibility)
				if(!(see_ghosts && (isobserver(AM) || HAS_TRAIT(AM, TRAIT_INVISIBLE_TO_CAMERA))))
					continue

			var/obj/effect/render_proxy/AM_P = new(newT)
			AM_P.appearance = AM.appearance
			AM_P.render_source = "\ref[AM]"
			AM_P.dir = AM.dir
			AM_P.pixel_x = AM.pixel_x
			AM_P.pixel_y = AM.pixel_y
			AM_P.transform = AM.transform
			proxies += AM_P

	var/obj/effect/render_proxy/compositor = new(cloned_center)
	compositor.icon = 'icons/blanks/96x96.dmi'
	compositor.icon_state = "nothing"

	var/matrix/M = matrix()
	M.Scale(psize_x / 32, psize_y / 32)
	compositor.transform = M

	for(var/obj/effect/render_proxy/P in proxies)
		compositor.vis_contents += P

	var/icon/final_render = icon(compositor)

	QDEL_LIST(proxies)
	qdel(compositor)

	return final_render
