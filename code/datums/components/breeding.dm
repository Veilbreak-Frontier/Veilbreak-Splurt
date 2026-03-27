/datum/component/breed
	var/list/can_breed_with
	var/list/baby_paths
	var/breed_timer
	var/breed_key = BB_BREED_READY
	var/ready_to_breed = TRUE
	var/datum/callback/post_birth

/datum/component/breed/Initialize(list/can_breed_with = list(), breed_timer = 40 SECONDS, list/baby_paths = list(), post_birth)
	if(!isliving(parent) || ishuman(parent))
		return COMPONENT_INCOMPATIBLE

	if(!length(baby_paths))
		stack_trace("Attempted to add a breeding component to [parent.type] with empty baby_paths.")
		return COMPONENT_INCOMPATIBLE

	src.can_breed_with = can_breed_with
	src.breed_timer = breed_timer
	src.baby_paths = baby_paths
	src.post_birth = post_birth

	ADD_TRAIT(parent, TRAIT_SUBTREE_REQUIRED_OPERATIONAL_DATUM, type)

/datum/component/breed/RegisterWithParent()
	RegisterSignal(parent, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(breed_with_partner))
	ADD_TRAIT(parent, TRAIT_MOB_BREEDER, REF(src))
	var/mob/living/parent_mob = parent
	parent_mob.ai_controller?.set_blackboard_key(breed_key, TRUE)

/datum/component/breed/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_HOSTILE_PRE_ATTACKINGTARGET)
	REMOVE_TRAIT(parent, TRAIT_MOB_BREEDER, REF(src))
	post_birth = null

/datum/component/breed/proc/breed_with_partner(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	if(source.combat_mode || !ismob(target) || source.client || target.client)
		return

	if(!is_type_in_typecache(target, can_breed_with))
		return

	if(!HAS_TRAIT(target, TRAIT_MOB_BREEDER) || target.gender == source.gender)
		return

	if(!ready_to_breed)
		return COMPONENT_HOSTILE_NO_ATTACK

	var/chosen_baby_path = pick_weight(baby_paths)

	if(!chosen_baby_path && length(baby_paths))
		chosen_baby_path = baby_paths[1]

	if(!chosen_baby_path)
		stack_trace("Breeding component on [source.type] failed to resolve a baby path.")
		return COMPONENT_HOSTILE_NO_ATTACK

	var/turf/delivery_destination = get_turf(source)
	var/atom/baby = new chosen_baby_path(delivery_destination)
	new /obj/effect/temp_visual/heart(delivery_destination)

	toggle_status(source)
	addtimer(CALLBACK(src, PROC_REF(toggle_status), source), breed_timer)

	post_birth?.Invoke(baby, target)
	return COMPONENT_HOSTILE_NO_ATTACK

/datum/component/breed/proc/toggle_status(mob/living/source)
	ready_to_breed = !ready_to_breed
	source.ai_controller?.set_blackboard_key(breed_key, ready_to_breed)
