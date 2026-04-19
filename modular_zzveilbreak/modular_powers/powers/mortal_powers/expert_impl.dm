#define VEILBREAK_SURGERY_SPEED_MULT 0.78
#define VEILBREAK_ENGINEERING_ACTIONSPEED -0.22
#define VEILBREAK_SERVICE_ACTIONSPEED -0.12
#define VEILBREAK_SEASONED_COOK_ACTIONSPEED -0.1
#define VEILBREAK_GREEN_THUMB_ACTIONSPEED -0.08
#define VEILBREAK_MASTER_CHEF_ACTIONSPEED -0.12

/datum/actionspeed_modifier/veilbreak_engineering
	variable = TRUE
	id = "veilbreak_engineering"
	multiplicative_slowdown = VEILBREAK_ENGINEERING_ACTIONSPEED

/datum/actionspeed_modifier/veilbreak_service
	variable = TRUE
	id = "veilbreak_service"
	multiplicative_slowdown = VEILBREAK_SERVICE_ACTIONSPEED

/datum/actionspeed_modifier/veilbreak_seasoned_chef
	variable = TRUE
	id = "veilbreak_seasoned_chef"
	multiplicative_slowdown = VEILBREAK_SEASONED_COOK_ACTIONSPEED

/datum/actionspeed_modifier/veilbreak_green_thumb
	variable = TRUE
	id = "veilbreak_green_thumb"
	multiplicative_slowdown = VEILBREAK_GREEN_THUMB_ACTIONSPEED

/datum/actionspeed_modifier/veilbreak_master_chef
	variable = TRUE
	id = "veilbreak_master_chef"
	multiplicative_slowdown = VEILBREAK_MASTER_CHEF_ACTIONSPEED

/datum/element/veilbreak_expert_medical

/datum/element/veilbreak_expert_medical/Attach(datum/target)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_LIVING_INITIATE_SURGERY_STEP, PROC_REF(on_surgery_step))

/datum/element/veilbreak_expert_medical/Detach(datum/source, ...)
	UnregisterSignal(source, COMSIG_LIVING_INITIATE_SURGERY_STEP)
	return ..()

/datum/element/veilbreak_expert_medical/proc/on_surgery_step(mob/living/carbon/_source, mob/living/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, datum/surgery_step/step, list/modifiers)
	SIGNAL_HANDLER
	if(!HAS_TRAIT(user, TRAIT_POWER_MEDICAL))
		return
	modifiers[SPEED_MOD_INDEX] *= VEILBREAK_SURGERY_SPEED_MULT

/datum/power/medical/add(mob/living/carbon/human/target)
	target.AddElement(/datum/element/veilbreak_expert_medical)

/datum/power/engineering/add(mob/living/carbon/human/target)
	target.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/veilbreak_engineering, multiplicative_slowdown = VEILBREAK_ENGINEERING_ACTIONSPEED)

/datum/power/service/add(mob/living/carbon/human/target)
	target.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/veilbreak_service, multiplicative_slowdown = VEILBREAK_SERVICE_ACTIONSPEED)

/datum/power/seasoned_chef/add(mob/living/carbon/human/target)
	target.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/veilbreak_seasoned_chef, multiplicative_slowdown = VEILBREAK_SEASONED_COOK_ACTIONSPEED)

/datum/power/green_thumb/add(mob/living/carbon/human/target)
	target.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/veilbreak_green_thumb, multiplicative_slowdown = VEILBREAK_GREEN_THUMB_ACTIONSPEED)

/datum/power/master_chef/add(mob/living/carbon/human/target)
	target.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/veilbreak_master_chef, multiplicative_slowdown = VEILBREAK_MASTER_CHEF_ACTIONSPEED)
