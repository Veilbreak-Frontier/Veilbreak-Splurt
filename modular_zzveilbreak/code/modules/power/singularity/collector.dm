#define RAD_COLLECTOR_EFFICIENCY 80
#define RAD_COLLECTOR_COEFFICIENT 125
#define RAD_COLLECTOR_STORED_OUT 0.05
#define RAD_COLLECTOR_MINING_CONVERSION_RATE 0.00001
#define RAD_COLLECTOR_OUTPUT min(stored_power, (stored_power * RAD_COLLECTOR_STORED_OUT) + 1000)

/datum/gas_mixture/proc/get_moles(gas_id)
	return gases[gas_id] ? gases[gas_id][MOLES] : 0

/datum/gas_mixture/proc/adjust_moles(gas_id, amount)
	if(!amount)
		return
	assert_gas(gas_id)
	gases[gas_id][MOLES] = max(0, gases[gas_id][MOLES] + amount)
	garbage_collect(list(gas_id))

/obj/machinery/power/rad_collector
	name = "Radiation Collector Array"
	desc = "A device which uses Hawking Radiation and plasma to produce power."
	icon = 'modular_zzveilbreak/icons/obj/singularity.dmi'
	icon_state = "ca"
	anchored = FALSE
	density = TRUE
	req_access = list(ACCESS_ENGINE_EQUIP)
	max_integrity = 350
	integrity_failure = 0.2
	var/obj/item/tank/internals/plasma/loaded_tank = null
	var/stored_power = 0
	var/last_push = 0
	var/active = FALSE
	var/locked = FALSE
	var/drainratio = 1
	var/powerproduction_drain = 0.001
	var/bitcoinproduction_drain = 0.15
	var/bitcoinmining = FALSE
	rad_insulation = RAD_EXTREME_INSULATION
	var/obj/item/radio/Radio

/obj/machinery/power/rad_collector/anchored
	anchored = TRUE

/obj/machinery/power/rad_collector/Initialize(mapload)
	. = ..()
	Radio = new /obj/item/radio(src)
	Radio.listening = FALSE
	Radio.set_frequency(FREQ_ENGINEERING)
	RegisterSignal(src, COMSIG_IN_RANGE_OF_IRRADIATION, PROC_REF(on_irradiated))

/obj/machinery/power/rad_collector/Destroy()
	QDEL_NULL(Radio)
	return ..()

/obj/machinery/power/rad_collector/proc/on_irradiated(datum/source, datum/radiation_pulse_information/pulse_info, insulation)
	SIGNAL_HANDLER
	if(pulse_info)
		rad_act(pulse_info.chance * 5)

/obj/machinery/power/rad_collector/proc/rad_act(pulse_strength)
	if(loaded_tank && active && pulse_strength > RAD_COLLECTOR_EFFICIENCY)
		stored_power += (pulse_strength - RAD_COLLECTOR_EFFICIENCY) * RAD_COLLECTOR_COEFFICIENT

/obj/machinery/power/rad_collector/process()
	if(!loaded_tank || !active)
		return
	if(!bitcoinmining)
		if(loaded_tank.air_contents.get_moles(/datum/gas/plasma) < 0.0001)
			investigate_log("out of fuel.", INVESTIGATE_ENGINE)
			playsound(src, 'sound/machines/ding.ogg', 50, TRUE)
			if(Radio)
				Radio.talk_into(src, "Insufficient plasma in [get_area(src)] [src], ejecting \the [loaded_tank].", FREQ_ENGINEERING)
			eject()
		else
			var/gasdrained = min(powerproduction_drain * drainratio, loaded_tank.air_contents.get_moles(/datum/gas/plasma))
			loaded_tank.air_contents.adjust_moles(/datum/gas/plasma, -gasdrained)
			loaded_tank.air_contents.adjust_moles(/datum/gas/tritium, gasdrained)

			var/power_produced = RAD_COLLECTOR_OUTPUT
			add_avail(power_produced)
			stored_power -= power_produced
	else if(is_station_level(z))
		if(loaded_tank.air_contents.get_moles(/datum/gas/tritium) < 0.0001 || loaded_tank.air_contents.get_moles(/datum/gas/oxygen) < 0.0001)
			playsound(src, 'sound/machines/ding.ogg', 50, TRUE)
			if(Radio)
				Radio.talk_into(src, "Insufficient oxygen and tritium in [get_area(src)] [src] to produce research points, ejecting \the [loaded_tank].", FREQ_ENGINEERING)
			eject()
		else
			var/gasdrained = bitcoinproduction_drain * drainratio
			loaded_tank.air_contents.adjust_moles(/datum/gas/tritium, -gasdrained)
			loaded_tank.air_contents.adjust_moles(/datum/gas/oxygen, -gasdrained)
			loaded_tank.air_contents.adjust_moles(/datum/gas/carbon_dioxide, gasdrained * 2)
			var/bitcoins_mined = stored_power * RAD_COLLECTOR_MINING_CONVERSION_RATE
			var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_ENG)
			if(D)
				D.adjust_money(bitcoins_mined)
			var/datum/techweb/station_techweb = locate(/datum/techweb/science) in SSresearch.techwebs
			if(station_techweb)
				station_techweb.add_point_list(list(TECHWEB_POINT_TYPE_GENERIC = bitcoins_mined))
			last_push = stored_power
			stored_power = 0

/obj/machinery/power/rad_collector/interact(mob/user)
	if(anchored)
		if(!locked)
			toggle_power()
			user.visible_message("[user.name] turns the [src.name] [active ? "on" : "off"].", \
				span_notice("You turn the [src.name] [active ? "on" : "off"]."))
			var/fuel = loaded_tank ? loaded_tank.air_contents.get_moles(/datum/gas/plasma) : 0
			investigate_log("turned [active ? "<font color='green'>on</font>" : "<font color='red'>off</font>"] by [key_name(user)]. [loaded_tank ? "Fuel: [round(fuel/0.29)]%" : "<font color='red'>It is empty</font>"].", INVESTIGATE_ENGINE)
		else
			to_chat(user, span_warning("The controls are locked!"))

/obj/machinery/power/rad_collector/wrench_act(mob/living/user, obj/item/tool)
	if(loaded_tank)
		to_chat(user, span_warning("Remove the plasma tank first!"))
		return TRUE
	if(default_unfasten_wrench(user, tool))
		if(anchored)
			connect_to_network()
		else
			disconnect_from_network()
	return TRUE

/obj/machinery/power/rad_collector/screwdriver_act(mob/living/user, obj/item/tool)
	if(loaded_tank)
		to_chat(user, span_warning("Remove the plasma tank first!"))
		return TRUE
	return default_deconstruction_screwdriver(user, icon_state, icon_state, tool)

/obj/machinery/power/rad_collector/crowbar_act(mob/living/user, obj/item/tool)
	if(loaded_tank)
		if(locked)
			to_chat(user, span_warning("The controls are locked!"))
			return TRUE
		eject()
		return TRUE
	if(default_deconstruction_crowbar(tool))
		return TRUE
	to_chat(user, span_warning("There isn't a tank loaded!"))
	return TRUE

/obj/machinery/power/rad_collector/multitool_act(mob/living/user, obj/item/tool)
	if(!is_station_level(z))
		to_chat(user, span_warning("[src] isn't linked to a research system!"))
		return TRUE
	if(locked)
		to_chat(user, span_warning("[src] is locked!"))
		return TRUE
	if(active)
		to_chat(user, span_warning("[src] is currently active, producing [bitcoinmining ? "research points" : "power"]."))
		return TRUE
	bitcoinmining = !bitcoinmining
	to_chat(user, span_warning("You [bitcoinmining ? "enable" : "disable"] the research point production feature of [src]."))
	return TRUE

/obj/machinery/power/rad_collector/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/tank/internals/plasma))
		if(!anchored)
			to_chat(user, span_warning("[src] needs to be secured to the floor first!"))
			return TRUE
		if(loaded_tank)
			to_chat(user, span_warning("There's already a plasma tank loaded!"))
			return TRUE
		if(panel_open)
			to_chat(user, span_warning("Close the maintenance panel first!"))
			return TRUE
		if(!user.transferItemToLoc(W, src))
			return TRUE
		loaded_tank = W
		update_appearance()
		return TRUE
	else if(W.GetID())
		if(allowed(user))
			if(active)
				locked = !locked
				to_chat(user, span_notice("You [locked ? "lock" : "unlock"] the controls."))
			else
				to_chat(user, span_warning("The controls can only be locked when \the [src] is active!"))
		else
			to_chat(user, span_danger("Access denied."))
			return TRUE
	return ..()

/obj/machinery/power/rad_collector/examine(mob/user)
	. = ..()
	if(active)
		if(!bitcoinmining)
			. += span_notice("[src]'s display states that it has stored <b>[display_energy(stored_power)]</b>, and is processing <b>[display_power(RAD_COLLECTOR_OUTPUT)]</b>.<br>The <b>plasma</b> within its tank is being irradiated into <b>tritium</b>.")
		else
			. += span_notice("[src]'s display states that it's producing a total of <b>[(last_push * RAD_COLLECTOR_MINING_CONVERSION_RATE)*((60 SECONDS)/SSmachines.wait)]</b> research points per minute.<br>The <b>tritium</b> and <b>oxygen</b> within its tank is being combusted into <b>carbon dioxide</b>.")
	else
		if(!bitcoinmining)
			. += span_notice("<b>[src]'s display displays the words:</b> \"Power production mode. Please insert <b>Plasma</b>. Use a multitool to change production modes.\"")
		else
			. += span_notice("<b>[src]'s display displays the words:</b> \"Research point production mode. Please insert <b>Tritium</b> and <b>Oxygen</b>. Use a multitool to change production modes.\"")

/obj/machinery/power/rad_collector/proc/eject()
	locked = FALSE
	var/obj/item/tank/internals/plasma/Z = loaded_tank
	if(!Z)
		return
	Z.forceMove(drop_location())
	Z.layer = initial(Z.layer)
	Z.plane = initial(Z.plane)
	loaded_tank = null
	if(active)
		toggle_power()
	else
		update_appearance()

/obj/machinery/power/rad_collector/update_overlays()
	. = ..()
	if(loaded_tank)
		. += "ptank"
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if(active)
		. += "on"

/obj/machinery/power/rad_collector/proc/toggle_power()
	active = !active
	if(active)
		icon_state = "ca_on"
		flick("ca_active", src)
	else
		icon_state = "ca"
		flick("ca_deactive", src)
	update_appearance()

#undef RAD_COLLECTOR_EFFICIENCY
#undef RAD_COLLECTOR_COEFFICIENT
#undef RAD_COLLECTOR_STORED_OUT
#undef RAD_COLLECTOR_MINING_CONVERSION_RATE
#undef RAD_COLLECTOR_OUTPUT
