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
	data["portal_status"] = (linked_portal && linked_portal.powered() && linked_portal.anchored)
	data["generation_in_progress"] = generation_in_progress
	data["cleanup_in_progress"] = V ? V.cleanup_in_progress : FALSE
	if(V)
		data["current_target"] = list("name" = V.name)
		data["generation_status"] = V.generating ? "generating" : "ready"
		data["generation_progress"] = V.generation_progress
		data["can_generate"] = !V.generating && !V.generated
	else
		data["generation_status"] = "offline"
		data["can_generate"] = !generation_in_progress
	return data

/obj/machinery/computer/portal_control/ui_act(action, list/params, datum/tgui/ui)
	if(..())
		return
	switch(action)
		if("generate_new")
			if(generation_in_progress)
				return TRUE
			if(!linked_portal || QDELETED(linked_portal))
				say("Error: No local dimensional portal detected.")
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
	return FALSE

/obj/machinery/computer/portal_control/proc/on_generation_success()
	generation_in_progress = FALSE
	playsound(src, 'sound/machines/ping.ogg', 50, TRUE)
	if(linked_portal)
		linked_portal.update_appearance()

/obj/machinery/computer/portal_control/proc/on_generation_failed(reason)
	generation_in_progress = FALSE
	say("Stabilization Error: [reason]")
	playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 50, TRUE)

/obj/item/circuitboard/computer/portal_control
	name = "Circuit board (Portal Control Console)"
	build_path = /obj/machinery/computer/portal_control

/datum/design/board/portal_control
	name = "Portal Control Console Board"
	desc = "Allows for the construction of circuit boards used to build a Portal Control Console."
	id = "portal_control"
	build_path = /obj/item/circuitboard/computer/portal_control
	category = list(RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_ENGINEERING)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING
