// --- Refactored Void AI Controllers with Movement & Correct Inheritance ---

/datum/ai_controller/basic_controller/simple/hostile/void_melee
	behavior_tree_json = "modular_zzveilbreak/modules/void_melee.json"
	ai_movement = /datum/ai_movement/basic/pathfinding // Hareket motoru bağlandı
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/void_aggressive,
		BB_AGGRO_RANGE = 10
	)

/datum/ai_controller/basic_controller/simple/hostile/void_ranged_pathfinder
	behavior_tree_json = "modular_zzveilbreak/modules/void_ranged.json"
	ai_movement = /datum/ai_movement/basic/pathfinding
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/void_aggressive,
		BB_VOID_SUMMON_COOLDOWN = 0,
		BB_RANGED_SKIRMISH_MIN_DISTANCE = 1,
		BB_RANGED_SKIRMISH_MAX_DISTANCE = 5
	)

/datum/ai_controller/basic_controller/simple/hostile/void_ranged_healer
	behavior_tree_json = "modular_zzveilbreak/modules/void_healer.json"
	ai_movement = /datum/ai_movement/basic/pathfinding
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/void_aggressive,
		BB_VOID_HEAL_COOLDOWN = 0,
		BB_AGGRO_RANGE = 10,
		BB_RANGED_SKIRMISH_MIN_DISTANCE = 1,
		BB_RANGED_SKIRMISH_MAX_DISTANCE = 6
	)

// --- MOB INITIALIZATIONS ---

/mob/living/basic/void_creature
	ai_controller = /datum/ai_controller/basic_controller/simple/hostile/void_melee

/mob/living/basic/void_creature/voidling
	ai_controller = /datum/ai_controller/basic_controller/simple/hostile/void_melee

/mob/living/basic/void_creature/voidbug
	ai_controller = /datum/ai_controller/basic_controller/simple/hostile/void_melee

/mob/living/basic/void_creature/consumed_pathfinder
	ai_controller = /datum/ai_controller/basic_controller/simple/hostile/void_ranged_pathfinder

/mob/living/basic/void_creature/void_healer
	ai_controller = /datum/ai_controller/basic_controller/simple/hostile/void_ranged_healer
