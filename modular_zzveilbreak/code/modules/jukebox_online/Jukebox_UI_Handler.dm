/datum/online_jukebox_ui
	var/datum/online_jukebox/jukebox
	var/last_update = 0
	var/update_cooldown = 10

/datum/online_jukebox_ui/New(datum/online_jukebox/target_jukebox)
	jukebox = target_jukebox

/datum/online_jukebox_ui/Destroy()
	SStgui.close_uis(src)
	jukebox = null
	return ..()

/datum/online_jukebox_ui/ui_host(mob/user)
    return jukebox?.parent_atom || src

/datum/online_jukebox_ui/ui_state(mob/user)
	var/obj/machinery/jukebox/online/parent = jukebox?.parent_atom
	return parent?.ui_state(user) || GLOB.default_state

/datum/online_jukebox_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OnlineJukebox")
		ui.open()

/datum/online_jukebox_ui/ui_data(mob/user)
	if(!jukebox || QDELETED(jukebox))
		return list()

	var/list/data = jukebox.get_online_ui_data()
	var/obj/machinery/jukebox/online/parent_obj = jukebox.parent_atom

	if(istype(parent_obj) && parent_obj.music_player)
		var/datum/jukebox/legacy_player = parent_obj.music_player
		var/list/songs_data = list()
		for(var/song_name in legacy_player.songs)
			var/datum/track/one_song = legacy_player.songs[song_name]
			songs_data += list(list(
				"name" = song_name,
				"length" = DisplayTimeText(one_song.song_length),
				"beat" = one_song.song_beat_deciseconds,
			))
		data["songs"] = songs_data
		data["track_selected"] = legacy_player.selection?.song_name
	else
		data["songs"] = list()
		data["track_selected"] = null

	return data

/datum/online_jukebox_ui/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return TRUE
	if(!jukebox || QDELETED(jukebox))
		return FALSE

	if(isobserver(ui.user))
		var/mob/dead/observer/G = ui.user
		to_chat(G, span_warning("You can only monitor the jukebox as a ghost."))
		return TRUE

	var/mob/user = ui.user
	if(user && jukebox.parent_atom && get_dist(user, jukebox.parent_atom) > 1 && !isobserver(user))
		return FALSE
	switch(action)
		if("play_online", "download_url")
			var/url = params["url"]
			if(!url)
				jukebox.online_error_message = "No URL provided"
				update_ui()
				return TRUE
			var/list/validation = validate_jukebox_url(url)
			if(!validation["valid"])
				jukebox.online_error_message = validation["error"] || "Invalid URL"
				update_ui()
				return TRUE
			if(jukebox_api_healthy())
				GLOB.jukebox_api_handler.download_track_async(url, user, jukebox)
				jukebox.online_error_message = "Download started. Please wait..."
			else
				jukebox.online_error_message = "API is currently offline. Cannot download."
			update_ui()
			return TRUE

		if("play_library")
			var/url_hash = params["url_hash"]
			if(url_hash)
				jukebox.play_library_track(url_hash, user)
				update_ui()
				return TRUE

		if("stop_music")
			jukebox.stop_music()
			update_ui()
			return TRUE

		if("set_volume")
			var/vol = text2num(params["volume"])
			if(!isnull(vol))
				jukebox.set_new_volume(vol)
				update_ui()
				return TRUE

		if("set_loop")
			jukebox.sound_loops = !!params["looping"]
			if(jukebox.active_song_sound)
				jukebox.active_song_sound.repeat = jukebox.sound_loops
			update_ui()
			return TRUE

		if("refresh_library")
			load_jukebox_library()
			jukebox.online_error_message = jukebox_api_healthy() ? "Library refreshed and API is online" : "Library refreshed but API is offline"
			update_ui()
			return TRUE

	return FALSE

/datum/online_jukebox_ui/proc/update_ui()
	if(world.time < last_update + update_cooldown)
		return
	last_update = world.time
	SStgui.update_uis(src)


