/atom/movable/screen/map_view/char_preview/update_body()
	..()

	var/raw_height = preferences.read_preference(/datum/preference/choiced/height_scaling)
	var/chosen_height = text2num(raw_height)

	if(isnull(chosen_height))
		chosen_height = HUMAN_HEIGHT_MEDIUM

	if(chosen_height != HUMAN_HEIGHT_MEDIUM)
		if(hascall(body, "apply_height"))
			var/mutable_appearance/character_overlay = locate(/mutable_appearance) in overlays
			if(character_overlay)
				body:apply_height(character_overlay, ENTIRE_BODY, TRUE)
				for(var/mutable_appearance/sub_overlay in character_overlay.overlays + character_overlay.underlays)
					body:apply_height(sub_overlay, ENTIRE_BODY, TRUE)
				cut_overlays()
				add_overlay(character_overlay)
