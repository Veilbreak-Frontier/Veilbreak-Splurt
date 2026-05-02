/// Datum to handle interactions between a MODsuit and its parts.
/datum/mod_part
	/// The actual item we handle.
	var/obj/item/part_item = null
	/// Are we sealed?
	var/sealed = FALSE
	/// Message to user when unsealed.
	var/unsealed_message
	/// Message to user when sealed.
	var/sealed_message
	/// The layer the item will render on when unsealed.
	var/unsealed_layer
	/// The layer the item will render on when sealed.
	var/sealed_layer
	/// Can our part overslot over others?
	var/can_overslot = FALSE
	/// What are we overslotting over?
	var/obj/item/overslotting = null

/datum/mod_part/Destroy()
	// To avoid qdel loops in MOD control units, since they're also a part
	if (!QDELING(part_item))
		qdel(part_item)
	part_item = null
	overslotting = null
	return ..()

/datum/mod_part/proc/set_item(obj/item/new_part)
	part_item = new_part
	RegisterSignal(part_item, COMSIG_ITEM_GET_SEPARATE_WORN_OVERLAYS, PROC_REF(get_separate_worn_overlays))

// If we're overslotting an item, add its visual as an underlay
/datum/mod_part/proc/get_separate_worn_overlays(obj/item/source, list/overlays, mutable_appearance/standing, mutable_appearance/draw_target, isinhands, icon_file)
	SIGNAL_HANDLER
	if(!overslotting || sealed || !part_item)
		return
	if(ismob(source.loc))
		var/mob/living/L = source.loc
		if(L.get_item_by_slot(source.slot_flags) != source)
			return
	var/mutable_appearance/over_overlay = mutable_appearance(icon_file, source.icon_state)
	over_overlay.alpha = 150
	overlays += over_overlay
