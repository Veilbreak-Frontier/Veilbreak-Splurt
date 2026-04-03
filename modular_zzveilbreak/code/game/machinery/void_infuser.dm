/obj/machinery/void_infuser
	name = "void infuser"
	desc = "A strange, pulsing machine that infuses items with void shards."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "protolathe"
	density = TRUE
	anchored = TRUE
	var/is_infusing = FALSE

/obj/machinery/void_infuser/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/voidshard) || W.w_class <= WEIGHT_CLASS_BULKY)
		if(contents.len >= 2)
			to_chat(user, "<span class='warning'>\The [src] is full!</span>")
			return TRUE
		if(is_infusing)
			to_chat(user, "<span class='warning'>\The [src] is busy infusing!</span>")
			return TRUE
		if(!user.transferItemToLoc(W, src))
			return TRUE
		to_chat(user, "<span class='notice'>You insert \the [W] into \the [src].</span>")
		return TRUE
	return ..()

/obj/machinery/void_infuser/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "VoidInfuser")
		ui.open()

/obj/machinery/void_infuser/ui_data(mob/user)
	var/list/data = list()
	data["is_infusing"] = is_infusing
	
	var/list/items = list()
	var/has_shard = FALSE
	var/has_target = FALSE
	
	for(var/obj/item/I in contents)
		var/list/item_data = list()
		item_data["name"] = I.name
		item_data["ref"] = REF(I)
		item_data["icon"] = icon2base64(getFlatIcon(image(icon = I.icon, icon_state = I.icon_state), no_anim = TRUE))
		item_data["is_shard"] = istype(I, /obj/item/voidshard)
		
		if(istype(I, /obj/item/voidshard))
			has_shard = TRUE
		else
			has_target = TRUE
			
		items += list(item_data)
		
	data["items"] = items
	data["can_infuse"] = (has_shard && has_target)
	
	return data

/obj/machinery/void_infuser/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return
		
	if(is_infusing)
		return TRUE

	var/mob/user = usr
	switch(action)
		if("eject")
			var/obj/item/target = locate(params["ref"]) in contents
			if(!target)
				return TRUE
			target.forceMove(drop_location())
			to_chat(user, "<span class='notice'>You eject \the [target] from \the [src].</span>")
			return TRUE
			
		if("infuse")
			var/obj/item/voidshard/shard = locate(/obj/item/voidshard) in contents
			var/obj/item/target_item
			for(var/obj/item/I in contents)
				if(I != shard)
					target_item = I
					break
					
			if(!shard || !target_item)
				return TRUE
				
			is_infusing = TRUE
			to_chat(user, "<span class='notice'>\The [src] starts humming as it prepares the infusion...</span>")
			
			// Force UI update so it shows as infusing
			SStgui.update_uis(src)
			
			INVOKE_ASYNC(src, PROC_REF(do_infuse), user, shard, target_item)
			return TRUE

/obj/machinery/void_infuser/proc/do_infuse(mob/user, obj/item/voidshard/shard, obj/item/target_item)
	if(do_after(user, 3 SECONDS, target=src))
		if(!(shard in contents) || !(target_item in contents))
			is_infusing = FALSE
			SStgui.update_uis(src)
			return

		var/success = FALSE
		var/datum/void_infusion_recipe/recipe
		for(var/T in subtypesof(/datum/void_infusion_recipe))
			var/datum/void_infusion_recipe/R = new T()
			if(R.matches(target_item))
				recipe = R
				break
		
		if(recipe)
			success = recipe.apply(target_item)
			if(success)
				playsound(loc, 'modular_zzveilbreak/sound/effects/shard-infusion.mp3', 50, 1)
				qdel(shard)

		if(success)
			to_chat(user, "<span class='notice'>\The [src] dings successfully! The infusion is complete.</span>")
		else
			to_chat(user, "<span class='warning'>\The [src] buzzes angrily. The infusion failed. \The [target_item] might not be compatible or is already infused.</span>")
		
		for(var/obj/item/I in contents)
			I.forceMove(drop_location())
			
	is_infusing = FALSE
	SStgui.update_uis(src)
