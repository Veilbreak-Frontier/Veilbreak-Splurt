/*
/obj/item/reagent_containers/cup
	var/beingChugged = FALSE // For checking

/obj/item/reagent_containers/cup/try_drink(mob/living/target_mob, mob/living/user)
	if(target_mob == user && user.zone_selected == BODY_ZONE_PRECISE_MOUTH && !beingChugged && reagents && reagents.total_volume > 5)
		beingChugged = TRUE
		user.visible_message(span_notice("[user] starts chugging [src]."), \
			span_notice("You start chugging [src]."))
		if(!do_after(user, 3 SECONDS, target_mob))
			beingChugged = FALSE
			return ITEM_INTERACT_BLOCKING
		if(!reagents || !reagents.total_volume)
			beingChugged = FALSE
			return ITEM_INTERACT_BLOCKING

		var/original_gulp_size = gulp_size
		gulp_size = 50
		user.visible_message(span_notice("[user] chugs [src]."), \
			span_notice("You chug [src]."))
		. = ..()
		gulp_size = original_gulp_size
		beingChugged = FALSE
		return .
	return ..()
*/
