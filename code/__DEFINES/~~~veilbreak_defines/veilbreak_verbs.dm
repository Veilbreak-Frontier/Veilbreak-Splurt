#define GAME_VERB_INSTANT(owner_type, verb_path_name, verb_name, verb_category) \
	_GAME_VERB(owner_type, verb_path_name, verb_name, "", verb_category, TRUE, FALSE, TRUE)

#define GAME_VERB_DESC_INSTANT(owner_type, verb_path_name, verb_name, verb_desc, verb_category) \
	_GAME_VERB(owner_type, verb_path_name, verb_name, verb_desc, verb_category, TRUE, FALSE, TRUE)

#define VERB_ARG_SOURCE_EXAMINE "examine"
#define VERB_ARG_SOURCE_OVIEW_1 "oview_1"

#define GAME_VERB_CONTEXT_IN(owner_type, verb_path_name, verb_name, verb_desc, verb_category, context_type, source_expr) \
/datum/verb_metadata##owner_type/##verb_path_name \
{ \
	name = ##verb_name; \
	description = ##verb_desc; \
	category = ##verb_category; \
	verb_path = ##owner_type/verb/##verb_path_name; \
	body_path = ##owner_type/proc/__gvb_##verb_path_name; \
}; \
##owner_type/verb/##verb_path_name(var##context_type/__context_target in source_expr) \
{ \
	set name = ##verb_name; \
	set desc = ##verb_desc; \
	set hidden = FALSE; \
	set popup_menu = TRUE; \
	set category = ##verb_category; \
	if(__context_target) { var/list/__args = args.Copy(); __args += list(VERB_ARG_CONTEXT_TARGET_KEY = __context_target); INVOKE_ASYNC(SSverbs, TYPE_PROC_REF(/datum/controller/subsystem/verbs, invoke_verb), src, ##owner_type/verb/##verb_path_name, __args, usr); } \
	else { INVOKE_ASYNC(SSverbs, TYPE_PROC_REF(/datum/controller/subsystem/verbs, invoke_verb), src, ##owner_type/verb/##verb_path_name, args, usr); }; \
}; \
##owner_type/proc/__gvb_##verb_path_name(list/structured_args)

#define _GAME_VERB_CONTEXT_SOURCE(owner_type, verb_path_name, verb_name, verb_desc, verb_category, show_in_context_menu, context_type, input_filter, source_expr) \
/datum/verb_metadata##owner_type/##verb_path_name \
{ \
	name = ##verb_name; \
	description = ##verb_desc; \
	category = ##verb_category; \
	verb_path = ##owner_type/verb/##verb_path_name; \
	body_path = ##owner_type/proc/__gvb_##verb_path_name; \
}; \
##owner_type/verb/##verb_path_name(var##context_type/target as input_filter in source_expr) \
{ \
	set name = ##verb_name; \
	set desc = ##verb_desc; \
	set hidden = FALSE; \
	set popup_menu = ##show_in_context_menu; \
	set category = ##verb_category; \
	if(target) { var/list/__args = args.Copy(); __args += list(VERB_ARG_CONTEXT_TARGET_KEY = target); INVOKE_ASYNC(SSverbs, TYPE_PROC_REF(/datum/controller/subsystem/verbs, invoke_verb), src, ##owner_type/verb/##verb_path_name, __args, usr); } \
	else { INVOKE_ASYNC(SSverbs, TYPE_PROC_REF(/datum/controller/subsystem/verbs, invoke_verb), src, ##owner_type/verb/##verb_path_name, args, usr); }; \
}; \
##owner_type/proc/__gvb_##verb_path_name(list/structured_args)
