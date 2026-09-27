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
	world.log << "OPERATING-DBG: ui_interact ENTER user=[user] ref=[REF(user)] ui_arg=[ui]"
	to_chat(user, span_notice("OPERATING-DBG: ui_interact ENTER ui_arg=[ui]"))
	if(ishuman(user))
		world.log << "OPERATING-DBG: registering signal on [REF(user)]"
		to_chat(user, span_notice("OPERATING-DBG: registering signal on [REF(user)]"))
		RegisterSignal(user, COMSIG_MOB_SELECTED_ZONE_SET, PROC_REF(on_user_zone_changed), override = TRUE)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	world.log << "OPERATING-DBG: after try_update_ui, ui=[ui]"
	to_chat(user, span_notice("OPERATING-DBG: after try_update_ui, ui=[ui ? "DATUM" : "NULL"]"))
	if(ui)
		world.log << "OPERATING-DBG: early return (suspended UI resumed)"
		to_chat(user, span_notice("OPERATING-DBG: early return, suspended UI resumed"))
		return
	world.log << "OPERATING-DBG: creating fresh UI"
	to_chat(user, span_notice("OPERATING-DBG: creating fresh UI"))
	ui = new(user, src, "OperatingComputer", name)
	ui.open()

/obj/machinery/computer/operating/ui_close(mob/user)
	world.log << "OPERATING-DBG: ui_close called user=[user] ref=[REF(user)]"
	to_chat(user, span_notice("OPERATING-DBG: ui_close called"))
	. = ..()
	to_chat(user, span_notice("OPERATING-DBG: unregistering signal from [REF(user)]"))
	UnregisterSignal(user, COMSIG_MOB_SELECTED_ZONE_SET)

/obj/machinery/computer/operating/proc/on_user_zone_changed(mob/user, new_zone)
	SIGNAL_HANDLER
	world.log << "OPERATING-DBG: signal fired, zone=[new_zone]"
	to_chat(user, span_notice("OPERATING-DBG: signal handler fired, zone=[new_zone]"))
	var/datum/tgui/ui = SStgui.get_open_ui(user, src)
	if(!ui)
		world.log << "OPERATING-DBG: get_open_ui returned null"
		to_chat(user, span_warning("OPERATING-DBG: get_open_ui returned null"))
		return
	ui.send_full_update(force = TRUE, always_instant = TRUE)
	world.log << "OPERATING-DBG: send_full_update dispatched"
	to_chat(user, span_notice("OPERATING-DBG: send_full_update dispatched"))

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

GAME_VERB(/mob, dbg_fire_zone_signal, "Debug: Fire Zone Signal", "Debug")
	world.log << "OPERATING-DBG: manual verb firing zone signal on [REF(src)]"
	to_chat(src, span_notice("OPERATING-DBG: manually firing COMSIG_MOB_SELECTED_ZONE_SET on ref [REF(src)]"))
	SEND_SIGNAL(src, COMSIG_MOB_SELECTED_ZONE_SET, zone_selected)
