#define GAME_VERB_INSTANT(owner_type, verb_path_name, verb_name, verb_category) \
	_GAME_VERB(owner_type, verb_path_name, verb_name, "", verb_category, TRUE, FALSE, TRUE)

#define GAME_VERB_DESC_INSTANT(owner_type, verb_path_name, verb_name, verb_desc, verb_category) \
	_GAME_VERB(owner_type, verb_path_name, verb_name, verb_desc, verb_category, TRUE, FALSE, TRUE)
