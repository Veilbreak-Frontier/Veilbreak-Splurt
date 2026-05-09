/obj/item/custom_tattoo_kit
	name = "professional tattoo kit"
	desc = "A complete tattoo application system with multiple ink reservoirs and precision needles."
	icon = 'modular_zzveilbreak/icons/item_icons/tattoo.dmi'
	icon_state = "tgun"
	w_class = WEIGHT_CLASS_SMALL
	var/ink_uses = 30
	var/max_ink_uses = 30
	var/mob/living/carbon/human/current_target = null
	var/next_use = 0

/obj/item/custom_tattoo_kit/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/custom_tattoo_kit/Destroy()
	current_target = null
	return ..()

/obj/item/custom_tattoo_kit/examine(mob/user)
	. = ..()
	. += span_info("Ink remaining: [ink_uses]/[max_ink_uses]")

/obj/item/custom_tattoo_kit/update_icon_state()
	icon_state = (ink_uses > 0) ? "tgun" : "tgun_empty"
	return ..()

/obj/item/custom_tattoo_kit/attack(mob/living/target, mob/living/user, params)
	if(!iscarbon(target))
		return ..()

	var/mob/living/carbon/human/human_target = target

	if(human_target.client && !human_target.client.prefs?.read_preference(/datum/preference/toggle/erp/allow_bodywriting))
		to_chat(user, span_warning("[human_target] doesn't allow body modifications!"))
		return TRUE

	current_target = human_target
	ui_interact(user)
	return TRUE

/obj/item/custom_tattoo_kit/proc/refill_ink(mob/user)
	if(ink_uses >= max_ink_uses)
		to_chat(user, span_warning("The tattoo kit is already full of ink."))
		return

	var/obj/item/toner/cartridge = user.get_inactive_held_item()
	if(!istype(cartridge))
		to_chat(user, span_warning("You need to hold a toner cartridge in your other hand to refill the kit!"))
		return

	if(cartridge.charges <= 0)
		to_chat(user, span_warning("[cartridge] is empty!"))
		return

	to_chat(user, span_notice("You begin refilling the [src] with toner..."))

	if(!do_after(user, 2 SECONDS, target = src))
		return

	var/transfer_amount = min(max_ink_uses - ink_uses, cartridge.charges)

	ink_uses += transfer_amount

	if(cartridge.charges != INFINITY)
		cartridge.charges -= transfer_amount

	to_chat(user, span_notice("You refill the [src] using [transfer_amount] units from [cartridge]."))

	update_appearance()
	if(current_target)
		ui_interact(user)

/obj/item/custom_tattoo_kit/proc/can_apply_tattoo(mob/user)
	if(!current_target)
		to_chat(user, span_warning("No target selected."))
		return FALSE

	var/datum/custom_tattoo_ui_data/ui_data = current_target.get_tattoo_ui_data("global")
	if(!ui_data)
		to_chat(user, span_warning("UI data not found."))
		return FALSE

	if(!ui_data.is_ready_for_application())
		to_chat(user, span_warning("Design not complete or no body part selected."))
		return FALSE

	if(ink_uses <= 0)
		to_chat(user, span_warning("No ink remaining."))
		return FALSE

	if(!is_custom_tattoo_bodypart_existing(current_target, ui_data.zone))
		to_chat(user, span_warning("Body part doesn't exist."))
		return FALSE

	if(!get_custom_tattoo_location_accessible(current_target, ui_data.zone))
		to_chat(user, span_warning("Body part is not accessible."))
		return FALSE

	var/current_tattoos = length(current_target.get_custom_tattoos(ui_data.zone))
	if(current_tattoos >= CUSTOM_MAX_TATTOOS_PER_PART)
		to_chat(user, span_warning("Maximum tattoos reached for this body part."))
		return FALSE

	return TRUE

/obj/item/custom_tattoo_kit/proc/apply_tattoo(mob/user)
	if(!can_apply_tattoo(user))
		return FALSE

	to_chat(user, span_notice("You begin carefully applying the tattoo..."))

	if(!do_after(user, CUSTOM_TATTOO_APPLICATION_TIME, target = current_target))
		to_chat(user, span_warning("Tattoo application interrupted!"))
		return FALSE

	var/datum/custom_tattoo_ui_data/ui_data = current_target.get_tattoo_ui_data("global")
	if(!ui_data)
		to_chat(user, span_warning("UI data lost during application."))
		return FALSE

	var/is_signature_format = findtext(ui_data.artist_name, "%s")
	var/final_artist = ui_data.artist_name
	if(is_signature_format)
		final_artist = replacetext(final_artist, "%s", user.name)

	var/datum/custom_tattoo/new_tattoo = new(
		final_artist,
		ui_data.tattoo_design,
		ui_data.zone,
		ui_data.ink_color,
		ui_data.selected_layer,
		is_signature_format,
		ui_data.selected_font,
		ui_data.selected_flair
	)

	if(current_target.add_custom_tattoo(new_tattoo))
		ink_uses = max(0, ink_uses - 1)

		var/major_zone_string = get_major_body_zone_string_for_tattoo_zone(ui_data.zone)
		var/damage_amount = 20

		var/damage_type = BRUTE
		var/pain_message = span_warning("The intense process causes a deep, sharp pain, and the area feels bruised and raw.")

		if(issynthetic(current_target))
			damage_type = FIRE
			pain_message = span_warning("Your internal sensors pulse with heat warnings as the needle etches into your plating.")

		current_target.apply_damage(damage_amount, damage_type, major_zone_string)
		to_chat(current_target, pain_message)

		next_use = world.time + 2 SECONDS
		current_target.regenerate_icons()
		update_appearance()

		ui_data.artist_name = ""
		ui_data.tattoo_design = ""

		SStgui.update_uis(src)
		to_chat(user, span_green("Tattoo applied successfully!"))
		return TRUE
	else
		to_chat(user, span_warning("Failed to apply tattoo!"))
		return FALSE
