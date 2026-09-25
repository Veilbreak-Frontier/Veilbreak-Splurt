/datum/admins
	var/datum/instance_finder/instance_finder_datum
	var/datum/instance_list/instance_list_datum

ADMIN_VERB(instance_finder, R_SPAWN, "Instance Finder", "Search object types and view active instances in the game world.", ADMIN_CATEGORY_GAME)
	var/datum/admins/admin = user.holder
	if(!admin)
		return
	if(!admin.instance_finder_datum)
		admin.instance_finder_datum = new()
	admin.instance_finder_datum.ui_interact(user.mob)
	BLACKBOX_LOG_ADMIN_VERB("Instance Finder")

/// Datum controlling the Instance Finder search panel (TGUI)
/datum/instance_finder
	/// Currently selected object path
	var/selected_path = null

/datum/instance_finder/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "InstanceFinder")
		ui.open()

/datum/instance_finder/ui_state(mob/user)
	return ADMIN_STATE(R_SPAWN)

/datum/instance_finder/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/json/spawnpanel),
	)

/datum/instance_finder/ui_data(mob/user)
	var/list/data = list()
	data["selected_path"] = selected_path ? "[selected_path]" : ""
	return data

/datum/instance_finder/ui_act(action, params, datum/tgui/ui)
	if(..() || !check_rights_for(ui.user.client, R_SPAWN))
		return FALSE

	switch(action)
		if("selected-atom-changed")
			var/path_text = params["newObj"]
			if(path_text)
				var/path = text2path(path_text)
				if(path)
					selected_path = path
			return TRUE

		if("find-instances")
			var/target_path_text = params["path"] || (selected_path ? "[selected_path]" : null)
			if(!target_path_text)
				return TRUE
			var/path = text2path(target_path_text)
			if(!path)
				to_chat(ui.user, span_warning("Invalid path: [target_path_text]"))
				return TRUE

			selected_path = path

			var/datum/admins/admin_holder = ui.user.client?.holder
			if(!admin_holder)
				return TRUE

			if(!admin_holder.instance_list_datum)
				admin_holder.instance_list_datum = new /datum/instance_list()

			admin_holder.instance_list_datum.set_target_path(path)
			admin_holder.instance_list_datum.ui_interact(ui.user)
			return TRUE

/// Datum controlling the Instance List window (TGUI)
/datum/instance_list
	/// Target type path to list instances for
	var/target_path = null
	/// Target type name (initial name)
	var/target_path_name = ""

/datum/instance_list/proc/set_target_path(path)
	target_path = path
	if(ispath(path, /atom))
		var/atom/initial_atom = path
		target_path_name = initial(initial_atom.name) || "[path]"
	else
		target_path_name = "[path]"

/datum/instance_list/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "InstanceList")
		ui.open()

/datum/instance_list/ui_state(mob/user)
	return ADMIN_STATE(R_SPAWN)

/datum/instance_list/ui_data(mob/user)
	var/list/data = list()
	data["target_path"] = target_path ? "[target_path]" : ""
	data["target_path_name"] = target_path_name

	var/list/instances_data = list()
	if(target_path)
		var/list/all_instances = get_all_of_type(target_path)
		var/count = 0
		var/max_instances = 1000
		for(var/datum/thing as anything in all_instances)
			if(!thing)
				continue
			count++
			if(count > max_instances)
				break

			var/list/inst_info = list()
			inst_info["ref"] = REF(thing)
			inst_info["name"] = isatom(thing) ? (thing:name || "[thing.type]") : "[thing.type]"
			inst_info["type"] = "[thing.type]"

			if(isatom(thing))
				var/atom/A = thing
				var/turf/T = get_turf(A)
				var/area/ar = get_area(A)
				inst_info["area"] = ar ? ar.name : "Unknown Area"
				inst_info["coords"] = T ? "[T.x], [T.y], [T.z]" : "No Turf"
				inst_info["icon"] = A.icon ? "[A.icon]" : null
				inst_info["icon_state"] = A.icon_state ? "[A.icon_state]" : null

				if(A.loc && A.loc != T)
					inst_info["location_details"] = "Inside [A.loc]"
				else if(T)
					inst_info["location_details"] = "On Turf"
				else
					inst_info["location_details"] = "Nullspace"
			else
				inst_info["area"] = "N/A"
				inst_info["coords"] = "N/A"
				inst_info["location_details"] = "Datum"
				inst_info["icon"] = null
				inst_info["icon_state"] = null

			instances_data += list(inst_info)

		data["total_count"] = length(all_instances)
	else
		data["total_count"] = 0

	data["instances"] = instances_data
	return data

/datum/instance_list/ui_act(action, params, datum/tgui/ui)
	if(..() || !check_rights_for(ui.user.client, R_SPAWN))
		return FALSE

	switch(action)
		if("teleport")
			var/ref_str = params["ref"]
			if(!ref_str)
				return TRUE
			var/datum/target_datum = locate(ref_str)
			if(!target_datum)
				to_chat(ui.user, span_warning("Target object no longer exists."))
				return TRUE

			var/turf/T = get_turf(target_datum)
			if(!T)
				to_chat(ui.user, span_warning("Target object is in nullspace or has no turf."))
				return TRUE

			ui.user.abstract_move(T)
			log_admin("[key_name(ui.user)] teleported to [target_datum] ([AREACOORD(T)]) via Instance Finder")
			message_admins("[key_name_admin(ui.user)] teleported to [target_datum] ([AREACOORD(T)]) via Instance Finder")
			to_chat(ui.user, span_notice("Teleported to [target_datum] at [AREACOORD(T)]."))
			return TRUE

		if("vv")
			var/ref_str = params["ref"]
			if(!ref_str)
				return TRUE
			var/datum/target_datum = locate(ref_str)
			if(!target_datum)
				to_chat(ui.user, span_warning("Target object no longer exists."))
				return TRUE

			ui.user.client?.debug_variables(target_datum)
			return TRUE

		if("refresh")
			return TRUE
