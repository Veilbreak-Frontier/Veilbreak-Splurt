/datum/http_dungeon_generator
	var/current_request_id = 0
	var/list/active_requests = list()

/datum/http_dungeon_generator/proc/generate_dungeon(datum/portal_destination/veilbreak/destination, width = 100, height = 100)
	var/request_id = ++current_request_id
	var/url = "[DUNGEON_GENERATOR_URL][DUNGEON_GENERATE_ENDPOINT]?width=[width]&height=[height]&seed=[rand(1,1000000)]&format=json"
	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_GET, url, "", "")
	request.begin_async()
	var/id_str = "[request_id]"
	active_requests[id_str] = destination
	active_requests["[id_str]_req"] = request
	active_requests["[id_str]_time"] = world.time
	return request_id

/datum/http_dungeon_generator/proc/check_request(request_id)
	var/id_str = "[request_id]"
	var/datum/portal_destination/veilbreak/destination = active_requests[id_str]
	var/datum/http_request/request = active_requests["[id_str]_req"]
	if(!istype(destination) || QDELETED(destination) || !request)
		cleanup_request(id_str)
		return FALSE
	if(!request.is_complete())
		var/start_time = active_requests["[id_str]_time"]
		if(world.time - start_time > DUNGEON_GENERATOR_TIMEOUT)
			destination.generation_failed("API Request Timeout")
			cleanup_request(id_str)
			return FALSE
		return TRUE
	var/datum/http_response/response = request.into_response()
	if(!response || response.status_code != 200)
		destination.generation_failed("HTTP [response.status_code]: [response.body]")
		cleanup_request(id_str)
		return FALSE
	var/list/json_data = json_decode(response.body)
	if(json_data?["status"] != "success" || length(json_data?["dmm_content"]) <= 100)
		destination.generation_failed("API Error: Invalid or insufficient map data")
		cleanup_request(id_str)
		return FALSE
	if(destination)
		destination.generation_complete(json_data)
		if(length(SSatoms.initialized_state))
			var/source = SSatoms.get_initialized_source()
			if(source)
				SSatoms.map_loader_stop(source)
	cleanup_request(id_str)
	return FALSE

/datum/http_dungeon_generator/proc/cleanup_request(id_str)
	active_requests.Remove(id_str)
	active_requests.Remove("[id_str]_req")
	active_requests.Remove("[id_str]_time")
