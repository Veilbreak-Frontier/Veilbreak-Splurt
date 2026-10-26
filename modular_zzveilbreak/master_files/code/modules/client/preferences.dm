/atom/movable/screen/map_view/char_preview/update_body()
	..()

	var/raw_height = preferences.read_preference(/datum/preference/choiced/height_scaling)
	var/chosen_height = text2num(raw_height)

	if(isnull(chosen_height))
		chosen_height = HUMAN_HEIGHT_MEDIUM

	if(chosen_height != HUMAN_HEIGHT_MEDIUM)
		var/list/current_overlays = overlays.Copy()
		if(length(current_overlays))
			cut_overlays()
			for(var/character_overlay as anything in current_overlays)
				var/mutable_appearance/render_layer = new(character_overlay)

				// Direct pixel-perfect layer offsets pulling from your server's global constants
				if(GLOB.human_heights_to_offsets && GLOB.human_heights_to_offsets["[chosen_height]"])
					var/offset_z = GLOB.human_heights_to_offsets["[chosen_height]"]["[UPPER_BODY]"] || 0
					render_layer.pixel_z += offset_z

					// Propagate the exact coordinate displacement down to sub-clothing attachments
					for(var/mutable_appearance/sub_overlay in render_layer.overlays + render_layer.underlays)
						sub_overlay.pixel_z += offset_z
				else
					// Mathematical fallback tracker if your local macro strings serialize unbracketed
					var/offset_modifier = (chosen_height - HUMAN_HEIGHT_MEDIUM)
					render_layer.pixel_z += offset_modifier
					for(var/mutable_appearance/sub_overlay in render_layer.overlays + render_layer.underlays)
						sub_overlay.pixel_z += offset_modifier

				add_overlay(render_layer)
