/obj/machinery/atmospherics/components/binary/mole_pump
	name = "mole pump"
	desc = "A binary device that pushes a specific amount of moles of gas before turning off."
	icon_state = "pump-off"
	can_unwrench = TRUE
	shift_underlay_only = FALSE
	construction_type = /obj/item/pipe/binary
	pipe_state = "pump"
	var/moles_to_transfer = 1000
	var/moles_transferred = 0
	var/max_moles_to_transfer = 10000

/obj/machinery/atmospherics/components/binary/mole_pump/Initialize(mapload)
	. = ..()
	register_context()

/obj/machinery/atmospherics/components/binary/mole_pump/click_ctrl(mob/user)
	if(can_interact(user))
		if(on)
			set_on(FALSE)
		else
			moles_transferred = 0
			set_on(TRUE)
		balloon_alert(user, "turned [on ? "on" : "off"]")
		investigate_log("was turned [on ? "on" : "off"] by [key_name(user)]", INVESTIGATE_ATMOS)
		return CLICK_ACTION_SUCCESS
	return CLICK_ACTION_BLOCKING

/obj/machinery/atmospherics/components/binary/mole_pump/attack_hand(mob/user)
	if(!can_interact(user))
		return ..()
	ui_interact(user)
	return CLICK_ACTION_SUCCESS

/obj/machinery/atmospherics/components/binary/mole_pump/update_icon_nopipes()
	icon_state = (on && is_operational) ? "pump-on[set_overlay_offset(piping_layer)]" : "pump-off[set_overlay_offset(piping_layer)]"

/obj/machinery/atmospherics/components/binary/mole_pump/process_atmos()
	if(!on || !is_operational)
		return
	if(moles_transferred >= moles_to_transfer)
		set_on(FALSE)
		return
	var/datum/gas_mixture/air1 = airs[1]
	var/datum/gas_mixture/air2 = airs[2]
	if(air1.total_moles() <= 0)
		return
	var/moles_to_move = min(moles_to_transfer - moles_transferred, air1.total_moles())
	if(moles_to_move <= 0)
		set_on(FALSE)
		return
	var/datum/gas_mixture/removed = air1.remove(moles_to_move)
	if(!removed || removed.total_moles() <= 0)
		return
	moles_transferred += removed.total_moles()
	air2.merge(removed)
	update_parents()
	if(moles_transferred >= moles_to_transfer)
		set_on(FALSE)

/obj/machinery/atmospherics/components/binary/mole_pump/can_unwrench(mob/user)
	. = ..()
	if(. && on && is_operational)
		to_chat(user, span_warning("You cannot unwrench [src], turn it off first!"))
		return FALSE

/obj/machinery/atmospherics/components/binary/mole_pump/layer1
	piping_layer = 1
	icon_state = "pump-off-1"

/obj/machinery/atmospherics/components/binary/mole_pump/layer2
	piping_layer = 2
	icon_state = "pump-off-2"

/obj/machinery/atmospherics/components/binary/mole_pump/layer4
	piping_layer = 4
	icon_state = "pump-off-4"

/obj/machinery/atmospherics/components/binary/mole_pump/layer5
	piping_layer = 5
	icon_state = "pump-off-5"

/obj/machinery/atmospherics/components/binary/mole_pump/on
	on = TRUE
	icon_state = "pump-on"

/obj/machinery/atmospherics/components/binary/mole_pump/on/layer1
	piping_layer = 1
	icon_state = "pump-on-1"

/obj/machinery/atmospherics/components/binary/mole_pump/on/layer2
	piping_layer = 2
	icon_state = "pump-on-2"

/obj/machinery/atmospherics/components/binary/mole_pump/on/layer4
	piping_layer = 4
	icon_state = "pump-on-4"

/obj/machinery/atmospherics/components/binary/mole_pump/on/layer5
	piping_layer = 5
	icon_state = "pump-on-5"

/obj/machinery/atmospherics/components/binary/mole_pump/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MolePump", name)
		ui.open()

/obj/machinery/atmospherics/components/binary/mole_pump/ui_data(mob/user)
	var/list/data = list()
	data["on"] = on
	data["moles_to_transfer"] = moles_to_transfer
	data["moles_transferred"] = moles_transferred
	data["max_moles_to_transfer"] = max_moles_to_transfer
	return data

/obj/machinery/atmospherics/components/binary/mole_pump/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("toggle_power")
			if(on)
				set_on(FALSE)
			else
				moles_transferred = 0
				set_on(TRUE)
			investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", INVESTIGATE_ATMOS)
			return TRUE
		if("set_moles")
			var/new_amount = text2num(params["moles"])
			if(!isnum(new_amount) || new_amount < 1 || new_amount > max_moles_to_transfer)
				to_chat(usr, span_warning("Invalid amount. Must be between 1 and [max_moles_to_transfer]."))
				return
			moles_to_transfer = new_amount
			return TRUE
