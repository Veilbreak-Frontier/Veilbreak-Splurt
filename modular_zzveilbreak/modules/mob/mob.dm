GAME_VERB(/mob, open_language_menu_verb, "Open Language Menu", "IC")
	get_language_holder().open_language_menu(src)

GAME_VERB(/mob/living, emote_panel, "Emote Panel", "IC")
	var/static/datum/emote_panel/emote_panel
	if(isnull(emote_panel))
		emote_panel = new
	emote_panel.ui_interact(src)

GAME_VERB(/mob/living, toggle_resting_verb, "Rest", "IC")
	set_resting(!resting, FALSE)

GAME_VERB(/mob, memory, "Memories", "IC")
	if(!mind)
		var/fail_message = "You have no mind!"
		if(isobserver(src))
			fail_message += " You have to be in the current round at some point to have one."
		to_chat(src, span_warning(fail_message))
		return
	if(!mind.memory_panel)
		mind.memory_panel = new(src, mind)
	mind.memory_panel.ui_interact(src)

GAME_VERB(/mob, view_skills, "View Skills", "IC")
	mind?.print_levels(src)

GAME_VERB_CONTEXT(/mob, examinate_verb, "Examine", "", "IC", /atom)
	VERB_ARG_TYPED(examinify, VERB_ARG_TYPE_MOB | VERB_ARG_TYPE_OBJ | VERB_ARG_TYPE_TURF, VERB_ARG_SOURCE_VIEW, /atom)
	DEFAULT_QUEUE_OR_CALL_VERB(VERB_CALLBACK(src, PROC_REF(run_examinate), examinify))

GAME_VERB(/mob, mode_verb, "Activate Held Object", "Object")
	DEFAULT_QUEUE_OR_CALL_VERB(VERB_CALLBACK(src, PROC_REF(execute_mode)))

GAME_VERB(/mob/living, stop_pulling_verb, "Stop Pulling", "IC")
	stop_pulling()

GAME_VERB(/mob/living, mob_sleep_verb, "Sleep", "IC")
	if(IsSleeping())
		to_chat(src, span_warning("You are already sleeping!"))
		return

	if(tgui_alert(src, "Are you sure you want to sleep for a while?", "Sleep", list("Yes", "No")) == "Yes")
		SetSleeping(400)

GAME_VERB(/mob/living, resist_verb, "Resist", "IC")
	DEFAULT_QUEUE_OR_CALL_VERB(VERB_CALLBACK(src, PROC_REF(execute_resist)))

GAME_VERB(/mob/living, lookup_verb, "Look Up", "IC")
	if(looking_vertically)
		to_chat(src, "You set your head straight again.")
		end_look()
		return

	var/turf/current_turf = get_turf(src)
	var/turf/above_turf = GET_TURF_ABOVE(current_turf)

	if(!above_turf)
		to_chat(src, span_warning("There's nothing interesting above. Better keep your eyes ahead."))
		return

	to_chat(src, "You tilt your head upwards.")
	look_up()

GAME_VERB(/mob/living, lookdown_verb, "Look Down", "IC")
	if(looking_vertically)
		to_chat(src, "You set your head straight again.")
		end_look()
		return

	var/turf/current_turf = get_turf(src)
	var/turf/below_turf = GET_TURF_BELOW(current_turf)

	if(!below_turf)
		to_chat(src, span_warning("There's nothing interesting below. Better keep your eyes ahead."))
		return

	to_chat(src, "You tilt your head downwards.")
	look_down()

GAME_VERB(/mob, up_verb, "Move Upwards", "IC")
	if(remote_control)
		return remote_control.relaymove(src, UP)

	var/turf/current_turf = get_turf(src)

	if(ismovable(loc))
		var/atom/loc_atom = loc
		return loc_atom.relaymove(src, UP)

	var/obj/structure/ladder/current_ladder = locate() in current_turf
	if(current_ladder)
		current_ladder.use(src, TRUE)
		return

	if(!can_z_move(UP, current_turf, null, ZMOVE_CAN_FLY_CHECKS|ZMOVE_FEEDBACK))
		return
	balloon_alert(src, "moving up...")
	if(!do_after(src, 1 SECONDS, hidden = TRUE))
		return
	if(zMove(UP, z_move_flags = ZMOVE_FLIGHT_FLAGS|ZMOVE_FEEDBACK))
		to_chat(src, span_notice("You move upwards."))

GAME_VERB(/mob, down_verb, "Move Down", "IC")
	if(remote_control)
		return remote_control.relaymove(src, DOWN)

	var/turf/current_turf = get_turf(src)

	if(ismovable(loc))
		var/atom/loc_atom = loc
		return loc_atom.relaymove(src, DOWN)

	var/obj/structure/ladder/current_ladder = locate() in current_turf
	if(current_ladder)
		current_ladder.use(src, FALSE)
		return

	if(!can_z_move(DOWN, current_turf, null, ZMOVE_CAN_FLY_CHECKS|ZMOVE_FEEDBACK))
		return
	balloon_alert(src, "moving down...")
	if(!do_after(src, 1 SECONDS, hidden = TRUE))
		return
	if(zMove(DOWN, z_move_flags = ZMOVE_FLIGHT_FLAGS|ZMOVE_FEEDBACK))
		to_chat(src, span_notice("You move down."))
	return FALSE

GAME_VERB(/mob/living, navigate_verb, "Navigate", "IC")
	if(incapacitated)
		return
	if(length(client.navigation_images))
		addtimer(CALLBACK(src, PROC_REF(cut_navigation)), world.tick_lag)
		balloon_alert(src, "navigation path removed")
		return
	if(!COOLDOWN_FINISHED(src, navigate_cooldown))
		balloon_alert(src, "navigation on cooldown!")
		return
	addtimer(CALLBACK(src, PROC_REF(create_navigation)), world.tick_lag)

GAME_VERB_INSTANT(/mob, say_verb_veilbreak, "Say", "IC")
	VERB_ARG(message, VERB_ARG_TYPE_TEXT, VERB_ARG_SOURCE_INPUT)
	if(GLOB.say_disabled)
		to_chat(src, span_danger("Speech is currently admin-disabled."))
		return

	if(message)
		QUEUE_OR_CALL_VERB_FOR(VERB_CALLBACK(src, TYPE_PROC_REF(/atom/movable, say), message), SSspeech_controller)

GAME_VERB_INSTANT(/mob, whisper_verb_veilbreak, "Whisper", "IC")
	VERB_ARG(message, VERB_ARG_TYPE_TEXT, VERB_ARG_SOURCE_INPUT)
	if(GLOB.say_disabled)
		to_chat(src, span_danger("Speech is currently admin-disabled."))
		return

	if(message)
		QUEUE_OR_CALL_VERB_FOR(VERB_CALLBACK(src, TYPE_PROC_REF(/mob, whisper), message), SSspeech_controller)

GAME_VERB_DESC_INSTANT(/mob, me_verb_veilbreak, "Me", "Perform a custom emote. Leave blank to pick between an audible or a visible emote (Defaults to visible).", "IC")
	VERB_ARG(message, VERB_ARG_TYPE_TEXT, VERB_ARG_SOURCE_INPUT)
	if(GLOB.say_disabled)
		to_chat(src, span_danger("Speech is currently admin-disabled."))
		return

	message = trim(copytext_char(html_encode(message), 1, MAX_MESSAGE_LEN))

	QUEUE_OR_CALL_VERB_FOR(VERB_CALLBACK(src, TYPE_PROC_REF(/mob, emote), "me", NONE, message, TRUE), SSspeech_controller)

GAME_VERB(/mob, pray_verb, "Pray", "IC")
	VERB_ARG(msg, VERB_ARG_TYPE_TEXT, VERB_ARG_SOURCE_INPUT)
	if(GLOB.say_disabled)
		to_chat(src, span_danger("Speech is currently admin-disabled."), confidential = TRUE)
		return

	msg = copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN)
	if(!msg)
		return
	log_prayer("[src.key]/([src.name]): [msg]")
	if(src.client)
		if(src.client.prefs.muted & MUTE_PRAY)
			to_chat(src, span_danger("You cannot pray (muted)."), confidential = TRUE)
			return
		if(src.client.handle_spam_prevention(msg, MUTE_PRAY))
			return

	var/mutable_appearance/cross = mutable_appearance('icons/obj/storage/book.dmi', "bible")
	var/font_color = "purple"
	var/prayer_type = "PRAYER"
	var/deity
	if(job == JOB_CHAPLAIN)
		cross.icon_state = "kingyellow"
		font_color = "blue"
		prayer_type = "CHAPLAIN PRAYER"
		if(GLOB.deity)
			deity = GLOB.deity
	else if(IS_CULTIST(src))
		cross.icon_state = "tome"
		font_color = "red"
		prayer_type = "CULTIST PRAYER"
		deity = "Nar'Sie"
	else if(isliving(src))
		var/mob/living/living_mob = src
		if(HAS_TRAIT(living_mob, TRAIT_SPIRITUAL))
			cross.icon_state = "holylight"
			font_color = "blue"
			prayer_type = "SPIRITUAL PRAYER"

	var/msg_tmp = msg
	GLOB.requests.pray(src.client, msg, job == JOB_CHAPLAIN)
	msg = span_adminnotice("[icon2html(cross, GLOB.admins)]<b><font color=[font_color]>[prayer_type][deity ? " (to [deity])" : ""]: </font>[ADMIN_FULLMONTY(src)] [ADMIN_SC(src)]:</b> [span_linkify(msg)]")
	for(var/client/C in GLOB.admins)
		if(get_chat_toggles(C) & CHAT_PRAYER)
			to_chat(C, msg, type = MESSAGE_TYPE_PRAYER, confidential = TRUE)
	to_chat(src, span_info("You pray to the gods: \"[msg_tmp]\""), confidential = TRUE)

	BLACKBOX_LOG_ADMIN_VERB("Prayer")
