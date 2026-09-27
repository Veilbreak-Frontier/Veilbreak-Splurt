/*
 * Operating Computer Zone Selection Fix
 *
 * The TGUI zone selector silently no-op'd ui_act outside two tiles of the
 * machine, and ui_close reverted the surgeon's HUD zone on close, so target
 * selection had to be redone every time the UI was closed. Additionally the
 * TGUI only mirrored the machine's own target_zone, leaving the HUD doll and
 * the surgery UI out of sync when the zone was changed outside the UI.
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

/obj/machinery/computer/operating/proc/on_user_zone_changed(mob/user, new_zone)
	SIGNAL_HANDLER
	to_chat(user, span_notice("DBG: signal fired, zone=[new_zone] at [world.time]"))
	var/datum/tgui/ui = SStgui.get_open_ui(user, src)
	if(!ui)
		to_chat(user, span_warning("DBG: get_open_ui returned null"))
		return
	to_chat(user, span_notice("DBG: ui found, calling send_full_update"))
	ui.send_full_update(force = TRUE, always_instant = TRUE)

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
