/obj/item/organ/cyberimp/chest/veilbreak_spinal_tap
	name = "spinal CNS tap"
	desc = "A low-profile neural shunt wired into the spine. It anchors other augment hardware but leaves you twitchy when ion storms hit."
	icon_state = "chest_implant"
	aug_overlay = null
	slot = ORGAN_SLOT_SPINE

/obj/item/organ/cyberimp/chest/veilbreak_spinal_tap/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	owner.adjust_jitter(20 SECONDS / severity)
	owner.adjust_organ_loss(ORGAN_SLOT_BRAIN, 8 / severity)
	to_chat(owner, span_warning("Your spine lights up with static!"))

/obj/item/organ/cyberimp/chest/veilbreak_pneumatic
	name = "pneumatic reservoir"
	desc = "A pressurized chest reservoir that bleeds kinetic cushioning into your frame. EMPs can vent it painfully."
	icon_state = "chest_implant"
	aug_overlay = null
	slot = ORGAN_SLOT_STOMACH_AID

/obj/item/organ/cyberimp/chest/veilbreak_pneumatic/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	owner.adjust_brute_loss(15 / severity)
	owner.adjust_stamina_loss(40 / severity)
	to_chat(owner, span_warning("Your pneumatic reservoir spasms!"))

/obj/item/organ/cyberimp/chest/veilbreak_pneumatic/on_life(seconds_per_tick, times_fired)
	..()
	if(!owner || (organ_flags & ORGAN_FAILING))
		return
	owner.adjust_stamina_loss(-1.2 * seconds_per_tick, updating_stamina = TRUE, forced = TRUE)

/obj/item/organ/cyberimp/chest/veilbreak_titanium_endo
	name = "titanium endoskeleton lattice"
	desc = "Subdermal struts and woven alloy bands reinforce your skeleton against trauma and give tackles extra bite."
	icon_state = "chest_implant"
	aug_overlay = null
	slot = ORGAN_SLOT_MONSTER_CORE

/obj/item/organ/cyberimp/chest/veilbreak_titanium_endo/on_mob_insert(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	add_organ_trait(TRAIT_STURDY_FRAME)
	if(ishuman(organ_owner))
		var/mob/living/carbon/human/human_owner = organ_owner
		for(var/obj/item/bodypart/limb as anything in human_owner.bodyparts)
			limb.wound_resistance += 12

/obj/item/organ/cyberimp/chest/veilbreak_titanium_endo/on_mob_remove(mob/living/carbon/organ_owner, special, movement_flags)
	remove_organ_trait(TRAIT_STURDY_FRAME)
	if(ishuman(organ_owner))
		var/mob/living/carbon/human/human_owner = organ_owner
		for(var/obj/item/bodypart/limb as anything in human_owner.bodyparts)
			limb.wound_resistance -= 12
	return ..()

/datum/power/spinal_tap/add(mob/living/carbon/human/target)
	var/obj/item/organ/old = target.get_organ_slot(ORGAN_SLOT_SPINE)
	if(old)
		qdel(old)
	var/obj/item/organ/cyberimp/chest/veilbreak_spinal_tap/implant = new()
	implant.Insert(target, special = TRUE)

/datum/power/pneumatic/add(mob/living/carbon/human/target)
	var/obj/item/organ/old = target.get_organ_slot(ORGAN_SLOT_STOMACH_AID)
	if(old)
		qdel(old)
	var/obj/item/organ/cyberimp/chest/veilbreak_pneumatic/implant = new()
	implant.Insert(target, special = TRUE)

/datum/power/titanium/add(mob/living/carbon/human/target)
	var/obj/item/organ/old = target.get_organ_slot(ORGAN_SLOT_MONSTER_CORE)
	if(old)
		qdel(old)
	var/obj/item/organ/cyberimp/chest/veilbreak_titanium_endo/implant = new()
	implant.Insert(target, special = TRUE)
