/datum/changelog
	var/static/list/changelog_items = list()
	var/static/list/bubber_items = list()
	var/static/list/splurt_items = list()
	var/static/list/veilbreak_items = list() // VEILBREAK ADDITION

/datum/changelog/ui_state()
	return GLOB.always_state

/datum/changelog/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "BubberChangelog")
		ui.open()

/datum/changelog/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(action == "get_month")
		var/date = params["date"]

		// Base /tg/ changelog
		var/datum/asset/changelog_item/base_item = changelog_items[date]
		if (!base_item)
			base_item = new /datum/asset/changelog_item(date, "archive")
			changelog_items[date] = base_item
		ui.send_asset(base_item)

		// Bubber changelog
		var/bubber_key = "bubber_[date]"
		var/datum/asset/changelog_item/bubber_item = bubber_items[bubber_key]
		if (!bubber_item)
			bubber_item = new /datum/asset/changelog_item(date, "bubber_archive")
			bubber_items[bubber_key] = bubber_item
		ui.send_asset(bubber_item)

		// Splurt changelog
		var/splurt_key = "splurt_[date]"
		var/datum/asset/changelog_item/splurt_item = splurt_items[splurt_key]
		if (!splurt_item)
			splurt_item = new /datum/asset/changelog_item(date, "splurt_archive")
			splurt_items[splurt_key] = splurt_item
		ui.send_asset(splurt_item)

		// Veilbreak changelog
		var/veilbreak_key = "veilbreak_[date]"
		var/datum/asset/changelog_item/veilbreak_item = veilbreak_items[veilbreak_key]
		if (!veilbreak_item)
			veilbreak_item = new /datum/asset/changelog_item(date, "veilbreak_archive") // VEILBREAK ADDITION
			veilbreak_items[veilbreak_key] = veilbreak_item
		ui.send_asset(veilbreak_item)

		return

// BUBBER EDIT CHANGE BEGIN: Changelog 2
/datum/changelog/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/server_logos)
	)
// BUBBER EDIT CHANGE END: Changelog 2

/datum/changelog/ui_static_data()
	var/list/data = list( "dates" = list() )
	var/regex/ymlRegex = regex(@"\.yml", "g")
	// BUBBER EDIT ADDITION BEGIN: Changelog 2
	var/list/tg_files = flist("html/changelogs/archive/")
	var/list/bubber_files = flist("html/changelogs/bubber_archive/")
	// BUBBER EDIT ADDITION END: Changelog 2
	// SPLURT EDIT ADDITION BEGIN: Changelog 3
	var/list/splurt_files = flist("html/changelogs/splurt_archive/")
	// SPLURT EDIT ADDITION END: Changelog 3
	// VEILBREAK ADDITION BEGIN: Changelog 4
	var/list/veilbreak_files = flist("html/changelogs/veilbreak_archive/")
	// VEILBREAK ADDITION END: Changelog 4

	for(var/archive_file in sort_list(tg_files |= bubber_files | splurt_files | veilbreak_files))
		var/archive_date = ymlRegex.Replace(archive_file, "")
		data["dates"] = list(archive_date) + data["dates"]

	return data
