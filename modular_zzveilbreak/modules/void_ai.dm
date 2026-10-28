// --- Refactored Void AI Controllers with BT Editor Links ---

/datum/ai_controller/basic_controller/void_melee
	// Tells the BT Editor extension and engine which tree template to load
	behavior_tree_json = "build/behavior_trees/void_melee.json"

/datum/ai_controller/basic_controller/void_melee/Possess(mob/living/new_pawn, list/arguments)
	. = ..()
	set_blackboard_key(BB_TARGETING_STRATEGY, /datum/targeting_strategy/basic/void_aggressive)
	set_blackboard_key(BB_AGGRO_RANGE, 10)


/datum/ai_controller/basic_controller/void_ranged_pathfinder
	behavior_tree_json = "build/behavior_trees/void_ranged.json"

/datum/ai_controller/basic_controller/void_ranged_pathfinder/Possess(mob/living/new_pawn, list/arguments)
	. = ..()
	set_blackboard_key(BB_TARGETING_STRATEGY, /datum/targeting_strategy/basic/void_aggressive)
	set_blackboard_key(BB_VOID_SUMMON_COOLDOWN, 0)
	// Keeps skirmish active but prevents endless retreat loops
	set_blackboard_key(BB_RANGED_SKIRMISH_MIN_DISTANCE, 1)
	set_blackboard_key(BB_RANGED_SKIRMISH_MAX_DISTANCE, 5)


/datum/ai_controller/basic_controller/void_ranged_healer
	behavior_tree_json = "build/behavior_trees/void_healer.json"

/datum/ai_controller/basic_controller/void_ranged_healer/Possess(mob/living/new_pawn, list/arguments)
	. = ..()
	set_blackboard_key(BB_TARGETING_STRATEGY, /datum/targeting_strategy/basic/void_aggressive)
	set_blackboard_key(BB_VOID_HEAL_COOLDOWN, 0)
	set_blackboard_key(BB_AGGRO_RANGE, 10)
	set_blackboard_key(BB_RANGED_SKIRMISH_MIN_DISTANCE, 1)
	set_blackboard_key(BB_RANGED_SKIRMISH_MAX_DISTANCE, 6)


// --- MOB INITIALIZATIONS ---

/mob/living/basic/void_creature
	ai_controller = /datum/ai_controller/basic_controller/void_melee

/mob/living/basic/void_creature/voidling
	ai_controller = /datum/ai_controller/basic_controller/void_melee

/mob/living/basic/void_creature/voidbug
	ai_controller = /datum/ai_controller/basic_controller/void_melee

/mob/living/basic/void_creature/consumed_pathfinder
	ai_controller = /datum/ai_controller/basic_controller/void_ranged_pathfinder

/mob/living/basic/void_creature/void_healer
	ai_controller = /datum/ai_controller/basic_controller/void_ranged_healer
