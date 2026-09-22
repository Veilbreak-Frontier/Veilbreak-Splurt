/*
 * VEILBREAK MODULAR OVERRIDE
 *
 * Popup plane master groups build the popup-safe parallax whitifier
 * (/atom/movable/screen/plane_master/parallax_white/veilbreak_popup) instead
 * of the stock one. See parallax_white_popup.dm for the full rationale.
 *
 * subtypesof() already returns the child type, so removing the parent is
 * sufficient - no explicit re-add, no duplicate instantiation.
 */

/datum/plane_master_group/popup/get_plane_types()
	. = ..()
	. -= /atom/movable/screen/plane_master/parallax_white
