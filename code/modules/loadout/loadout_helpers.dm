/datum/loadout_item/proc/is_allowed(mob/living/carbon/human/user)
    if(!ckeywhitelist)
        return TRUE
    if(lowertext(user.ckey) in ckeywhitelist)
        return TRUE
    return FALSE

/datum/loadout_item/New(category)
    src.category = category

    if(!(loadout_flags & LOADOUT_FLAG_BLOCK_GREYSCALING) && is_greyscale_item())
        loadout_flags |= LOADOUT_FLAG_GREYSCALING_ALLOWED

    if(loadout_flags & LOADOUT_FLAG_JOB_GREYSCALING)
        var/default_colors = SSgreyscale.ParseColorString(item_path::greyscale_colors)
        var/list/final_palette = LAZYLISTDUPLICATE(job_greyscale_palettes)
        switch(length(default_colors))
            if(1)
                LAZYOR(final_palette, default_one_color_job_palette())
            if(2 to INFINITY)
                stack_trace("[length(default_colors)] color job palettes are not implemented yet, please do so.")
        job_greyscale_palettes = final_palette

    if(isnull(name))
        name = item_path::name

    if(isnull(ui_icon) && isnull(ui_icon_state))
        ui_icon = item_path::icon_preview || item_path::icon
        ui_icon_state = item_path::icon_state_preview || item_path::icon_state

    if(loadout_flags & LOADOUT_FLAG_ALLOW_RESKIN)
        var/obj/item/dummy_item = new item_path()
        if(!length(dummy_item.unique_reskin))
            loadout_flags &= ~LOADOUT_FLAG_ALLOW_RESKIN
            stack_trace("Loadout item [item_path] has LOADOUT_FLAG_ALLOW_RESKIN but has no unique reskins.")
        else
            cached_reskin_options = dummy_item.unique_reskin.Copy()
        qdel(dummy_item)

    if(ckeywhitelist)
        for(var/i in 1 to length(ckeywhitelist))
            ckeywhitelist[i] = lowertext(ckey(ckeywhitelist[i]))

/mob/living/carbon/human/proc/equip_outfit_and_loadout(datum/outfit/outfit = /datum/outfit, datum/preferences/preference_source, visuals_only = FALSE, datum/job/equipping)
    if(isnull(preference_source))
        return equipOutfit(outfit, visuals_only)

    var/datum/outfit/equipped_outfit
    if(ispath(outfit, /datum/outfit))
        equipped_outfit = new outfit()
    else if(istype(outfit, /datum/outfit))
        equipped_outfit = outfit
    else
        CRASH("Invalid outfit passed to equip_outfit_and_loadout ([outfit])")

    var/list/preference_list = preference_source.read_preference(/datum/preference/loadout)
    preference_list = preference_list[preference_source.get_active_loadout_preset_name()]
    var/list/loadout_datums = loadout_list_to_datums(preference_list)
    var/obj/item/storage/briefcase/empty/travel_suitcase
    var/loadout_placement_preference = preference_source.read_preference(/datum/preference/choiced/loadout_override_preference)

    for(var/datum/loadout_item/item as anything in loadout_datums)
        var/ckey_pass = FALSE
        if(item.ckeywhitelist && (lowertext(ckey) in item.ckeywhitelist))
            ckey_pass = TRUE

        if(!ckey_pass)
            if(item.restricted_roles && equipping && !(equipping.title in item.restricted_roles))
                if(preference_source.parent)
                    to_chat(preference_source.parent, span_warning("You were unable to get a loadout item([initial(item.item_path.name)]) due to job restrictions!"))
                continue

            if(item.blacklisted_roles && equipping && (equipping.title in item.blacklisted_roles))
                if(preference_source.parent)
                    to_chat(preference_source.parent, span_warning("You were unable to get a loadout item([initial(item.item_path.name)]) due to job blacklists!"))
                continue

            if(item.restricted_species && !(dna.species.id in item.restricted_species))
                if(preference_source.parent)
                    to_chat(preference_source.parent, span_warning("You were unable to get a loadout item ([initial(item.item_path.name)]) due to species restrictions!"))
                continue

            if(item.donator_only && !SSplayer_ranks.is_donator(preference_source?.parent))
                if(preference_source.parent)
                    to_chat(preference_source.parent, span_warning("You were unable to get a loadout item ([initial(item.item_path.name)]) due to donator restrictions!"))
                continue

        if(item.ckeywhitelist && !ckey_pass)
            if(preference_source.parent)
                to_chat(preference_source.parent, span_warning("You were unable to get a loadout item ([initial(item.item_path.name)]) due to CKEY restrictions!"))
            continue

        if(loadout_placement_preference == LOADOUT_OVERRIDE_CASE && !visuals_only)
            if(!travel_suitcase)
                travel_suitcase = new(loc)
            new item.item_path(travel_suitcase)
        else
            item.insert_path_into_outfit(equipped_outfit, src, visuals_only, loadout_placement_preference)

    if(!equipped_outfit.equip(src, visuals_only))
        return FALSE

    if(travel_suitcase)
        put_in_hands(travel_suitcase)

    var/list/new_contents = get_all_gear(INCLUDE_PROSTHETICS|INCLUDE_ABSTRACT|INCLUDE_ACCESSORIES)
    var/update = NONE
    for(var/datum/loadout_item/item as anything in loadout_datums)
        update |= item.on_equip_item(
            equipped_item = (loadout_placement_preference == LOADOUT_OVERRIDE_CASE && !visuals_only) ? locate(item.item_path) in travel_suitcase : locate(item.item_path) in new_contents,
            item_details = preference_list?[item.item_path] || list(),
            equipper = src,
            outfit = equipped_outfit,
            visuals_only = visuals_only,
        )
    if(update)
        update_clothing(update)

    return TRUE

/proc/loadout_list_to_datums(list/loadout_list)
    var/list/datums = list()
    if(!length(GLOB.all_loadout_datums))
        CRASH("No loadout datums in the global loadout list!")
    for(var/path in loadout_list)
        var/actual_datum = GLOB.all_loadout_datums[path]
        if(!istype(actual_datum, /datum/loadout_item))
            stack_trace("Could not find ([path]) loadout item in the global list of loadout datums!")
            continue
        datums += actual_datum
    return datums

/proc/sanitize_loadout_list(list/passed_list)
	RETURN_TYPE(/list)

	var/list/list_to_clean = LAZYLISTDUPLICATE(passed_list)
	for(var/path in list_to_clean)
		if(!ispath(path))
			stack_trace("invalid path found in loadout list! (Path: [path])")
			LAZYREMOVE(list_to_clean, path)

		else if(!(path in GLOB.all_loadout_datums))
			stack_trace("invalid loadout slot found in loadout list! Path: [path]")
			LAZYREMOVE(list_to_clean, path)

	return list_to_clean

/obj/item/storage/briefcase/empty/PopulateContents()
    return
