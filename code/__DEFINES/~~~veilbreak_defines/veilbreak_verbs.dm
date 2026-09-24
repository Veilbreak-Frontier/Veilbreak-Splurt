#undef GAME_VERB_INSTANT
#undef GAME_VERB_DESC_INSTANT

#define GAME_VERB_INSTANT(owner_type, verb_path_name, verb_name, verb_category, verb_args...) \
	_GAME_VERB(owner_type, verb_path_name, verb_name, "", verb_category, TRUE, FALSE, TRUE, ##verb_args)

#define GAME_VERB_DESC_INSTANT(owner_type, verb_path_name, verb_name, verb_desc, verb_category, verb_args...) \
	_GAME_VERB(owner_type, verb_path_name, verb_name, verb_desc, verb_category, TRUE, FALSE, TRUE, ##verb_args)
