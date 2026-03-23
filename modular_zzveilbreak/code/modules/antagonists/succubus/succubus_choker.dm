/// Unremovable choker given at mark level 4. Text supports %VICTIM% and %ANTAG% placeholders.
/obj/item/clothing/neck/succubus_choker
	name = "enslaving choker"
	desc = "A collar that cannot be removed. It bears an inscription."
	icon = 'icons/obj/clothing/neck.dmi'
	icon_state = "petcollar"
	worn_icon = 'icons/mob/clothing/neck.dmi'
	worn_icon_state = "petcollar"
	slot_flags = ITEM_SLOT_NECK
	/// Custom text shown on examine; %VICTIM% and %ANTAG% replaced
	var/choker_text = SUCCUBUS_CHOKER_DEFAULT_TEXT
	/// Ref to the mark datum (so we know not to allow removal)
	var/datum/succubus_mark/mark_datum
	/// Cached for text replacement
	var/victim_name = ""
	var/antag_name = ""

/obj/item/clothing/neck/succubus_choker/proc/update_choker_text()
	choker_text = replacetext(SUCCUBUS_CHOKER_DEFAULT_TEXT, "%VICTIM%", victim_name)
	choker_text = replacetext(choker_text, "%ANTAG%", antag_name)

/obj/item/clothing/neck/succubus_choker/examine(mob/user)
	. = ..()
	. += span_pink("It reads: \"[choker_text]\"")

/obj/item/clothing/neck/succubus_choker/dropped(mob/user)
	. = ..()
	// Re-equip to neck if still marked
	if(mark_datum && user?.mind == mark_datum.victim_mind)
		addtimer(CALLBACK(src, PROC_REF(force_reequip), user), 10 DECISECONDS)
	else
		mark_datum = null

/obj/item/clothing/neck/succubus_choker/proc/force_reequip(mob/living/carbon/human/user)
	if(!user || !mark_datum || mark_datum.victim_mind != user.mind)
		return
	user.equip_to_slot_if_possible(src, ITEM_SLOT_NECK, disable_warning = TRUE)
	if(loc != user)
		user.put_in_hands(src) // as fallback keep it on them

/obj/item/clothing/neck/succubus_choker/equipped(mob/user, slot)
	. = ..()

/// Prevent removal by resist or other means when mark is active
/obj/item/clothing/neck/succubus_choker/attack_hand(mob/user)
	if(mark_datum && user == loc)
		to_chat(user, span_warning("The choker won't come off."))
		return TRUE
	return ..()

/obj/item/clothing/neck/succubus_choker/on_found(mob/finder)
	if(mark_datum && ishuman(finder))
		var/mob/living/carbon/human/H = finder
		if(H.mind == mark_datum.victim_mind)
			H.equip_to_slot_if_possible(src, ITEM_SLOT_NECK, disable_warning = TRUE)
			return
	return ..()
