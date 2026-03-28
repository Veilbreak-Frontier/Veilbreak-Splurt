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
		if(!QDELETED(P))
			linked_portal = P
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
	data["portal_name"] = linked_portal?.name
	if(V)
		data["generation_status"] = V.generating ? "generating" : (V.generated ? "stable" : "idle")
		data["current_target"] = list("name" = V.generated ? V.name : "0")
	else
		data["generation_status"] = "idle"
		data["current_target"] = null
	return data

/obj/machinery/computer/portal_control/ui_act(action, list/params, datum/tgui/ui)
	if(..())
		return
	switch(action)
		if("generate_new")
			if(generation_in_progress || !linked_portal)
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
				V.cleanup_z_level_completely(V.dungeon_z_level, linked_portal.loc)
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
