/atom/movable/screen/map_view/char_preview/update_body()
	..()

	var/raw_height = preferences.read_preference(/datum/preference/choiced/height_scaling)
	var/chosen_height = text2num(raw_height)

	if(isnull(chosen_height))
		chosen_height = HUMAN_HEIGHT_MEDIUM

	var/list/current_overlays = overlays.Copy()
	if(length(current_overlays))
		cut_overlays()
		for(var/character_overlay as anything in current_overlays)
			var/mutable_appearance/render_layer = new(character_overlay)

			if(chosen_height != HUMAN_HEIGHT_MEDIUM)
				if(hascall(body, "apply_height_filter"))
					body:apply_height_filter(render_layer)
					if(length(render_layer.overlays))
						for(var/sub_overlay as anything in render_layer.overlays)
							body:apply_height_filter(sub_overlay)
					if(length(render_layer.underlays))
						for(var/sub_underlay as anything in render_layer.underlays)
							body:apply_height_filter(sub_underlay)

			add_overlay(render_layer)
