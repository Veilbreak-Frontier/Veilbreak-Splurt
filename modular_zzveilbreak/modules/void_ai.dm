// --- Refactored Void AI Controllers with BT Editor Links ---

/datum/ai_controller/basic_controller/void_melee
	// Tells the BT Editor extension and engine which tree template to load
	behavior_tree_json = "build/behavior_trees/void_melee.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/void_aggressive,
		BB_AGGRO_RANGE = 10
	)

/datum/ai_controller/basic_controller/void_ranged_pathfinder
	behavior_tree_json = "build/behavior_trees/void_ranged.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/void_aggressive,
		BB_VOID_SUMMON_COOLDOWN = 0,
		BB_RANGED_SKIRMISH_MIN_DISTANCE = 1,
		BB_RANGED_SKIRMISH_MAX_DISTANCE = 5
	)

/datum/ai_controller/basic_controller/void_ranged_healer
	behavior_tree_json = "build/behavior_trees/void_healer.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/void_aggressive,
		BB_VOID_HEAL_COOLDOWN = 0,
		BB_AGGRO_RANGE = 10,
		BB_RANGED_SKIRMISH_MIN_DISTANCE = 1,
		BB_RANGED_SKIRMISH_MAX_DISTANCE = 6
	)

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
