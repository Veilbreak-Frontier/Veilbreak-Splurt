/datum/bodypart_overlay/mutant/taur_body/on_mob_insert(obj/item/organ/parent, mob/living/carbon/receiver)
	. = ..()

	var/datum/sprite_accessory/taur/accessory = sprite_datum
	if(accessory?.can_lay_down)
		can_lay_down = TRUE
		laydown_offset = accessory.laydown_offset
		add_verb(receiver, /mob/living/carbon/human/proc/veil_taur_toggle_laying)

	add_verb(receiver, /mob/living/carbon/human/proc/veil_taur_toggle_cropping)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(veil_strip_legacy_taur_verbs), receiver), 0)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(veil_refresh_taur_verbs), receiver), 1)

/proc/veil_strip_legacy_taur_verbs(mob/living/carbon/receiver)
	if(!istype(receiver))
		return
	remove_verb(receiver, /obj/item/organ/taur_body/proc/toggle_laying)
	remove_verb(receiver, /obj/item/organ/taur_body/proc/toggle_cropping)

/proc/veil_refresh_taur_verbs(mob/living/carbon/receiver)
	if(!istype(receiver))
		return
	if(!receiver.client)
		return
	receiver.client.init_verbs()

/proc/veil_untaur_verbs(mob/living/carbon/human/owner)
	if(!istype(owner))
		return
	remove_verb(owner, /mob/living/carbon/human/proc/veil_taur_toggle_laying)
	remove_verb(owner, /mob/living/carbon/human/proc/veil_taur_toggle_cropping)

GAME_VERB_PROC(/mob/living/carbon/human, veil_taur_toggle_laying, "Toggle Laying Down", "Taur")
	var/mob/living/carbon/human/owner = src
	if(!istype(owner))
		return

	var/obj/item/organ/taur_body/organ = owner.get_organ_by_type(/obj/item/organ/taur_body)
	if(isnull(organ))
		veil_untaur_verbs(owner)
		return

	var/datum/bodypart_overlay/mutant/taur_body/overlay = organ.bodypart_overlay
	if(!overlay?.can_lay_down)
		return

	if(owner.resting)
		to_chat(owner, span_notice("You have to be standing up in order to lay down properly!"))
		return

	if(overlay.laying_down)
		to_chat(owner, span_notice("You start lifting your body up."))
		if(!do_after(owner, 1 SECONDS))
			return
		if(!overlay.laying_down)
			return
		overlay.laying_down = FALSE
		owner.layer = initial(owner.layer)
		owner.pixel_y -= overlay.laydown_offset
		owner.update_body_parts()
		owner.SetImmobilized(0, TRUE)
		REMOVE_TRAIT(owner, TRAIT_UNDENSE, TRAIT_SOURCE_TAURLAY)
		to_chat(owner, span_notice("You stand up."))
	else
		overlay.laying_down = TRUE
		owner.layer = LYING_MOB_LAYER
		owner.pixel_y += overlay.laydown_offset
		owner.update_body_parts()
		owner.Immobilize(INFINITY, TRUE)
		ADD_TRAIT(owner, TRAIT_UNDENSE, TRAIT_SOURCE_TAURLAY)
		to_chat(owner, span_notice("You lay down."))
		if(owner.has_gravity())
			playsound(owner, "bodyfall", 50, TRUE)

GAME_VERB_PROC(/mob/living/carbon/human, veil_taur_toggle_cropping, "Override Taur Cropping Settings", "Taur")
	var/mob/living/carbon/human/owner = src
	if(!istype(owner))
		return

	var/obj/item/organ/taur_body/organ = owner.get_organ_by_type(/obj/item/organ/taur_body)
	if(isnull(organ))
		veil_untaur_verbs(owner)
		return

	if(HAS_TRAIT(owner, TRAIT_TAUR_IGNORING_CROPPING))
		REMOVE_TRAIT(owner, TRAIT_TAUR_IGNORING_CROPPING, TRAIT_SOURCE_TAURCROP)
	else
		ADD_TRAIT(owner, TRAIT_TAUR_IGNORING_CROPPING, TRAIT_SOURCE_TAURCROP)

	var/setting_string = (HAS_TRAIT(owner, TRAIT_TAUR_IGNORING_CROPPING) ? "now ignoring cropping" : "no longer ignoring cropping")
	balloon_alert(owner, setting_string)

	owner.update_clothing(ITEM_SLOT_OCLOTHING|ITEM_SLOT_ICLOTHING)
