/*
 * Operating Computer Zone Selection Fix
 *
 * Operating computer zone selection is unreliable: the TGUI silently no-ops
 * ui_act when the surgeon is beyond 2 tiles, forcing them to step away and back
 * to change target, and ui_close reverts the surgeon's HUD zone, discarding the
 * TGUI selection and diverging the surgical target from what the UI displayed.
 */

/obj/machinery/computer/operating/ui_check(mob/living/user)
	if(!is_operational)
		return UI_CLOSE
	if(IS_UNCONSCIOUS(user))
		return UI_CLOSE
	if(user.body_position == LYING_DOWN)
		return (user.loc == table?.loc) ? UI_CLOSE : UI_DISABLED
	if(user.incapacitated)
		return UI_DISABLED
	if(!(user in viewers(world.view, src)))
		return UI_DISABLED
	return UI_INTERACTIVE

/obj/machinery/computer/operating/ui_close(mob/user)
	. = ..()
	LAZYREMOVE(zone_on_open, WEAKREF(user))
	if(!LAZYLEN(zone_on_open))
		zone_on_open = initial(zone_on_open)
