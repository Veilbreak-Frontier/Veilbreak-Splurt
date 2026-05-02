#define PHYSICAL_POSITION(atom) ((atom.y * 32) + (atom.pixel_y))

/obj/item/camera/proc/camera_get_icon(list/turfs, turf/center, psize_x = 96, psize_y = 96, datum/turf_reservation/clone_area, size_x, size_y, total_x, total_y)
	var/list/render_queue = list()
	var/xcomp = (psize_x / 2) - 16
	var/ycomp = (psize_y / 2) - 16

	var/mutable_appearance/backdrop = mutable_appearance('icons/hud/screen_gen.dmi', "flash")
	backdrop.blend_mode = BLEND_OVERLAY
	backdrop.color = "#292319"

	for(var/t in turfs)
		var/turf/T = t
		render_queue += T
		if(T.lighting_object)
			render_queue += T.lighting_object
		for(var/atom/movable/AM in T)
			if(AM.invisibility)
				if(!(see_ghosts && (isobserver(AM) || HAS_TRAIT(AM, TRAIT_INVISIBLE_TO_CAMERA))))
					continue
			render_queue += AM

	var/list/sorted = list()
	var/j
	for(var/i in 1 to render_queue.len)
		var/atom/c = render_queue[i]
		for(j = sorted.len, j > 0, --j)
			var/atom/c2 = sorted[j]
			if(c2.plane > c.plane)
				continue
			if(c2.plane < c.plane)
				break
			var/c_pos = PHYSICAL_POSITION(c)
			var/c2_pos = PHYSICAL_POSITION(c2)
			if(c2_pos - 32 >= c_pos)
				break
			if(c2_pos <= c_pos - 32)
				continue
			if(c2.layer < c.layer)
				break
		sorted.Insert(j+1, c)
		CHECK_TICK

	var/icon/res = icon('icons/blanks/96x96.dmi', "nothing")
	res.Scale(psize_x, psize_y)

	for(var/atom/A in sorted)
		var/icon/img
		var/is_lighting = FALSE
		if(isturf(A))
			var/turf/T = A
			if(T.lighting_object == A)
				is_lighting = TRUE

		if(is_lighting)
			img = icon(A.icon, A.icon_state)
			img.Blend(backdrop, ICON_OVERLAY)
		else
			img = build_recursive_flattened_icon(A)

		if(!img)
			continue

		var/xo = (A.x - center.x) * 32 + A.pixel_x + xcomp
		var/yo = (A.y - center.y) * 32 + A.pixel_y + ycomp

		if(ismovable(A))
			var/atom/movable/AM = A
			xo += AM.step_x
			yo += AM.step_y

		if(A.transform)
			var/matrix/M = A.transform
			var/datum/decompose_matrix/decompose = M.decompose()
			if(decompose.scale_x != 1 || decompose.scale_y != 1)
				var/bw = img.Width()
				var/bh = img.Height()
				img.Scale(bw * abs(decompose.scale_x), bh * decompose.scale_y)
				if(decompose.scale_x < 0)
					img.Flip(EAST)
				xo -= (img.Width() - bw) / 2
				yo -= (img.Height() - bh) / 2
			if(decompose.rotation != 0)
				img.Turn(decompose.rotation)
			xo += decompose.shift_x
			yo += decompose.shift_y

		var/imode = ICON_OVERLAY
		switch(A.blend_mode)
			if(BLEND_MULTIPLY)
				imode = ICON_MULTIPLY
			if(BLEND_ADD)
				imode = ICON_ADD
			if(BLEND_SUBTRACT)
				imode = ICON_SUBTRACT

		res.Blend(img, imode, xo, yo)
		CHECK_TICK

	return res

/proc/build_recursive_flattened_icon(atom/A, list/passed_color)
	var/icon/base = icon(A.icon, A.icon_state, A.dir)
	var/list/working_color = passed_color

	if(istype(A, /obj/structure/serpentine_tail))
		var/obj/structure/serpentine_tail/ST = A
		if(ST.owner?.dna?.mutant_bodyparts)
			var/list/taur_data = ST.owner.dna.mutant_bodyparts["taur"] || ST.owner.dna.mutant_bodyparts["taur_snake"]
			if(taur_data && taur_data["color"])
				working_color = taur_data["color"]

	if(iscarbon(A))
		var/mob/living/carbon/C = A
		if(C.dna?.mutant_bodyparts)
			var/list/taur_data = C.dna.mutant_bodyparts["taur"] || C.dna.mutant_bodyparts["taur_snake"]
			if(taur_data && taur_data["color"])
				working_color = taur_data["color"]

	if(!working_color && A.atom_colours)
		for(var/i in A.atom_colours.len to 1 step -1)
			var/list/color_data = A.atom_colours[i]
			if(color_data && color_data[1])
				working_color = islist(color_data[1]) ? color_data[1] : list(color_data[1])
				break

	if(!working_color && A.color && A.color != "#ffffff")
		working_color = islist(A.color) ? A.color : list(A.color)

	if(working_color)
		if(length(working_color) >= 20)
			base.MapColors(arglist(working_color))
		else
			for(var/c_val in working_color)
				base.Blend(c_val, ICON_MULTIPLY)

	if(length(A.overlays))
		for(var/overlay in A.overlays)
			var/icon/ov
			if(istype(overlay, /image))
				var/image/I = overlay
				ov = icon(I.icon || A.icon, I.icon_state, I.dir || A.dir)
				if(I.color && I.color != "#ffffff")
					ov.Blend(I.color, ICON_MULTIPLY)
			else if(isappearance(overlay))
				ov = icon(overlay)

			if(ov)
				if(working_color)
					if(length(working_color) >= 20)
						ov.MapColors(arglist(working_color))
					else
						for(var/cv in working_color)
							ov.Blend(cv, ICON_MULTIPLY)
				base.Blend(ov, ICON_OVERLAY)

	if(A.vars.Find("vis_contents"))
		var/list/vc = A.vars["vis_contents"]
		if(length(vc))
			for(var/atom/V in vc)
				var/icon/vic = build_recursive_flattened_icon(V, working_color)
				base.Blend(vic, ICON_OVERLAY, V.pixel_x, V.pixel_y)

	if(A.alpha < 255)
		base.MapColors(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,A.alpha/255, 0,0,0,0)

	return base

#undef PHYSICAL_POSITION
