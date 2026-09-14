GAME_VERB(/mob, open_language_menu_verb, "Open Language Menu", "IC")
	get_language_holder().open_language_menu(usr)

GAME_VERB(/mob/living, emote_panel, "Emote Panel", "IC")
	var/static/datum/emote_panel/emote_panel
	if(isnull(emote_panel))
		emote_panel = new
	emote_panel.ui_interact(src)
