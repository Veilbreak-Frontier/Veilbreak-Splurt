/turf/open/CanBuildHere()
	if(isspaceturf(src) && destination_z)
		return FALSE
	return TRUE

/obj/item/construction/rcd/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	log_world("RCD_DBG_IA_ENTER target=[interacting_with.type]")
	. = ..()
	log_world("RCD_DBG_IA_EXIT target=[interacting_with.type] result=[.]")
	if(. & ITEM_INTERACT_ANY_BLOCKER)
		return .
	mode = construction_mode
	return rcd_create(interacting_with, user)

/obj/item/construction/rcd/handle_openspace_click(turf/target, mob/user, list/modifiers)
	log_world("RCD_DBG_OSC target=[target.type]")
	interact_with_atom(target, user, modifiers)

/obj/item/construction/rcd/rcd_create(atom/target, mob/user)
	log_world("RCD_DBG_ENTER target=[target.type] isopenturf=[isopenturf(target)] mode=[mode] path=[rcd_design_path]")
	var/result = ..()
	log_world("RCD_DBG_EXIT result=[result]")
	return result
