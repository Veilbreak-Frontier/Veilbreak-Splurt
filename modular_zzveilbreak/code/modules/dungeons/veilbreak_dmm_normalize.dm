/// BYOND /datum/parsed_map only accepts tile keys matching [a-zA-Z]+ and coords like (1,1,1) with no spaces.
/// External dungeon generators often emit numeric keys or "(1, 1, 1)" — normalize before parse.

/proc/cmp_veilbreak_dmm_key_length_desc(a, b)
	return length(b) - length(a)

/proc/veilbreak_nth_alpha_key(index, key_len)
	var/result = ""
	var/n = index
	for(var/i in 1 to key_len)
		var/d = n % 26
		n = round((n - d) / 26)
		result = ascii2text(97 + d) + result
	return result

/proc/veilbreak_needed_alpha_key_length(num_keys)
	var/len = 1
	while(TRUE)
		var/capacity = 1
		for(var/j in 1 to len)
			capacity *= 26
		if(capacity >= num_keys)
			return len
		len++

/proc/veilbreak_remap_grid_block_inner(inner, key_len, list/old_to_new)
	var/list/lines = splittext(inner, "\n")
	var/list/out_lines = list()
	for(var/raw_line in lines)
		var/line = trim(raw_line)
		if(!length(line))
			out_lines += raw_line
			continue
		var/build = ""
		for(var/pos = 1; pos <= length(line); pos += key_len)
			var/chunk = copytext(line, pos, pos + key_len)
			if(length(chunk) < key_len)
				build += chunk
				break
			build += old_to_new[chunk] || chunk
		out_lines += build
	return jointext(out_lines, "\n")

/proc/veilbreak_remap_all_coord_grids(dmm_text, key_len, list/old_to_new)
	var/. = dmm_text
	var/static/regex/rx_block = new(@'\((\d+),(\d+),(\d+)\)\s*=\s*\{\"')
	var/safety = 0
	while(++safety < 10000)
		if(!rx_block.Find(., 1))
			break
		var/grid_start = rx_block.index + length(rx_block.match)
		var/close = findtext(., "\"}", grid_start)
		if(!close)
			break
		var/inner = copytext(., grid_start, close)
		var/remapped = veilbreak_remap_grid_block_inner(inner, key_len, old_to_new)
		. = copytext(., 1, grid_start) + remapped + copytext(., close)
	return .

/// Returns normalized DMM text, or null if tile keys have inconsistent lengths (cannot fix safely).
/proc/veilbreak_normalize_dmm_for_parsed_map(dmm_content)
	if(!length(dmm_content))
		return null

	var/. = dmm_content
	var/first_quote = findtext(., "\"")
	if(first_quote > 1)
		. = copytext(., first_quote)
	. = replacetext(., "\r", "")

	var/static/regex/regex_coord_spaces = new(@"\((\d+)\s*,\s*(\d+)\s*,\s*(\d+)\)")
	. = regex_coord_spaces.Replace(., "($1,$2,$3)")
	var/static/regex/regex_loose_grid_open = new(@'\)\s*=\s*\{\s*\"')
	. = regex_loose_grid_open.Replace(., ") = {\"")

	var/list/keys_ordered = list()
	var/list/seen = list()
	var/static/regex/regex_map_key = new(@'"([a-zA-Z0-9_]+)"\s*=\s*\(', "g")
	var/find_pos = 1
	while(regex_map_key.Find(., find_pos))
		var/k = regex_map_key.group[1]
		if(!seen[k])
			seen[k] = TRUE
			keys_ordered += k
		find_pos = regex_map_key.next

	if(!length(keys_ordered))
		return .

	var/key_len = length(keys_ordered[1])
	for(var/check_key in keys_ordered)
		if(length(check_key) != key_len)
			log_world("Veilbreak DMM normalize: inconsistent tile key lengths ([key_len] vs [length(check_key)]), cannot normalize")
			return null

	var/static/regex/alpha_only_tile_key = new(@"^[a-zA-Z]+$")
	var/need_remap = FALSE
	for(var/alpha_check in keys_ordered)
		if(!alpha_only_tile_key.Find(alpha_check))
			need_remap = TRUE
			break

	if(!need_remap)
		return .

	var/new_len = max(key_len, veilbreak_needed_alpha_key_length(length(keys_ordered)))
	var/list/old_to_new = list()
	var/list/sorted_old = keys_ordered.Copy()
	sortTim(sorted_old, GLOBAL_PROC_REF(cmp_veilbreak_dmm_key_length_desc))

	var/n = 0
	for(var/old_k in sorted_old)
		old_to_new[old_k] = veilbreak_nth_alpha_key(n++, new_len)

	for(var/old_k in sorted_old)
		var/new_k = old_to_new[old_k]
		. = replacetext(., "\"[old_k]\" = (", "\"[new_k]\" = (")

	. = veilbreak_remap_all_coord_grids(., key_len, old_to_new)
	return .
