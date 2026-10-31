/**
 * Ensures the preferences character preview map_view is only registered to the
 * client's screen once BOTH the parent TGUI window is visible AND the ByondUi
 * map control has actually been mounted on the client.
 *
 * If BYOND registers screen objects to a secondary map control while the
 * parent window has `is-visible = false` or before the map control exists,
 * BYOND falls back to `world.view` (15x15 tiles) instead of auto-fitting the
 * 1x1/2x2/3x3 preview canvas, rendering a tiny "micro" character.
 */
/atom/movable/screen/map_view/char_preview/display_to(mob/show_to, datum/tgui_window/window)
	if(istype(preferences, /datum/preferences) && window && window.visible && !(assigned_map in window.locked_by?.open_byondui_elements))
		return
	return ..()

/atom/movable/screen/map_view/char_preview/display_on_ui_visible(datum/tgui_window/window, client/show_to)
	if(istype(preferences, /datum/preferences) && !(assigned_map in window?.locked_by?.open_byondui_elements))
		UnregisterSignal(window, COMSIG_TGUI_WINDOW_VISIBLE)
		return
	return ..()

/datum/tgui/on_message(type, list/payload, list/href_list)
	. = ..()
	if(type == TGUI_MANAGED_BYONDUI_TYPE_RENDER && istype(src_object, /datum/preferences))
		var/datum/preferences/prefs = src_object
		var/atom/movable/screen/map_view/char_preview/preview = prefs.character_preview_view
		if(preview && window?.visible && (preview.assigned_map in open_byondui_elements) && user?.client)
			preview.UnregisterSignal(window, COMSIG_TGUI_WINDOW_VISIBLE)
			preview.display_to_client(user.client)
