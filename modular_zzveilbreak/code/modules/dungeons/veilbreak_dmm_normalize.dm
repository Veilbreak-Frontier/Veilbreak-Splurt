/// BYOND /datum/parsed_map only accepts tile keys matching [a-zA-Z]+ and coords like (1,1,1) with no spaces.
/// External dungeon generators often emit numeric keys or "(1, 1, 1)" — normalize before parse.
///
/// The parser regex requires each model to end with ) then newline before the next "key" or (1,1,1) grid.
/// Grid blobs may only contain [a-zA-Z\n] — spaces between row keys must be removed.

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
	var/out = dmm_text
	var/static/regex/rx_block = new(@'\((\d+),(\d+),(\d+)\)\s*=\s*\{\"')
	var/safety = 0
	while(++safety < 10000)
		if(!rx_block.Find(out, 1))
			break
		var/grid_start = rx_block.index + length(rx_block.match)
		var/close = findtext(out, "\"}", grid_start)
		if(!close)
			break
		var/inner = copytext(out, grid_start, close)
		var/remapped = veilbreak_remap_grid_block_inner(inner, key_len, old_to_new)
		out = copytext(out, 1, grid_start) + remapped + copytext(out, close)
	return out

/// parsed_map coord regex only allows letters and newlines inside the grid string.
/proc/veilbreak_dmm_strip_spaces_in_grid_blocks(dmm_text)
	var/out = dmm_text
	var/static/regex/rx_block = new(@'\((\d+),(\d+),(\d+)\)\s*=\s*\{\"')
	var/safety = 0
	var/tab = ascii2text(9)
	while(++safety < 10000)
		if(!rx_block.Find(out, 1))
			break
		var/grid_start = rx_block.index + length(rx_block.match)
		var/close = findtext(out, "\"}", grid_start)
		if(!close)
			break
		var/inner = copytext(out, grid_start, close)
		var/list/lines = splittext(inner, "\n")
		var/list/out_lines = list()
		for(var/raw_line in lines)
			var/line = trim(raw_line)
			if(!length(line))
				out_lines += raw_line
				continue
			line = replacetext(line, " ", "")
			line = replacetext(line, tab, "")
			out_lines += line
		var/new_inner = jointext(out_lines, "\n")
		out = copytext(out, 1, grid_start) + new_inner + copytext(out, close)
	return out

/// Insert newlines so each model ends with )\n (required by reader.dm dmm_regex).
/proc/veilbreak_dmm_fix_compact_model_layout(dmm_text)
	var/out = dmm_text
	var/static/regex/rx_tight_defs = new(@'\)\"([a-zA-Z]+)\"\s*=\s*\(')
	out = rx_tight_defs.Replace(out, ")\n\"$1\" = (")
	var/static/regex/rx_def_chain = new(@'\)[ \t]+\"([a-zA-Z]+)\"\s*=\s*\(')
	out = rx_def_chain.Replace(out, ")\n\"$1\" = (")
	var/static/regex/rx_grid_start = new(@'\)\s*\((\d+,\d+,\d+)\)\s*=\s*\{\"')
	out = rx_grid_start.Replace(out, ")\n($1) = {\"")
	return out

/// Returns normalized DMM text, or null if tile keys have inconsistent lengths (cannot fix safely).
/proc/veilbreak_normalize_dmm_for_parsed_map(dmm_content)
	if(!length(dmm_content))
		return null

	var/out = dmm_content
	var/first_quote = findtext(out, "\"")
	if(first_quote > 1)
		out = copytext(out, first_quote)
	out = replacetext(out, ascii2text(13), "")

	out = veilbreak_dmm_fix_compact_model_layout(out)

	var/static/regex/regex_coord_spaces = new(@"\((\d+)\s*,\s*(\d+)\s*,\s*(\d+)\)")
	out = regex_coord_spaces.Replace(out, "($1,$2,$3)")
	var/static/regex/regex_loose_grid_open = new(@'\)\s*=\s*\{\s*\"')
	out = regex_loose_grid_open.Replace(out, ") = {\"")

	out = veilbreak_dmm_strip_spaces_in_grid_blocks(out)

	var/list/keys_ordered = list()
	var/list/seen = list()
	var/static/regex/regex_map_key = new(@'"([a-zA-Z0-9_]+)"\s*=\s*\(', "g")
	var/find_pos = 1
	while(regex_map_key.Find(out, find_pos))
		var/k = regex_map_key.group[1]
		if(!seen[k])
			seen[k] = TRUE
			keys_ordered += k
		find_pos = regex_map_key.next

	if(!length(keys_ordered))
		return out

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
		return out

	var/new_len = max(key_len, veilbreak_needed_alpha_key_length(length(keys_ordered)))
	var/list/old_to_new = list()
	var/list/sorted_old = keys_ordered.Copy()
	sortTim(sorted_old, GLOBAL_PROC_REF(cmp_veilbreak_dmm_key_length_desc))

	var/n = 0
	for(var/old_k in sorted_old)
		old_to_new[old_k] = veilbreak_nth_alpha_key(n++, new_len)

	for(var/old_k in sorted_old)
		var/new_k = old_to_new[old_k]
		out = replacetext(out, "\"[old_k]\" = (", "\"[new_k]\" = (")

	out = veilbreak_remap_all_coord_grids(out, key_len, old_to_new)
	out = veilbreak_dmm_strip_spaces_in_grid_blocks(out)
	return out

/// HTTP generators often send only "key"=(/turf,/area) defs. BYOND needs a (1,1,1)={"..."} grid; fill with the first defined key (repeated).
/proc/veilbreak_dmm_append_placeholder_grid(dmm_text, width, height)
	var/fill_key = "a"
	var/static/regex/rx_first_key = new(@'"([a-zA-Z]+)"\s*=\s*\(')
	if(rx_first_key.Find(dmm_text, 1))
		fill_key = rx_first_key.group[1]

	var/list/rows = list()
	var/row = ""
	for(var/tile_x in 1 to width)
		row += fill_key
	for(var/tile_y in 1 to height)
		rows += row
	var/body = jointext(rows, "\n")
	return "[dmm_text]\n(1,1,1) = {\"\n[body]\n\"}\n"
