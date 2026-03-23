/obj/machinery/jukebox/online
	name = "online jukebox"
	desc = "A jukebox that can play tracks from the online library."
	icon_state = "jukebox"
	base_icon_state = "jukebox"
	processing_flags = START_PROCESSING_MANUALLY
	var/datum/online_jukebox/online_component

/obj/machinery/jukebox/online/Initialize(mapload)
	. = ..()
	music_player = new(src)
	online_component = new /datum/online_jukebox(src)

/obj/machinery/jukebox/online/Destroy()
	QDEL_NULL(online_component)
	QDEL_NULL(music_player)
	return ..()

/obj/machinery/jukebox/online/examine(mob/user)
	. = ..()
	if(online_component?.playing_online)
		. += span_notice("Now playing (Online): [online_component.online_track_name]")
	else if(music_player?.active_song_sound)
		. += span_notice("Now playing (Local): [music_player.selection.song_name]")

/obj/machinery/jukebox/online/update_icon_state()
	var/is_playing = (online_component?.playing_online || music_player?.active_song_sound)
	icon_state = "[base_icon_state][is_playing ? "-active" : ""]"
	return ..()

/obj/machinery/jukebox/online/interact(mob/user)
	if(isobserver(user))
		to_chat(user, span_warning("You cannot interact with the jukebox as an observer!"))
		return
	ui_interact(user)

/obj/machinery/jukebox/online/ui_interact(mob/user, datum/tgui/ui)
	return online_component?.ui?.ui_interact(user, ui)

/obj/machinery/jukebox/online/ui_status(mob/user, datum/ui_state/state)
	if(!anchored || isobserver(user))
		return UI_CLOSE
	return UI_INTERACTIVE

/obj/machinery/jukebox/online/ui_state(mob/user)
	return GLOB.physical_state

/obj/machinery/jukebox/online/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(held_item?.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = anchored ? "Unsecure" : "Secure"
	else
		context[SCREENTIP_CONTEXT_LMB] = "Interact"
	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/jukebox/online/wrench_act(mob/living/user, obj/item/tool)
	if(online_component?.playing_online || music_player?.active_song_sound)
		to_chat(user, span_warning("Stop the music before moving the jukebox!"))
		return TRUE
	if(default_unfasten_wrench(user, tool))
		if(!anchored)
			online_component?.stop_music()
			if(music_player)
				music_player.active_song_sound = null
				for(var/mob/M in GLOB.player_list)
					M.stop_sound_channel(CHANNEL_JUKEBOX)
		return TRUE
	return ..()

/obj/machinery/jukebox/online/power_change()
	. = ..()
	if(machine_stat & NOPOWER)
		online_component?.stop_music()
		if(music_player)
			music_player.active_song_sound = null
			for(var/mob/M in GLOB.player_list)
				M.stop_sound_channel(CHANNEL_JUKEBOX)
	update_appearance()

/obj/machinery/jukebox/online/Moved(atom/old_loc, dir, forced)
	. = ..()
	online_component?.update_all()
