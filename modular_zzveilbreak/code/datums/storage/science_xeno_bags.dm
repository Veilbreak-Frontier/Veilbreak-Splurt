/// Veilbreak: science bags accept crossbred slime items; those count as several raw cores for capacity.

/// How many "raw extract units" a crossbred /obj/item/slimecross occupies versus a /obj/item/slime_extract.
#define SCIENCE_BAG_CROSSBRED_STORAGE_COST 5

/datum/storage/bag/xeno/proc/xeno_bag_effective_weight(obj/item/I)
	if(istype(I, /obj/item/slimecross))
		return SCIENCE_BAG_CROSSBRED_STORAGE_COST * WEIGHT_CLASS_TINY
	return I.w_class

/datum/storage/bag/xeno/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(list(
		/obj/item/bodypart,
		/obj/item/food/deadmouse,
		/obj/item/food/monkeycube,
		/obj/item/organ,
		/obj/item/petri_dish,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/cup/tube,
		/obj/item/reagent_containers/syringe,
		/obj/item/slime_extract,
		/obj/item/slimecross,
		/obj/item/swab,
	))

/datum/storage/bag/xeno/get_total_weight()
	var/total_weight = 0
	for(var/obj/item/thing in real_location)
		total_weight += xeno_bag_effective_weight(thing)
	return total_weight

/datum/storage/bag/xeno/can_insert(obj/item/to_insert, mob/user, messages = TRUE, force = STORAGE_NOT_LOCKED)
	if(QDELETED(to_insert) || !istype(to_insert))
		return FALSE

	if(to_insert.item_flags & ABSTRACT)
		return FALSE
	if(parent.flags_1 & HOLOGRAM_1)
		if(!(to_insert.flags_1 & HOLOGRAM_1))
			return FALSE
	else if(to_insert.flags_1 & HOLOGRAM_1)
		return FALSE

	if(locked > force)
		if(messages && user)
			user.balloon_alert(user, "closed!")
		return FALSE

	if((to_insert == parent) || (to_insert == real_location))
		return FALSE

	if(to_insert.w_class > max_specific_storage)
		if(!is_type_in_typecache(to_insert, exception_hold))
			if(messages && user)
				user.balloon_alert(user, "too big!")
			return FALSE
		if(exception_max <= get_exception_count())
			if(messages && user)
				user.balloon_alert(user, "no room!")
			return FALSE

	if(real_location.contents.len >= max_slots)
		if(messages && user && !silent_for_user)
			user.balloon_alert(user, "no room!")
		return FALSE

	if(xeno_bag_effective_weight(to_insert) + get_total_weight() > max_total_storage)
		if(messages && user && !silent_for_user)
			user.balloon_alert(user, "no room!")
		return FALSE

	var/can_hold_it = isnull(can_hold) || is_type_in_typecache(to_insert, can_hold) || is_type_in_typecache(to_insert, exception_hold)
	var/cant_hold_it = is_type_in_typecache(to_insert, cant_hold)
	var/trait_says_no = HAS_TRAIT(to_insert, TRAIT_NO_STORAGE_INSERT)
	if(!can_hold_it || cant_hold_it || trait_says_no)
		if(messages && user)
			user.balloon_alert(user, "can't hold!")
		return FALSE

	if(HAS_TRAIT(to_insert, TRAIT_NODROP))
		if(messages && user)
			user.balloon_alert(user, "stuck on your hand!")
		return FALSE

	var/datum/storage/bigger_fish = parent.loc.atom_storage
	if(bigger_fish && bigger_fish.max_specific_storage < max_specific_storage)
		if(messages && user)
			user.balloon_alert(user, "[LOWER_TEXT(parent.loc.name)] is in the way!")
		return FALSE

	if(isitem(parent))
		var/obj/item/item_parent = parent
		var/datum/storage/smaller_fish = to_insert.atom_storage
		if(smaller_fish && !allow_big_nesting && to_insert.w_class >= item_parent.w_class)
			if(messages && user)
				user.balloon_alert(user, "too big!")
			return FALSE

	return TRUE

/datum/storage/bag/xeno/bluespace
	max_slots = 100
	max_total_storage = 800
