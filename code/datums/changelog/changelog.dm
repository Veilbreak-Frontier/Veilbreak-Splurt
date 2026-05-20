/datum/changelog
	// Caches for each archive type (prevents regenerating assets multiple times)
	var/static/list/tg_assets = list()      // html/changelogs/archive/
	var/static/list/bubber_assets = list()  // html/changelogs/bubber_archive/
	var/static/list/splurt_assets = list()  // html/changelogs/splurt_archive/
	var/static/list/veilbreak_assets = list() // html/changelogs/veilbreak_archive/

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

		// Base /tg/ changelog (archive/)
		var/datum/asset/changelog_item/base_item = tg_assets[date]
		if (!base_item)
			base_item = new /datum/asset/changelog_item(date, "archive")
			tg_assets[date] = base_item
		ui.send_asset(base_item)

		// Bubber changelog (bubber_archive/)
		var/datum/asset/changelog_item/bubber_item = bubber_assets[date]
		if (!bubber_item)
			bubber_item = new /datum/asset/changelog_item(date, "bubber_archive")
			bubber_assets[date] = bubber_item
		ui.send_asset(bubber_item)

		// Splurt changelog (splurt_archive/)
		var/datum/asset/changelog_item/splurt_item = splurt_assets[date]
		if (!splurt_item)
			splurt_item = new /datum/asset/changelog_item(date, "splurt_archive")
			splurt_assets[date] = splurt_item
		ui.send_asset(splurt_item)

		// Veilbreak changelog (veilbreak_archive/)
		var/datum/asset/changelog_item/veilbreak_item = veilbreak_assets[date]
		if (!veilbreak_item)
			veilbreak_item = new /datum/asset/changelog_item(date, "veilbreak_archive")
			veilbreak_assets[date] = veilbreak_item
		ui.send_asset(veilbreak_item)

		return

/datum/changelog/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/simple/server_logos))

/datum/changelog/ui_static_data()
	var/list/data = list("dates" = list())
	var/regex/ymlRegex = regex(@"\.yml", "g")
	var/list/all_files = list()
	all_files |= flist("html/changelogs/archive/")
	all_files |= flist("html/changelogs/bubber_archive/")
	all_files |= flist("html/changelogs/splurt_archive/")
	all_files |= flist("html/changelogs/veilbreak_archive/")

	for(var/archive_file in sort_list(all_files))
		var/archive_date = ymlRegex.Replace(archive_file, "")
		data["dates"] = list(archive_date) + data["dates"]

	return data
