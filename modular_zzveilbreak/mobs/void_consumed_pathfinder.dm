// Ranged skirmisher configuration for the Pathfinder type.

/datum/ai_controller/basic_controller/simple/void_ranged_pathfinder
	behavior_tree_json = "modular_zzveilbreak/mobs/void_ranged.bt.json"
	ai_movement = /datum/ai_movement/basic_avoidance
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/void_aggressive,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_AGGRO_RANGE = 10,
		BB_VOID_SUMMON_COOLDOWN = 0,
		BB_RANGED_SKIRMISH_MIN_DISTANCE = 3,
		BB_RANGED_SKIRMISH_MAX_DISTANCE = 7
	)

/mob/living/basic/void_creature/consumed_pathfinder
	name = "Consumed Pathfinder"
	desc = "A pathfinder just like you, consumed by the void. It moves with unnatural purpose."
	icon = 'modular_zzveilbreak/icons/mob/mobs.dmi'
	icon_state = "consumed"
	icon_living = "consumed"
	ai_controller = /datum/ai_controller/basic_controller/simple/void_ranged_pathfinder
	maxHealth = 80
	health = 80
	speed = 1
	faction = list(FACTION_VOID)
	melee_damage_lower = 0
	melee_damage_upper = 0
	armor = list(
		BLUNT = -20, PUNCTURE = -20, SLASH = -20, LASER = -10, ENERGY = 0,
		BOMB = 0, BIO = 50, FIRE = 30, ACID = 0, MAGIC = 30, RADIATION = 80,
	)

/mob/living/basic/void_creature/consumed_pathfinder/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ranged_attacks, projectile_type = /obj/projectile/magic/voidbolt, projectile_sound = 'sound/effects/magic/magic_missile.ogg', cooldown_time = 2 SECONDS)

/mob/living/basic/void_creature/consumed_pathfinder/do_void_creature_loot_drop()
	var/loot_type = pick_loot_from_table(consumed_pathfinder_drops)
	if(loot_type)
		new loot_type(drop_location())
