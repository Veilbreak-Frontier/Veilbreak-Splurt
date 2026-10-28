/**
 * Hook into ui_interact to handle the window assignment safely.
 */
/datum/preferences/ui_interact(mob/user, datum/tgui/ui)
	var/is_new_ui = !ui
	. = ..()
	if(is_new_ui && src.character_preview_view)
		var/datum/tgui/current_ui = SStgui.get_open_ui(user, src)
		if(current_ui && current_ui.window)
			src.character_preview_view.display_to(user, current_ui.window)

/**
 * Intercept TGUI data requests to force an update when the UI first mounts.
 * This mimics the exact update cycle triggered when you click a body size slider.
 */
/datum/preferences/ui_data(mob/user)
	. = ..()

	if(src.character_preview_view)
		spawn(2)
			if(src && src.character_preview_view)
				src.character_preview_view.update_body()
