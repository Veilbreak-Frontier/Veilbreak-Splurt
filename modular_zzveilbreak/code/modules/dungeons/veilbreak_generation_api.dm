/datum/http_dungeon_generator
	var/current_request_id = 0
	var/list/active_requests = list()

/datum/http_dungeon_generator/proc/generate_dungeon(datum/portal_destination/veilbreak/destination, width = 100, height = 100)
	var/request_id = ++current_request_id
	var/seed = rand(1, 1000000)
	var/url = "[DUNGEON_GENERATOR_URL][DUNGEON_GENERATE_ENDPOINT]?width=[width]&height=[height]&seed=[seed]&format=json"
	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_GET, url, "", "")
	request.begin_async()
	var/id_str = "[request_id]"
	active_requests[id_str] = destination
	active_requests["[id_str]_req"] = request
	active_requests["[id_str]_time"] = world.time
	active_requests["[id_str]_seed"] = seed
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

	log_world("Veilbreak API: Raw response body length: [length(response.body)]")
	log_world("Veilbreak API: Raw response first 300 chars:")
	log_world(copytext(response.body, 1, 300))

	var/list/json_data = json_decode(response.body)
	if(!json_data || json_data["status"] != "success")
		destination.generation_failed("API Error: Invalid response")
		cleanup_request(id_str)
		return FALSE

	var/dmm_content = json_data["dmm_content"]
	log_world("Veilbreak API: After json_decode, dmm_content length: [length(dmm_content)]")
	log_world("Veilbreak API: First 300 chars after decode:")
	log_world(copytext(dmm_content, 1, 300))
	log_world("Veilbreak API: Contains newline character 0x0A? [findtext(dmm_content, "\n") ? "YES" : "NO"]")
	log_world("Veilbreak API: Contains literal backslash-n? [findtext(dmm_content, "\\n") ? "YES" : "NO"]")

	if(!dmm_content || length(dmm_content) <= 100)
		destination.generation_failed("API Error: Invalid or insufficient map data")
		cleanup_request(id_str)
		return FALSE

	dmm_content = replacetext(dmm_content, "\\n", "\n")
	dmm_content = replacetext(dmm_content, "\\t", "\t")
	dmm_content = replacetext(dmm_content, "\\\"", "\"")

	var/list/new_json_data = list()
	new_json_data["status"] = json_data["status"]
	new_json_data["dmm_content"] = dmm_content
	new_json_data["metadata"] = json_data["metadata"]

	if(destination)
		destination.generation_complete(new_json_data)
	cleanup_request(id_str)
	return TRUE

/datum/http_dungeon_generator/proc/cleanup_request(id_str)
	active_requests.Remove(id_str)
	active_requests.Remove("[id_str]_req")
	active_requests.Remove("[id_str]_time")
	active_requests.Remove("[id_str]_seed")
