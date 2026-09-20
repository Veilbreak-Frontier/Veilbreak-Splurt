GLOBAL_VAR_INIT(rcd_debug_logging, TRUE)

/proc/rcd_dbg(stage, atom/target, mob/user, obj/item/tool, extra)
	if(!GLOB.rcd_debug_logging)
		return
	var/user_key = user ? user.ckey : "n/a"
	var/tool_type = tool ? tool.type : "n/a"
	var/target_type = target ? target.type : "null"
	log_world("RCD_DBG [stage] user=[user_key] target=[target_type] tool=[tool_type] [extra]")

/turf/open/CanBuildHere()
	if(isspaceturf(src) && destination_z)
		return FALSE
	return TRUE

/turf/open/space/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	rcd_dbg("SPACE_II_ENTER", src, user, tool, "blocker=[ITEM_INTERACT_ANY_BLOCKER & .]")

	if(ITEM_INTERACT_ANY_BLOCKER & .)
		rcd_dbg("SPACE_II_EXIT", src, user, tool, "reason=blocker result=[.]")
		return .

	if(istype(tool, /obj/item/stack/rods))
		if(!CanBuildHere())
			rcd_dbg("SPACE_II_EXIT", src, user, tool, "reason=canbuildhere result=NONE")
			return .
		build_with_rods(tool, user)
		rcd_dbg("SPACE_II_EXIT", src, user, tool, "reason=rods result=SUCCESS")
		return ITEM_INTERACT_SUCCESS

	if(ismetaltile(tool))
		if(!CanBuildHere())
			rcd_dbg("SPACE_II_EXIT", src, user, tool, "reason=canbuildhere result=NONE")
			return .
		build_with_floor_tiles(tool, user)
		rcd_dbg("SPACE_II_EXIT", src, user, tool, "reason=tiles result=SUCCESS")
		return ITEM_INTERACT_SUCCESS

	rcd_dbg("SPACE_II_EXIT", src, user, tool, "reason=fallthrough result=NONE")
	return NONE

/turf/open/openspace/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	rcd_dbg("OPENSPACE_II_ENTER", src, user, tool, "blocker=[ITEM_INTERACT_ANY_BLOCKER & .]")

	if(ITEM_INTERACT_ANY_BLOCKER & .)
		rcd_dbg("OPENSPACE_II_EXIT", src, user, tool, "reason=blocker result=[.]")
		return .

	if(istype(tool, /obj/item/stack/rods))
		if(!CanBuildHere())
			rcd_dbg("OPENSPACE_II_EXIT", src, user, tool, "reason=canbuildhere result=NONE")
			return .
		build_with_rods(tool, user)
		rcd_dbg("OPENSPACE_II_EXIT", src, user, tool, "reason=rods result=SUCCESS")
		return ITEM_INTERACT_SUCCESS

	if(ismetaltile(tool))
		if(!CanBuildHere())
			rcd_dbg("OPENSPACE_II_EXIT", src, user, tool, "reason=canbuildhere result=NONE")
			return .
		build_with_floor_tiles(tool, user)
		rcd_dbg("OPENSPACE_II_EXIT", src, user, tool, "reason=tiles result=SUCCESS")
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/stack/thermoplastic))
		if(!CanBuildHere())
			rcd_dbg("OPENSPACE_II_EXIT", src, user, tool, "reason=canbuildhere result=NONE")
			return .
		build_with_transport_tiles(tool, user)
		rcd_dbg("OPENSPACE_II_EXIT", src, user, tool, "reason=thermoplastic result=SUCCESS")
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/stack/sheet/mineral/titanium))
		if(!CanBuildHere())
			rcd_dbg("OPENSPACE_II_EXIT", src, user, tool, "reason=canbuildhere result=NONE")
			return .
		build_with_titanium(tool, user)
		rcd_dbg("OPENSPACE_II_EXIT", src, user, tool, "reason=titanium result=SUCCESS")
		return ITEM_INTERACT_SUCCESS

	rcd_dbg("OPENSPACE_II_EXIT", src, user, tool, "reason=fallthrough result=NONE")
	return NONE

/obj/item/construction/rcd/rcd_create(atom/target, mob/user)
	rcd_dbg("RCD_CREATE_ENTER", target, user, src, "isopenturf=[isopenturf(target)]")
	var/result = ..()
	rcd_dbg("RCD_CREATE_EXIT", target, user, src, "result=[result]")
	return result

/obj/item/holosign_creator/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	rcd_dbg("HOLO_IA_ENTER", interacting_with, user, src, "signs=[LAZYLEN(signs)] busy=[holocreator_busy]")
	var/result = ..()
	rcd_dbg("HOLO_IA_EXIT", interacting_with, user, src, "result=[result]")
	return result
