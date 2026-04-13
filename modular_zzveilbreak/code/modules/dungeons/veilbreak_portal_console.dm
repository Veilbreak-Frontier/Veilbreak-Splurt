/obj/machinery/computer/portal_control
	name = "portal control console"
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "computer"
	var/obj/machinery/portal/linked_portal
	var/generation_in_progress = FALSE

/obj/machinery/computer/portal_control/Initialize(mapload)
	. = ..()
	try_to_linkup()

/obj/machinery/computer/portal_control/proc/try_to_linkup()
	for(var/obj/machinery/portal/P in orange(3, src))
		if(QDELETED(P) || P.is_dungeon_portal)
			continue
		linked_portal = P
		resync_veilbreak_portals_if_active()
		return TRUE
	return FALSE

/obj/machinery/computer/portal_control/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PortalControl", name)
		ui.open()

/obj/machinery/computer/portal_control/ui_data(mob/user)
	var/list/data = list()
	var/datum/portal_destination/veilbreak/V = linked_portal?.target
	data["portal_present"] = !!linked_portal
	data["portal_active"] = linked_portal?.transport_active
	data["portal_status"] = (linked_portal && (linked_portal.machine_stat & (NOPOWER|BROKEN)) == 0 && linked_portal.anchored)
	data["generation_in_progress"] = generation_in_progress
	data["cleanup_in_progress"] = V?.cleanup_in_progress || FALSE
	data["generation_progress"] = V?.generation_progress || 0
	data["can_generate"] = (linked_portal && !generation_in_progress && (!V || !V.generated))
	// Pocket title from destination (map_name); avoid dungeon map portal /obj names in the UI.
	var/display_name = linked_portal?.name
	if(istype(V, /datum/portal_destination/veilbreak) && V.connected_control_computer == src && (V.generated || V.generating || generation_in_progress))
		display_name = V.name
	data["portal_name"] = display_name
	if(V)
		data["generation_status"] = V.generating ? "generating" : (V.generated ? "stable" : "idle")
		data["current_target"] = list("name" = (V.generated || V.generating || generation_in_progress) ? V.name : "0")
	else
		data["generation_status"] = "idle"
		data["current_target"] = null
	return data

/obj/machinery/computer/portal_control/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	switch(action)
		if("linkup")
			var/found = rescan_for_portal()
			if(found)
				say("Dimensional matrix synchronized with hardware.")
			else
				say("No compatible portal signature detected in local range.")
			return TRUE
		if("deactivate")
			if(linked_portal && linked_portal.transport_active)
				var/datum/portal_destination/veilbreak/V = linked_portal.target
				if(V)
					V.cleanup_z_level_completely(V.dungeon_z_level, get_step(linked_portal, SOUTH))
					V.generated = FALSE
					V.generating = FALSE
					V.current_request_id = 0
					V.spawn_station_portal = null
					linked_portal.target = null
					qdel(V)
				linked_portal.transport_active = FALSE
				linked_portal.update_appearance()
			generation_in_progress = FALSE
			return TRUE
		if("generate_new")
			if(generation_in_progress || !linked_portal || linked_portal.transport_active)
				return TRUE
			var/datum/portal_destination/veilbreak/V = new()
			V.connected_control_computer = src
			linked_portal.target = V
			if(!V.start_generation(usr))
				linked_portal.target = null
				qdel(V)
				return TRUE
			generation_in_progress = TRUE
			return TRUE
		if("recalibrate")
			var/datum/portal_destination/veilbreak/V = linked_portal?.target
			if(V && V.generated)
				V.cleanup_z_level_completely(V.dungeon_z_level, get_step(linked_portal, SOUTH))
			return TRUE
	return FALSE

/obj/machinery/computer/portal_control/proc/on_generation_success()
	generation_in_progress = FALSE
	playsound(src, 'sound/machines/ping.ogg', 50, TRUE)
	if(linked_portal)
		linked_portal.transport_active = TRUE
		linked_portal.update_appearance()

/obj/machinery/computer/portal_control/proc/on_generation_failed(reason)
	generation_in_progress = FALSE
	say("Stabilization Error: [reason]")
	playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 50, TRUE)

/obj/machinery/computer/portal_control/proc/rescan_for_portal()
	var/obj/machinery/portal/found_portal
	for(var/obj/machinery/portal/P in range(3, src))
		if(QDELETED(P) || P.is_dungeon_portal || (P.machine_stat & (BROKEN|NOPOWER)))
			continue
		found_portal = P
		break

	if(found_portal)
		linked_portal = found_portal
		found_portal.linked_console = src
		var/datum/portal_destination/veilbreak/V = found_portal.target
		if(!V || !V.generated)
			found_portal.transport_active = FALSE
		return TRUE
	return FALSE

/// If a pocket is already open, re-bind return portals after the console finds a different linked portal.
/obj/machinery/computer/portal_control/proc/resync_veilbreak_portals_if_active()
	var/datum/portal_destination/veilbreak/V = linked_portal?.target
	if(!istype(V) || !V.generated || !V.dungeon_z_level)
		return
	V.spawn_station_portal = linked_portal
	V.veilbreak_sync_portal_pair()
