/turf/open/CanBuildHere()
	if(isspaceturf(src) && destination_z)
		return FALSE
	return TRUE

/obj/item/construction/rcd/rcd_create(atom/target, mob/user)
	log_world("RCD_DBG_ENTER target=[target.type] isopenturf=[isopenturf(target)] mode=[mode] path=[rcd_design_path]")
	var/result = ..()
	log_world("RCD_DBG_EXIT result=[result]")
	return result
