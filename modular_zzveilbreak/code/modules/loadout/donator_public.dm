/// VEILBREAK: Donator-tier and ckey-locked loadout items are available to all players.

/datum/loadout_item/New(category)
	. = ..()
	donator_only = FALSE

/datum/preference_middleware/loadout/select_item(datum/loadout_item/selected_item)
	var/list/loadout = get_current_loadout()
	var/list/datum/loadout_item/loadout_datums = loadout_list_to_datums(loadout)
	for(var/datum/loadout_item/item as anything in loadout_datums)
		if(item.category != selected_item.category)
			continue
		if(!item.category.handle_duplicate_entires(src, item, selected_item, loadout_datums))
			return

	LAZYSET(loadout, selected_item.item_path, list())
	save_current_loadout(loadout)
	preferences.character_preview_view?.update_body()
