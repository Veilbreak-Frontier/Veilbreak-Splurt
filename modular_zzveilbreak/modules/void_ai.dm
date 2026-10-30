// --- Void AI Controllers Configuration ---

/**

* Void Melee Basic AI Controller
* Standard combat logic similar to Juggernauts/Wraiths.
*/
/datum/ai_controller/basic_controller/simple/hostile/void_melee
behavior_tree_json = "modular_zzveilbreak/modules/void_melee.json"
ai_movement = /datum/ai_movement/basic_avoidance
blackboard = list(
BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/void_aggressive,
BB_TARGET_MINIMUM_STAT = HARD_CRIT,
BB_AGGRO_RANGE = 10,
)

/**

* Void Ranged Pathfinder AI Controller
* Handles distance maintenance and skirmish ranges.
*/
/datum/ai_controller/basic_controller/simple/hostile/void_ranged_pathfinder
behavior_tree_json = "modular_zzveilbreak/modules/void_ranged.json"
ai_movement = /datum/ai_movement/basic_avoidance
blackboard = list(
BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/void_aggressive,
BB_TARGET_MINIMUM_STAT = HARD_CRIT,
BB_VOID_SUMMON_COOLDOWN = 0,
BB_RANGED_SKIRMISH_MIN_DISTANCE = 1,
BB_RANGED_SKIRMISH_MAX_DISTANCE = 5,
)

/**

* Void Healer AI Controller
* Mimics Cult Artificer parameters to focus on friendly wounded units first.
*/
/datum/ai_controller/basic_controller/simple/hostile/void_ranged_healer
behavior_tree_json = "modular_zzveilbreak/modules/void_healer.json"
ai_movement = /datum/ai_movement/basic_avoidance
blackboard = list(
BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/void_aggressive/healer,
BB_FLEE_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
BB_TARGET_WOUNDED_ONLY = TRUE,
BB_VOID_HEAL_COOLDOWN = 0,
BB_AGGRO_RANGE = 10,
BB_RANGED_SKIRMISH_MIN_DISTANCE = 1,
BB_RANGED_SKIRMISH_MAX_DISTANCE = 6,
)

// --- Mob Initializations ---

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
