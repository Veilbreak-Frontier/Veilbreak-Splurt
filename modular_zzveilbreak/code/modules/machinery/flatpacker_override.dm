#define CREATE_AND_INCREMENT(L, I, increment) if(!(I in L)) { L[I] = 0; } L[I] += increment;

/datum/remote_materials/flatpacker
	check_z_level(obj/silo_to_check)
		return TRUE

	_PrepareStorage(connect_to_silo)
		. = ..()
		update_parent_materials()

	disconnect()
		. = ..()
		update_parent_materials()

	OnMultitool(datum/source, mob/user, obj/item/multitool/M)
		. = ..()
		if(. != ITEM_INTERACT_BLOCKING)
			update_parent_materials()

	proc/update_parent_materials()
		var/obj/machinery/flatpacker/P = parent
		if(istype(P))
			P.materials = mat_container

/obj/machinery/flatpacker
	var/datum/remote_materials/remote
	var/list/chosen_component_types = list()

/obj/machinery/flatpacker/Initialize(mapload)
	. = ..()
	remote = new /datum/remote_materials/flatpacker(src, FALSE, TRUE, TRUE, NONE, list(COMSIG_MATCONTAINER_ITEM_CONSUMED = TYPE_PROC_REF(/obj/machinery/flatpacker, AfterMaterialInsert)))
	materials = remote.mat_container

/obj/machinery/flatpacker/Destroy()
	QDEL_NULL(remote)
	materials = null
	QDEL_NULL(inserted_board)
	QDEL_LIST(flatpacked_components)
	chosen_component_types = list()
	needed_mats.Cut()
	return ..()

/obj/machinery/flatpacker/RefreshParts()
	. = ..()
	if(remote && !remote.silo)
		var/mat_capacity = 0
		for(var/datum/stock_part/matter_bin/new_matter_bin in component_parts)
			mat_capacity += new_matter_bin.tier * 25 * SHEET_MATERIAL_AMOUNT
		remote.local_size = mat_capacity
		if(remote.mat_container)
			remote.mat_container.max_amount = mat_capacity

/obj/machinery/flatpacker/proc/get_physical_type(stock_part_datum_type)
	PRIVATE_PROC(TRUE)
	var/datum/stock_part/part = GLOB.stock_part_datums_per_object[stock_part_datum_type]
	if(part && part.physical_object_type)
		return part.physical_object_type
	var/datum/stock_part/as_part = stock_part_datum_type
	return initial(as_part.physical_object_type)

/obj/machinery/flatpacker/proc/get_tiered_variants(base_type)
	PRIVATE_PROC(TRUE)
	var/list/variants = list()
	var/actual_base = base_type
	if(ispath(base_type, /datum/stock_part))
		actual_base = get_physical_type(base_type)
		if(!actual_base)
			return variants
	for(var/typepath in subtypesof(actual_base))
		var/datum/stock_part/part = GLOB.stock_part_datums_per_object[typepath]
		if(part && part.tier > 0)
			variants[typepath] = part.tier
	return variants

/obj/machinery/flatpacker/proc/get_variant_for_tier(variants, target_tier)
	var/best_type = null
	var/best_tier = 0
	for(var/typepath in variants)
		var/datum/stock_part/part = GLOB.stock_part_datums_per_object[typepath]
		var/tier = part ? part.tier : 0
		if(tier == target_tier)
			return typepath
		if(tier < target_tier && tier > best_tier)
			best_tier = tier
			best_type = typepath
	if(best_type)
		return best_type
	return variants[1]

/obj/machinery/flatpacker/proc/get_base_component_type(component_type)
	if(ispath(component_type, /datum/stock_part))
		return get_physical_type(component_type) || component_type
	if(ispath(component_type, /obj/item))
		return component_type
	for(var/obj/item/typepath as anything in GLOB.stock_part_datums_per_object)
		var/datum/stock_part/part = GLOB.stock_part_datums_per_object[typepath]
		if(part && part.type == component_type)
			return typepath
	return component_type

/obj/machinery/flatpacker/base_item_interaction(mob/living/user, obj/item/attacking_item, list/modifiers)
	if(attacking_item.flags_1 & HOLOGRAM_1)
		return ITEM_INTERACT_SKIP_TO_ATTACK

	if(istype(attacking_item, /obj/item/circuitboard/machine))
		if(busy)
			balloon_alert(user, "busy!")
			return ITEM_INTERACT_BLOCKING
		if(!user.transferItemToLoc(attacking_item, src))
			return ITEM_INTERACT_BLOCKING

		if(inserted_board)
			inserted_board.forceMove(drop_location())
		inserted_board = attacking_item

		var/list/required_components = inserted_board.req_components
		var/list/component_variants = list()
		var/max_possible_tier = max_part_tier

		for(var/comp_type in required_components)
			var/physical_type = get_base_component_type(comp_type)
			var/list/variants = get_tiered_variants(physical_type)
			if(length(variants))
				component_variants[physical_type] = variants
				var/highest_tier = 0
				for(var/t in variants)
					var/datum/stock_part/part = GLOB.stock_part_datums_per_object[t]
					var/tier = part ? part.tier : 0
					if(tier > highest_tier)
						highest_tier = tier
				max_possible_tier = min(max_possible_tier, highest_tier)
			else
				var/use_type = physical_type || comp_type
				component_variants[use_type] = list(use_type)

		var/selected_tier = 0
		var/list/best_components = list()
		var/list/best_mats = list()
		for(var/tier in max_possible_tier to 1 step -1)
			var/list/tier_components = list()
			var/list/temp_mats = list()
			CREATE_AND_INCREMENT(temp_mats, /datum/material/iron, SHEET_MATERIAL_AMOUNT * 5 + SHEET_MATERIAL_AMOUNT / 20)
			CREATE_AND_INCREMENT(temp_mats, /datum/material/glass, SHEET_MATERIAL_AMOUNT / 20)

			for(var/base_type in component_variants)
				var/list/variants = component_variants[base_type]
				var/chosen_type = variants[1]
				if(length(variants) > 1)
					chosen_type = get_variant_for_tier(variants, tier)
				analyze_cost(chosen_type, temp_mats, required_components[base_type])
				tier_components[chosen_type] = required_components[base_type]

			if(materials.has_materials(temp_mats, creation_efficiency))
				selected_tier = tier
				best_components = tier_components
				best_mats = temp_mats
				break

		if(!selected_tier)
			for(var/base_type in component_variants)
				var/list/variants = component_variants[base_type]
				var/chosen_type = variants[1]
				analyze_cost(chosen_type, best_mats, required_components[base_type])
				best_components[chosen_type] = required_components[base_type]
			CREATE_AND_INCREMENT(best_mats, /datum/material/iron, SHEET_MATERIAL_AMOUNT * 5 + SHEET_MATERIAL_AMOUNT / 20)
			CREATE_AND_INCREMENT(best_mats, /datum/material/glass, SHEET_MATERIAL_AMOUNT / 20)

		chosen_component_types = best_components
		needed_mats = best_mats

		QDEL_LIST(flatpacked_components)
		inserted_board.flatpack_components = list()

		update_appearance(UPDATE_OVERLAYS)
		return ITEM_INTERACT_SUCCESS

	if(!QDELETED(inserted_board))
		for(var/comp_type in inserted_board.req_components)
			var/check_type = comp_type
			if(ispath(comp_type, /datum/stock_part))
				check_type = get_physical_type(comp_type)
			if(istype(attacking_item, check_type))
				balloon_alert(user, "components are auto-produced from materials")
				return ITEM_INTERACT_BLOCKING

	return ..()

/obj/machinery/flatpacker/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("build")
			if(busy)
				return
			if(QDELETED(inserted_board))
				return
			if(print_tier > max_part_tier)
				say("Design too complex.")
				return
			if(!materials.has_materials(needed_mats, creation_efficiency))
				say("Not enough materials to begin production.")
				return
			playsound(src, 'sound/items/tools/rped.ogg', 50, TRUE)
			busy = TRUE
			flick_overlay_view(mutable_appearance('icons/obj/machines/lathes.dmi', "flatpacker_bar"), flatpack_time)
			addtimer(CALLBACK(src, PROC_REF(finish_build), inserted_board, ui.user), flatpack_time)
			return TRUE
		if("ejectBoard")
			try_put_in_hand(inserted_board, ui.user)
			QDEL_LIST(flatpacked_components)
			chosen_component_types = list()
			needed_mats.Cut()
			return TRUE
		if("eject")
			if(!materials)
				return
			var/datum/material/material = locate(params["ref"])
			if(!istype(material))
				return
			var/amount = text2num(params["amount"])
			if(isnull(amount))
				return
			if(!directly_use_energy(ROUND_UP((amount / MAX_STACK_SIZE) * 0.4 * initial(active_power_usage))))
				say("No power to dispense sheets")
				return
			remote.eject_sheets(material, amount, drop_target = drop_location(), user_data = ID_DATA(ui.user))
			return TRUE
		else
			return ..()

/obj/machinery/flatpacker/click_ctrl(mob/user)
	if(QDELETED(inserted_board) || busy)
		return CLICK_ACTION_BLOCKING
	try_put_in_hand(inserted_board, user)
	QDEL_LIST(flatpacked_components)
	chosen_component_types = list()
	needed_mats.Cut()
	return CLICK_ACTION_SUCCESS

/obj/machinery/flatpacker/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == inserted_board)
		inserted_board = null
		chosen_component_types = list()
		needed_mats.Cut()
	if(gone in flatpacked_components)
		flatpacked_components -= gone

/obj/machinery/flatpacker/finish_build(board, mob/user)
	busy = FALSE

	if(!inserted_board)
		return

	var/obj/machinery/build_machine = initial(inserted_board.build_path)
	var/build_name = initial(build_machine.name) || "machine"

	if(!remote.use_materials(needed_mats, creation_efficiency, 1, "build", build_name, user_data = ID_DATA(user)))
		say("Material consumption failed!")
		return

	var/obj/item/flatpack/box = new (drop_location(), inserted_board)

	for(var/obj/item/component_type as anything in chosen_component_types)
		var/actual_type = component_type
		if(ispath(component_type, /datum/stock_part))
			actual_type = get_physical_type(component_type) || component_type
		var/amount_needed = chosen_component_types[component_type]
		for(var/i in 1 to amount_needed)
			new actual_type(box)

	chosen_component_types = list()
	SStgui.update_uis(src)

#undef CREATE_AND_INCREMENT
