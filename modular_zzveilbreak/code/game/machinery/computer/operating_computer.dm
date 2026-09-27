/*
 * Operating Computer Zone Selection Fix
 *
 * Operating computer zone selection is unreliable: the TGUI silently no-ops
 * ui_act when the surgeon is beyond 2 tiles, forcing them to step away and back
 * to change target, and ui_close reverts the surgeon's HUD zone, discarding the
 * TGUI selection and diverging the surgical target from what the UI displayed.
 * Additionally, the TGUI only mirrored the machine's own target_zone, so
 * changing zone via the HUD doll left the TGUI stuck on the previous selection.
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

/obj/machinery/computer/operating/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(ui)
		return
	if(ishuman(user))
		RegisterSignal(user, COMSIG_MOB_SELECTED_ZONE_SET, PROC_REF(on_user_zone_changed), override = TRUE)
	ui = new(user, src, "OperatingComputer", name)
	ui.open()

/obj/machinery/computer/operating/ui_close(mob/user)
	. = ..()
	UnregisterSignal(user, COMSIG_MOB_SELECTED_ZONE_SET)
	LAZYREMOVE(zone_on_open, WEAKREF(user))
	if(!LAZYLEN(zone_on_open))
		zone_on_open = initial(zone_on_open)

/obj/machinery/computer/operating/proc/on_user_zone_changed(mob/user, new_zone)
	SIGNAL_HANDLER
	update_static_data(user)

/obj/machinery/computer/operating/ui_data(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	.["target_zone"] = user.zone_selected
	var/mob/living/patient = table?.patient
	if(patient)
		.["patient"]["surgery_state"] = patient.get_surgery_state_as_list(deprecise_zone(user.zone_selected))

/obj/machinery/computer/operating/ui_static_data(mob/user)
	if(ishuman(user))
		target_zone = user.zone_selected
	return ..()
