/**
 * Hook into ui_interact to ensure the TGUI window reference is explicitly
 * passed to display_to, allowing the system to wait for COMSIG_TGUI_WINDOW_VISIBLE.
 */
/datum/preferences/ui_interact(mob/user, datum/tgui/ui)
	var/is_new_ui = !ui
	. = ..()
	if(is_new_ui && src.character_preview_view)
		var/datum/tgui/current_ui = SStgui.get_open_ui(user, src)
		if(current_ui && current_ui.window)
			src.character_preview_view.display_to(user, current_ui.window)
