GLOBAL_LIST_EMPTY(jukebox_library_tracks)
GLOBAL_VAR_INIT(jukebox_library_initialized, FALSE)
GLOBAL_LIST_EMPTY(online_jukeboxes)
GLOBAL_VAR_INIT(jukebox_api_url, "http://localhost:8001")
GLOBAL_VAR_INIT(jukebox_api_status, FALSE)
GLOBAL_VAR_INIT(jukebox_last_check, 0)
GLOBAL_DATUM_INIT(jukebox_api_handler, /datum/jukebox_api_handler, new /datum/jukebox_api_handler)

#define JUKEBOX_MUSIC_DIR_NAME "jukebox_music"
#define JUKEBOX_SOUNDS_DIR_NAME "jukebox_music/sounds"
#define JUKEBOX_LIBRARY_FILE_NAME "jukebox_music/music_library.json"
#define JUKEBOX_HTTP_TIMEOUT 300

/proc/mob_by_key(key_to_find)
	if(!key_to_find)
		return null
	var/client/C = GLOB.directory[key_to_find]
	return C?.mob

/proc/time_to_text(time_in_seconds)
	return time2text(time_in_seconds, "YYYY/MM/DD hh:mm:ss")

/proc/get_jukebox_music_dir()
	var/static/jukebox_dir_cache
	if(jukebox_dir_cache)
		return jukebox_dir_cache
	var/base_dir = global.config?.directory || "config"
	var/list/candidates = list(
		"[base_dir]/jukebox_music",
		"/srv/tgstation_instances/livenew/Configuration/GameStaticFiles/[base_dir]/jukebox_music",
		"/srv/tgstation_instances/livenew/Game/Live/[base_dir]/jukebox_music"
	)
	for(var/cand in candidates)
		if(fexists(cand))
			jukebox_dir_cache = cand
			return cand
	jukebox_dir_cache = "[base_dir]/jukebox_music"
	return jukebox_dir_cache

/proc/get_jukebox_sounds_dir()
	return "[get_jukebox_music_dir()]/sounds"

/proc/get_jukebox_library_file()
	return "[get_jukebox_music_dir()]/music_library.json"

/proc/initialize_jukebox_library()
	if(GLOB.jukebox_library_initialized)
		return
	GLOB.jukebox_library_initialized = TRUE
	load_jukebox_library()

/proc/update_all_jukebox_uis()
	for(var/datum/online_jukebox/juke in GLOB.online_jukeboxes)
		juke.ui?.update_ui()

/proc/perform_jukebox_health_check()
	GLOB.jukebox_last_check = world.realtime
	return GLOB.jukebox_api_status

/proc/load_jukebox_library()
	var/library_path = get_jukebox_library_file()
	if(!fexists(library_path))
		return
	var/json_data = file2text(library_path)
	if(!json_data)
		return
	var/list/library_data = json_decode(json_data)
	if(!library_data || !library_data["tracks"])
		return
	GLOB.jukebox_library_tracks.Cut()
	var/list/raw_tracks = library_data["tracks"]
	var/list/play_counts = library_data["play_count"]
	var/list/last_played_times = library_data["last_played"]
	for(var/url_hash in raw_tracks)
		var/list/track_data = raw_tracks[url_hash]
		GLOB.jukebox_library_tracks[url_hash] = list(
			"file_path" = track_data["file_path"],
			"track_name" = track_data["track_name"],
			"duration" = track_data["duration"],
			"url" = track_data["url"],
			"url_hash" = track_data["url_hash"],
			"play_count" = play_counts?[url_hash] || 0,
			"last_played" = last_played_times?[url_hash] || 0
		)
	update_all_jukebox_uis()

/proc/get_sorted_library_tracks()
	var/list/tracks = list()
	for(var/url_hash in GLOB.jukebox_library_tracks)
		tracks += list(GLOB.jukebox_library_tracks[url_hash])
	sortTim(tracks, GLOBAL_PROC_REF(cmp_jukebox_tracks))
	return tracks

/proc/cmp_jukebox_tracks(list/a, list/b)
	if(a["play_count"] != b["play_count"])
		return b["play_count"] - a["play_count"]
	return b["last_played"] - a["last_played"]

/proc/validate_jukebox_url(url)
	if(!url || !findtext(url, "http"))
		return list("valid" = FALSE, "error" = "Invalid URL")
	var/static/list/supported_domains = list("soundcloud.com", "bandcamp.com")
	for(var/domain in supported_domains)
		if(findtext(url, domain))
			return list("valid" = TRUE)
	return list("valid" = FALSE, "error" = "Unsupported platform. Supported: SoundCloud, Bandcamp")

/proc/get_library_tracks_ui_data()
	var/list/ui_tracks = list()
	var/list/sorted = get_sorted_library_tracks()
	for(var/list/track in sorted)
		ui_tracks += list(list(
			"name" = track["track_name"],
			"duration" = DisplayTimeText(track["duration"] * 10),
			"url_hash" = track["url_hash"],
			"play_count" = track["play_count"],
			"last_played" = track["last_played"] ? time_to_text(track["last_played"]) : "Never"
		))
	return ui_tracks

/proc/get_jukebox_library_stats()
	var/list/sorted = get_sorted_library_tracks()
	var/list/most_played = list()
	for(var/i in 1 to min(length(sorted), 3))
		var/list/track = sorted[i]
		most_played += list(list("name" = track["track_name"], "plays" = track["play_count"]))
	return list("total_tracks" = length(GLOB.jukebox_library_tracks), "max_tracks" = 50, "most_played" = most_played)

/proc/record_jukebox_play(url_hash)
	if(!url_hash)
		return
	var/list/track = GLOB.jukebox_library_tracks[url_hash]
	if(!track)
		return
	track["play_count"]++
	track["last_played"] = world.realtime
	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_POST, "[GLOB.jukebox_api_url]/record_play/[url_hash]", "", "")
	request.begin_async()
	check_and_prune_library()
	update_all_jukebox_uis()

/proc/check_and_prune_library()
	if(length(GLOB.jukebox_library_tracks) < 50)
		return TRUE

	var/list/sorted = get_sorted_library_tracks()
	var/list/to_remove = sorted[length(sorted)]
	var/remove_hash = to_remove["url_hash"]

	GLOB.jukebox_library_tracks -= remove_hash

	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_DELETE, "[GLOB.jukebox_api_url]/remove_track/[remove_hash]", "", "")
	request.begin_async()
	return TRUE

/proc/jukebox_api_healthy()
	return GLOB.jukebox_api_status

/datum/jukebox_api_handler
	var/list/active_requests = list()
	var/current_request_id = 0

/datum/jukebox_api_handler/proc/check_health_async()
	var/request_id = ++current_request_id
	var/datum/http_request/request = new()
	if(!request)
		GLOB.jukebox_api_status = FALSE
		return
	active_requests["[request_id]"] = list("type" = "health", "request" = request)
	request.prepare(RUSTG_HTTP_METHOD_GET, "[GLOB.jukebox_api_url]/health", "", "")
	request.begin_async()
	addtimer(CALLBACK(src, PROC_REF(poll_health), request_id), 10)

/datum/jukebox_api_handler/proc/poll_health(request_id)
	var/list/req_data = active_requests["[request_id]"]
	if(!req_data)
		return
	var/datum/http_request/request = req_data["request"]
	if(!request.is_complete())
		addtimer(CALLBACK(src, PROC_REF(poll_health), request_id), 10)
		return
	var/datum/http_response/response = request.into_response()
	GLOB.jukebox_api_status = (response && response.status_code == 200)
	GLOB.jukebox_last_check = world.realtime
	update_all_jukebox_uis()
	active_requests -= "[request_id]"

/datum/jukebox_api_handler/proc/download_track_async(url, mob/user, datum/online_jukebox/jukebox)
	if(!url || !jukebox || QDELETED(jukebox))
		return
	var/request_id = ++current_request_id
	var/datum/http_request/request = new()
	if(!request)
		jukebox.online_error_message = "HTTP system not available"
		jukebox.ui?.update_ui()
		return
	active_requests["[request_id]"] = list("request" = request, "jukebox" = jukebox, "user" = WEAKREF(user), "url" = url, "start" = world.time)
	request.prepare(RUSTG_HTTP_METHOD_GET, "[GLOB.jukebox_api_url]/download?url=[url_encode(url)]", "", "")
	request.begin_async()
	addtimer(CALLBACK(src, PROC_REF(poll_download), request_id), 10)

/datum/jukebox_api_handler/proc/poll_download(request_id)
	var/list/req_data = active_requests["[request_id]"]
	if(!req_data)
		return
	var/datum/http_request/request = req_data["request"]
	var/datum/online_jukebox/jukebox = req_data["jukebox"]
	if(world.time > req_data["start"] + JUKEBOX_HTTP_TIMEOUT)
		if(!QDELETED(jukebox))
			jukebox.online_error_message = "Download timeout"
			jukebox.ui?.update_ui()
		active_requests -= "[request_id]"
		return
	if(!request.is_complete())
		addtimer(CALLBACK(src, PROC_REF(poll_download), request_id), 10)
		return
	var/datum/http_response/response = request.into_response()
	handle_download_completion(req_data, response)
	active_requests -= "[request_id]"

/datum/jukebox_api_handler/proc/handle_download_completion(list/req_data, datum/http_response/response)
	var/datum/online_jukebox/jukebox = req_data["jukebox"]
	var/datum/weakref/user_ref = req_data["user"]
	var/mob/user = user_ref?.resolve()

	if(QDELETED(jukebox))
		return

	if(response.errored || response.status_code != 200)
		jukebox.online_error_message = "API Error ([response.status_code])"
	else
		var/list/result = json_decode(response.body)
		if(result?["success"])
			check_and_prune_library()

			load_jukebox_library()

			jukebox.play_library_track_on_success(result["url_hash"], user)
			update_all_jukebox_uis()
		else
			jukebox.online_error_message = result?["error"] || "Unknown API error"

	jukebox.ui?.update_ui()

SUBSYSTEM_DEF(jukebox)
	name = "Online Jukebox"
	init_stage = INITSTAGE_MAIN
	priority = FIRE_PRIORITY_ASSETS
	flags = SS_KEEP_TIMING
	wait = 10
	var/next_health_check = 0

/datum/controller/subsystem/jukebox/Initialize()
	initialize_jukebox_library()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/jukebox/fire()
	if(world.time >= next_health_check)
		if(GLOB.jukebox_api_handler)
			GLOB.jukebox_api_handler.check_health_async()
		next_health_check = world.time + 600

	for(var/datum/online_jukebox/juke in GLOB.online_jukeboxes)
		if(QDELETED(juke))
			GLOB.online_jukeboxes -= juke
			continue
		juke.process_tick()
