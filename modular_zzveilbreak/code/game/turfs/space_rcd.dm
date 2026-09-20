GLOBAL_VAR_INIT(rcd_debug_logging, TRUE)

/proc/rcd_debug_log(atom/target, mob/user, obj/item/construction/rcd/the_rcd)
	if(!GLOB.rcd_debug_logging)
		return

	var/turf/open/open_turf = target
	var/user_key = user ? user.ckey : "n/a"
	var/rcd_mode = the_rcd ? the_rcd.mode : -1
	var/rcd_path = the_rcd ? the_rcd.rcd_design_path : "n/a"

	log_world("RCD_DBG user=[user_key] target=[target.type] dz=[open_turf.destination_z] dx=[open_turf.destination_x] dy=[open_turf.destination_y] cbh=[open_turf.CanBuildHere()] mode=[rcd_mode] path=[rcd_path]")

/obj/item/construction/rcd/rcd_create(atom/target, mob/user)
	if(isopenturf(target))
		var/turf/open/open = target
		if(!open.CanBuildHere())
			rcd_debug_log(target, user, src)
	return ..()
