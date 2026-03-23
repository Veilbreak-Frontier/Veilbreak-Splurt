#define CHANNEL_ONLINE_JUKEBOX CHANNEL_JUKEBOX

#define MUTE_DEAF (1<<0)
#define MUTE_PREF (1<<1)
#define MUTE_RANGE (1<<2)

/datum/online_jukebox
	var/online_track_url
	var/online_track_name
	var/online_track_duration = 0
	var/online_track_hash
	var/playing_online = FALSE
	var/track_start_time = 0
	var/volume = 50
	var/sound_loops = FALSE
	var/sound/active_song_sound
	var/online_error_message = ""
	var/datum/online_jukebox_ui/ui
	var/atom/parent_atom
	var/last_ui_update = 0
	var/ui_update_cooldown = 10
	var/list/listeners = list()
	var/sound_range
	var/x_cutoff
	var/z_cutoff

/datum/online_jukebox/New(atom/new_parent)
	parent_atom = new_parent
	if(isnull(sound_range))
		sound_range = 15
		x_cutoff = 15
		z_cutoff = 15
	ui = new /datum/online_jukebox_ui(src)

	GLOB.online_jukeboxes += src

	if(!GLOB.jukebox_library_initialized)
		initialize_jukebox_library()

/datum/online_jukebox/Destroy()
	GLOB.online_jukeboxes -= src
	stop_music()
	QDEL_NULL(ui)

	if(listeners)
		for(var/mob/M in listeners)
			deregister_listener(M)
		listeners.Cut()
		listeners = null

	parent_atom = null
	return ..()

/datum/online_jukebox/proc/process_tick()
	if(!playing_online || QDELETED(src))
		return

	if(ui && (world.time >= last_ui_update + ui_update_cooldown))
		ui.update_ui()
		last_ui_update = world.time

	if(active_song_sound)
		update_all()

	if(world.time - track_start_time >= online_track_duration)
		if(!sound_loops)
			stop_music()
		else
			track_start_time = world.time

/datum/online_jukebox/proc/get_ui_handler()
	return ui

/datum/online_jukebox/proc/get_online_ui_data()
	var/list/data = list()
	data["online_track_url"] = online_track_url
	data["online_track_name"] = online_track_name
	data["online_track_duration"] = online_track_duration
	data["playing_online"] = playing_online
	data["track_progress"] = get_track_progress()
	data["online_error_message"] = online_error_message
	data["volume"] = volume
	data["sound_loops"] = sound_loops
	data["api_healthy"] = jukebox_api_healthy()
	data["active_song_sound"] = !!active_song_sound
	data["library_tracks"] = get_library_tracks_ui_data()
	data["library_stats"] = get_jukebox_library_stats()
	data["update_timestamp"] = world.time
	return data

/datum/online_jukebox/proc/get_track_progress()
	if(!playing_online || !online_track_duration || !track_start_time)
		return 0
	var/progress = world.time - track_start_time
	if(progress >= online_track_duration)
		if(sound_loops)
			return 0
		else
			return online_track_duration
	return progress

/datum/online_jukebox/proc/play_library_track_on_success(url_hash, mob/user)
	var/list/track_data = GLOB.jukebox_library_tracks[url_hash]
	if(!track_data)
		online_error_message = "Track downloaded but not found in library"
		ui?.update_ui()
		return FALSE
	online_error_message = ""
	return play_library_track(url_hash, user)

/datum/online_jukebox/proc/play_library_track(url_hash, mob/user)
	var/list/track_data = GLOB.jukebox_library_tracks[url_hash]
	if(!track_data)
		online_error_message = "Track not found in library"
		ui?.update_ui()
		return FALSE
	var/sounds_dir = get_jukebox_sounds_dir()
	var/sound_path = "[sounds_dir]/[url_hash].ogg"
	if(fexists(sound_path))
		return play_library_track_internal(url_hash, user)

	online_error_message = "Waiting for sound file..."
	ui?.update_ui()

	addtimer(CALLBACK(src, PROC_REF(poll_for_file), url_hash, user, sound_path, 5), 30)
	return TRUE

/datum/online_jukebox/proc/poll_for_file(url_hash, mob/user, sound_path, attempts)
	if(QDELETED(src))
		return
	if(fexists(sound_path))
		play_library_track_internal(url_hash, user)
		return
	if(attempts > 0)
		addtimer(CALLBACK(src, PROC_REF(poll_for_file), url_hash, user, sound_path, attempts - 1), 10)
	else
		online_error_message = "Sound file missing; try refreshing the library."
		ui?.update_ui()

/datum/online_jukebox/proc/play_library_track_internal(url_hash, mob/user)
	var/list/track_data = GLOB.jukebox_library_tracks[url_hash]
	if(!track_data)
		online_error_message = "Track not found in library"
		ui?.update_ui()
		return FALSE

	stop_music()

	online_track_url = track_data["url"]
	online_track_name = track_data["track_name"]
	online_track_duration = track_data["duration"] * 10
	online_track_hash = url_hash
	playing_online = TRUE
	track_start_time = world.time
	online_error_message = ""

	var/sounds_dir = get_jukebox_sounds_dir()
	var/sound_path = "[sounds_dir]/[url_hash].ogg"

	var/sound/online_sound = sound(file(sound_path))
	online_sound.channel = CHANNEL_ONLINE_JUKEBOX
	online_sound.priority = 255
	online_sound.falloff = 2
	online_sound.volume = volume
	online_sound.status |= SOUND_STREAM

	var/area/juke_area = get_area(parent_atom)
	online_sound.environment = juke_area?.sound_environment || SOUND_ENVIRONMENT_NONE
	online_sound.repeat = sound_loops

	active_song_sound = online_sound

	if(parent_atom)
		for(var/mob/M in GLOB.player_list)
			if(M?.client)
				M.stop_sound_channel(CHANNEL_ONLINE_JUKEBOX)

		var/list/nearby = get_hearers_in_view(sound_range, parent_atom, RECURSIVE_CONTENTS_CLIENT_MOBS)
		for(var/mob/nearby_listener in nearby)
			register_listener(nearby_listener)

	record_jukebox_play(url_hash)

	ui?.update_ui()
	return TRUE

/datum/online_jukebox/proc/stop_music()
	if(active_song_sound)
		unlisten_all()
		active_song_sound = null
	playing_online = FALSE
	online_track_url = null
	online_track_name = null
	online_track_duration = 0
	online_track_hash = null
	track_start_time = 0
	online_error_message = ""
	ui?.update_ui()

/datum/online_jukebox/proc/set_new_volume(new_volume)
	volume = clamp(new_volume, 0, 100)
	if(active_song_sound)
		active_song_sound.volume = volume
		update_all()
	ui?.update_ui()

/datum/online_jukebox/proc/unlisten_all()
	for(var/mob/listening in listeners)
		deregister_listener(listening)
	active_song_sound = null

/datum/online_jukebox/proc/update_all()
	for(var/mob/listening in listeners)
		update_listener(listening)

/datum/online_jukebox/proc/register_listener(mob/new_listener)
	if(!new_listener || !new_listener.client || (new_listener in listeners))
		return
	listeners[new_listener] = NONE
	RegisterSignal(new_listener, COMSIG_QDELETING, PROC_REF(listener_deleted))
	RegisterSignals(new_listener, list(COMSIG_MOVABLE_MOVED, COMSIG_MOB_JUKEBOX_PREFERENCE_APPLIED), PROC_REF(listener_moved))
	RegisterSignals(new_listener, list(SIGNAL_ADDTRAIT(TRAIT_DEAF), SIGNAL_REMOVETRAIT(TRAIT_DEAF)), PROC_REF(listener_deaf))

	if(active_song_sound)
		update_listener(new_listener)
		listeners[new_listener] |= SOUND_UPDATE

/datum/online_jukebox/proc/listener_deleted(mob/source)
	SIGNAL_HANDLER
	deregister_listener(source)

/datum/online_jukebox/proc/listener_moved(mob/source)
	SIGNAL_HANDLER
	update_listener(source)

/datum/online_jukebox/proc/listener_deaf(mob/source)
	SIGNAL_HANDLER
	update_listener(source)

/datum/online_jukebox/proc/deregister_listener(mob/no_longer_listening)
	if(!no_longer_listening)
		return

	listeners -= no_longer_listening
	no_longer_listening.stop_sound_channel(CHANNEL_ONLINE_JUKEBOX)

	UnregisterSignal(no_longer_listening, list(
		COMSIG_MOB_LOGIN,
		COMSIG_QDELETING,
		COMSIG_MOVABLE_MOVED,
		COMSIG_MOB_JUKEBOX_PREFERENCE_APPLIED,
		SIGNAL_ADDTRAIT(TRAIT_DEAF),
		SIGNAL_REMOVETRAIT(TRAIT_DEAF),
	))

/datum/online_jukebox/proc/update_listener(mob/listener)
	if(!active_song_sound || !listener.client || QDELETED(src))
		return

	var/turf/sound_turf = get_turf(parent_atom)
	var/turf/listener_turf = get_turf(listener)

	var/new_mute_flags = NONE

	var/pref_volume = listener.client.prefs.read_preference(/datum/preference/numeric/volume/sound_jukebox)
	if(!pref_volume)
		new_mute_flags |= MUTE_PREF

	if(HAS_TRAIT(listener, TRAIT_DEAF))
		new_mute_flags |= MUTE_DEAF

	if(!sound_turf || !listener_turf || sound_turf.z != listener_turf.z)
		new_mute_flags |= MUTE_RANGE
	else
		var/new_x = sound_turf.x - listener_turf.x
		var/new_z = sound_turf.y - listener_turf.y
		if(abs(new_x) > x_cutoff || abs(new_z) > z_cutoff)
			new_mute_flags |= MUTE_RANGE
		else
			active_song_sound.x = new_x
			active_song_sound.z = new_z
			active_song_sound.volume = volume * (pref_volume / 100)

	if(new_mute_flags)
		listeners[listener] |= SOUND_MUTE
	else
		listeners[listener] &= ~SOUND_MUTE

	var/current_status = listeners[listener]
	active_song_sound.status = current_status
	if(current_status & SOUND_UPDATE)
		active_song_sound.status |= SOUND_UPDATE

	SEND_SOUND(listener, active_song_sound)
	listeners[listener] |= SOUND_UPDATE
