#define SHEET_BAG_BALOON_COOLDOWN (2 SECONDS)
// overides for bags but mostly the sheet snatcher


/obj/item/storage/bag/sheetsnatcher
	name = "sheet snatcher"
	desc = "A patented Nanotrasen storage system designed for any kind of mineral sheet."
	icon = 'icons/obj/mining.dmi'
	icon_state = "sheetsnatcher"
	worn_icon_state = "satchel"
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_NORMAL
	storage_type = /datum/storage/bag/sheet_snatcher
//sheets replace ore
// If TRUE the holder wont recieve any messages when failing to pick up sheets
	var/spam_protection = FALSE
// Mob/User being tracked
	var/mob/listening_to = null
// Are we dropping off sheets? used to prevent immiedete pickup after dropping (yes this whole thing is just a rehash of ore bags)
	var/dropping_sheets = FALSE
// Cooldown for Bubble messages recieved by the mob/user
	COOLDOWN_DECLARE(sheet_bag_baloon_cooldown)

/obj/item/storage/bag/sheetsnatcher/Destroy(force)
	listening_to = null
	. = ..()

/obj/item/storage/bag/sheetsnatcher/equipped(mob/user)
	.=..()
	listening_to = user
	if (!listening_to)
		return
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_user_moved))
	if (isturf(user.loc))
		RegisterSignal(user.loc, COMSIG_ATOM_ENTERED, PROC_REF(on_obj_entered))
		RegisterSignal(user.loc, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, PROC_REF(on_atom_initialized_on))
	listening_to = user

/obj/item/storage/bag/sheetsnatcher/dropped()
	.=..()
	if (!listening_to)
		return
	UnregisterSignal(listening_to, COMSIG_MOVABLE_MOVED)
	if (listening_to.loc)
		UnregisterSignal(listening_to.loc, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON))
	listening_to = null

// Make sure we dont suck up those yummy sheets again
/obj/item/storage/bag/sheetsnatcher/attack_self(mob/user, modifiers)
	dropping_sheets = TRUE
	. = ..()
	dropping_sheets = FALSE

/obj/item/storage/bag/sheetsnatcher/proc/on_user_moved(mob/living/user, atom/old_loc, dir, forced)
	SIGNAL_HANDLER

	if(old_loc)
		UnregisterSignal(old_loc, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON))

	var/turf/tile = get_turf(user)
	if(!isturf(tile))
		return

	RegisterSignal(tile, COMSIG_ATOM_ENTERED, PROC_REF(on_obj_entered))
	RegisterSignal(tile, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, PROC_REF(on_atom_initialized_on))
	INVOKE_ASYNC(src, PROC_REF(handle_move), user)

/obj/item/storage/bag/sheetsnatcher/proc/handle_move(mob/living/user)
	var/turf/tile/ = get_turf(user)

	var/show_message = FALSE
	for(var/atom/thing as anything in tile)
		if(!is_type_in_typecache(thing, atom_storage.can_hold))
			continue
		if(pickup_sheets(thing, user))
			show_message = TRUE

	if(!show_message)
		spam_protection = FALSE
		return

	playsound(user, SFX_RUSTLE, 50, TRUE)
	if(!COOLDOWN_FINISHED(src, sheet_bag_baloon_cooldown))
		return

	spam_protection = FALSE
	COOLDOWN_START(src, sheet_bag_baloon_cooldown, SHEET_BAG_BALOON_COOLDOWN)

	balloon_alert(user, "Moves material sheets into bag")
	user.visible_message(
		span_notice("[user] moves the sheets beneath [user.p_them()]."),
		ignored_mobs = user
	)

/obj/item/storage/bag/sheetsnatcher/proc/pickup_sheets(obj/item/stack/sheet, mob/user)
	if (istype(sheet, /obj/item/stack/sheet))
		var/obj/item/stack/sheet/real_sheet = sheet
		for(var/obj/item/stack/sheet/stored_sheet as anything in src)
			if(!real_sheet.can_merge(stored_sheet))
				continue
			real_sheet.merge(stored_sheet)
			if(QDELETED(real_sheet))
				return TRUE

	if (atom_storage.attempt_insert(sheet, user))
		return TRUE

	if (!spam_protection)
		balloon_alert(user, "bag full!")
		spam_protection = TRUE
	return FALSE

/obj/item/storage/bag/sheetsnatcher/proc/on_obj_entered(atom/new_loc, atom/movable/arrived, atom/old_loc)
	SIGNAL_HANDLER
	if(is_type_in_list(arrived, atom_storage.can_hold) && !dropping_sheets && old_loc != loc)
		INVOKE_ASYNC(src, PROC_REF(pickup_sheets), arrived, listening_to)

/obj/item/storage/bag/sheetsnatcher/proc/on_atom_initialized_on(atom/loc, atom/new_atom)
	SIGNAL_HANDLER
	if(is_type_in_list(new_atom, atom_storage.can_hold))
		INVOKE_ASYNC(src, PROC_REF(pickup_sheets), new_atom, listening_to)




#undef SHEET_BAG_BALOON_COOLDOWN
