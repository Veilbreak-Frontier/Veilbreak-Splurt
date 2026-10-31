/obj/item/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	// If the player's active hand is empty, show the "Pick up" prompt
	if(isnull(held_item))
		context[SCREENTIP_CONTEXT_LMB] = "Pick up"
		return CONTEXTUAL_SCREENTIP_SET

/turf/open/Initialize(mapload)
	. = ..()
	register_context()

/turf/open/register_context()
	flags_1 |= HAS_CONTEXTUAL_SCREENTIPS_1
	RegisterSignal(src, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM, PROC_REF(add_context_floor_items), TRUE)

/turf/open/proc/add_context_floor_items(turf/source, list/context, obj/item/held_item, mob/user)
	SIGNAL_HANDLER

	// Scan through items loose on the ground
	for(var/obj/item/I in source)
		if(I.invisibility > user.see_invisible)
			continue

		// Let the item add its context text (which will now be "Pick up" thanks to Part 1)
		var/item_res = I.add_context(source, context, held_item, user)
		if(item_res == CONTEXTUAL_SCREENTIP_SET)
			return CONTEXTUAL_SCREENTIP_SET

	return NONE
