// UI data container for tattoo kit
/datum/custom_tattoo_ui_data
	var/zone = ""
	var/artist_name = ""
	var/tattoo_design = ""
	var/selected_layer = CUSTOM_TATTOO_LAYER_NORMAL
	var/selected_font = PEN_FONT
	var/selected_flair = null
	var/ink_color = "#404040" // Changed from #000000 for better visibility
	var/design_mode = FALSE
	var/debug_mode = FALSE

	New(new_zone = "")
		zone = new_zone
		ink_color = "#404040" // Ensure visible default color

	proc/clear()
		artist_name = ""
		tattoo_design = ""
		selected_layer = CUSTOM_TATTOO_LAYER_NORMAL
		selected_font = PEN_FONT
		selected_flair = null
		ink_color = "#404040" // Reset to visible default
		design_mode = FALSE

	proc/is_ready_for_application()
		return zone && design_mode && artist_name && tattoo_design

// UI Interface using the older ui_interact system
/obj/item/custom_tattoo_kit/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TattooKit")
		ui.open()

/obj/item/custom_tattoo_kit/ui_data(mob/user)
	var/list/data = list()
	var/list/available_parts

	// Basic info
	data["target_name"] = current_target ? current_target.name : "No Target"
	data["ink_uses"] = ink_uses
	data["max_ink_uses"] = max_ink_uses
	data["applying"] = (world.time < next_use)
	data["default_ink_color"] = "#404040" // Ensure visible default

	// Get or create UI data
	var/datum/custom_tattoo_ui_data/ui_data = current_target?.get_tattoo_ui_data("global")
	if(!ui_data && current_target)
		ui_data = new()
		current_target.set_tattoo_ui_data("global", ui_data)

	if(ui_data)
		data["artist_name"] = ui_data.artist_name
		data["tattoo_design"] = ui_data.tattoo_design
		data["selected_zone"] = ui_data.zone
		data["selected_layer"] = ui_data.selected_layer
		data["selected_font"] = ui_data.selected_font
		data["selected_flair"] = ui_data.selected_flair
		data["ink_color"] = ui_data.ink_color
		data["design_mode"] = ui_data.design_mode
	else
		data["artist_name"] = ""
		data["tattoo_design"] = ""
		data["selected_zone"] = ""
		data["selected_layer"] = CUSTOM_TATTOO_LAYER_NORMAL
		data["selected_font"] = PEN_FONT
		data["selected_flair"] = null
		data["ink_color"] = "#404040" // Visible default
		data["design_mode"] = FALSE

	// Options
	data["font_options"] = list(
		list("name" = "Pen", "value" = "PEN_FONT"),
		list("name" = "Fountain Pen", "value" = "FOUNTAIN_PEN_FONT"),
		list("name" = "Printer", "value" = "PRINTER_FONT"),
		list("name" = "Charcoal", "value" = "CHARCOAL_FONT"),
		list("name" = "Crayon", "value" = "CRAYON_FONT")
	)

	data["flair_options"] = list(
		list("name" = "No Flair", "value" = null),
		list("name" = "Pink Flair", "value" = "pink"),
		list("name" = "Love Flair", "value" = "userlove"),
		list("name" = "Brown Flair", "value" = "brown"),
		list("name" = "Cyan Flair", "value" = "cyan"),
		list("name" = "Orange Flair", "value" = "orange"),
		list("name" = "Yellow Flair", "value" = "yellow"),
		list("name" = "Subtle Flair", "value" = "subtle"),
		list("name" = "Velvet Flair", "value" = "velvet"),
		list("name" = "Velvet Notice", "value" = "velvet_notice"),
		list("name" = "Glossy Flair", "value" = "glossy")
	)

	data["layer_options"] = list(
		list("name" = "Under (Bottom)", "value" = 1),
		list("name" = "Normal (Middle)", "value" = 2),
		list("name" = "Over (Top)", "value" = 3)
	)

	// Body parts
	data["body_parts"] = list()
	if(current_target)
		available_parts = get_all_custom_tattoo_body_parts(current_target)

	if(islist(available_parts))
		for(var/zone_key in available_parts)
			var/list/part_info = available_parts[zone_key]
			if(!islist(part_info))
				continue

			data["body_parts"] += list(list(
				"zone" = zone_key,
				"name" = part_info["name"] || "Unknown",
				"covered" = part_info["covered"] ? 1 : 0,
				"current_tattoos" = part_info["current_tattoos"] || 0,
				"max_tattoos" = part_info["max_tattoos"] || 3
			))

	// Existing tattoos (gather across all body parts for UI parity)
	data["existing_tattoos"] = list()
	if(current_target && islist(available_parts))
		for(var/zone_key in available_parts)
			var/list/tattoos = current_target.get_custom_tattoos(zone_key)
			if(!islist(tattoos))
				continue

			var/list/zone_part_info = available_parts[zone_key]
			var/zone_name = islist(zone_part_info) ? (zone_part_info["name"] || "Unknown") : "Unknown"
			var/tattoo_index = 1

			for(var/datum/custom_tattoo/T in tattoos)
				if(!istype(T) || QDELETED(T))
					continue

				data["existing_tattoos"] += list(list(
					"zone" = zone_key,
					"zone_name" = zone_name,
					"artist" = T.artist || "Unknown",
					"design" = T.design || "Unknown",
					"color" = T.color || "#404040",
					"layer" = T.layer || 2,
					"font" = T.font || "PEN_FONT",
					"flair" = T.flair,
					"date" = T.date_applied || "Unknown",
					"index" = tattoo_index
				))
				tattoo_index++

	// UI Settings for TGUI compatibility
	data["window_width"] = 600
	data["window_height"] = 700
	data["input_height"] = 30
	data["button_height"] = 40
	data["color_swatch_size"] = 25
	data["max_design_length"] = 100
	data["max_artist_length"] = 50

	data["button_sizes"] = list(
		"small" = list("width" = 80, "height" = 25),
		"medium" = list("width" = 120, "height" = 30),
		"large" = list("width" = 200, "height" = 40)
	)

	data["error_colors"] = list(
		"warning" = "#ff4444",
		"success" = "#44ff44",
		"info" = "#4444ff"
	)

	// Pagination (simplified for now)
	data["current_body_part_page"] = 1
	data["body_part_total_pages"] = 1
	data["body_parts_per_page"] = 8

	return data

/obj/item/custom_tattoo_kit/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	var/mob/user = usr
	var/datum/custom_tattoo_ui_data/ui_data = current_target?.get_tattoo_ui_data("global")
	if(!ui_data && current_target)
		ui_data = new()
		current_target.set_tattoo_ui_data("global", ui_data)

	if(!ui_data)
		return

	if(action == "set_artist_name")
		action = "set_artist"
	else if(action == "set_tattoo_design")
		action = "set_design"

	switch(action)
		if("select_zone")
			var/zone = params["zone"]
			if(current_target && is_custom_tattoo_bodypart_existing(current_target, zone))
				ui_data.zone = zone
				ui_data.design_mode = TRUE
				. = TRUE

		if("back")
			ui_data.design_mode = FALSE
			. = TRUE

		if("set_artist")
			var/new_artist = params["value"]
			if(!istext(new_artist))
				new_artist = ""
			var/limit = min(51, length(new_artist) + 1)
			ui_data.artist_name = copytext(new_artist, 1, limit)
			. = TRUE

		if("set_design")
			var/new_design = params["value"]
			if(!istext(new_design))
				new_design = ""
			var/limit = min(257, length(new_design) + 1)
			ui_data.tattoo_design = copytext(new_design, 1, limit)
			. = TRUE

		if("set_font")
			ui_data.selected_font = params["value"]
			. = TRUE

		if("set_flair")
			ui_data.selected_flair = params["value"]
			. = TRUE

		if("set_layer")
			ui_data.selected_layer = text2num(params["value"])
			. = TRUE

		if("set_color")
			var/new_color = params["value"]
			// Validate color visibility
			if(is_color_readable(new_color))
				ui_data.ink_color = new_color
			else
				ui_data.ink_color = "#404040" // Fallback to visible color
			. = TRUE

		if("pick_color")
			var/new_color = input(user, "Choose ink color:", "Tattoo Kit", ui_data.ink_color) as color|null
			if(new_color)
				// Validate color visibility
				if(is_color_readable(new_color))
					ui_data.ink_color = new_color
				else
					ui_data.ink_color = "#404040" // Fallback to visible color
					to_chat(user, span_warning("Color too dark for visibility, using default gray."))
				. = TRUE

		if("toggle_design_mode")
			if(!ui_data.zone)
				return
			ui_data.design_mode = !ui_data.design_mode
			. = TRUE

		if("apply")
			if(can_apply_tattoo(user))
				apply_tattoo(user)
				. = TRUE

		if("remove")
			var/index = text2num(params["index"])
			var/remove_zone = params["zone"]
			if(!istext(remove_zone) || !remove_zone)
				remove_zone = ui_data.zone

			if(current_target && remove_zone)
				var/list/tattoos = current_target.get_custom_tattoos(remove_zone)
				if(index > 0 && index <= length(tattoos))
					var/datum/custom_tattoo/tattoo = tattoos[index]
					if(current_target.remove_custom_tattoo(tattoo))
						to_chat(user, span_green("Tattoo removed!"))
						. = TRUE

		if("refill")
			refill_ink(user)
			. = TRUE

	if(. && current_target)
		current_target.set_tattoo_ui_data("global", ui_data)
		SStgui.update_uis(src)
