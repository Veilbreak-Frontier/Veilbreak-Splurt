// Artificer-like logic targeting friendly void assets with healing components.

/datum/ai_controller/basic_controller/simple/void_ranged_healer
	behavior_tree_json = "modular_zzveilbreak/mobs/void_healer.bt.json"
	ai_movement = /datum/ai_movement/basic_avoidance
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/void_aggressive,
		BB_TARGETING_STRATEGY_FRIEND = /datum/targeting_strategy/basic/void_aggressive/healer,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_TARGET_WOUNDED_ONLY = TRUE,
		BB_VOID_HEAL_COOLDOWN = 0,
		BB_AGGRO_RANGE = 10,
		BB_RANGED_SKIRMISH_MIN_DISTANCE = 3,
		BB_RANGED_SKIRMISH_MAX_DISTANCE = 7
	)

/datum/targeting_strategy/basic/void_aggressive/healer
	invert_faction_check = TRUE
	target_wounded_key = BB_TARGET_WOUNDED_ONLY

/datum/targeting_strategy/basic/void_aggressive/healer/is_valid_target(mob/living/living_mob, atom/the_target, vision_range, datum/ai_controller/controller = null)
	if(the_target == living_mob || !istype(the_target, /mob/living/basic/void_creature))
		return FALSE
	var/mob/living/basic/void_creature/void_ally = the_target
	if(!void_ally.get_brute_loss() && !void_ally.get_fire_loss())
		return FALSE
	return ..()

/mob/living/basic/void_creature/void_healer
	name = "Void Healer"
	desc = "A benevolent void entity that mends its allies."
	icon = 'modular_zzveilbreak/icons/mob/mobs.dmi'
	icon_state = "void_healer"
	icon_living = "void_healer"
	icon_dead = "void_healer_dead"
	ai_controller = /datum/ai_controller/basic_controller/simple/void_ranged_healer
	maxHealth = 40
	health = 40
	speed = 0.7
	melee_damage_lower = 0
	melee_damage_upper = 0
	armor = list(
		BLUNT = -20, PUNCTURE = -20, SLASH = -20, LASER = -10, ENERGY = 0,
		BOMB = 0, BIO = 50, FIRE = 30, ACID = 0, MAGIC = 30, RADIATION = 80,
	)

/mob/living/basic/void_creature/void_healer/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ranged_attacks, projectile_type = /obj/projectile/magic/voidbolt, projectile_sound = 'sound/effects/magic/magic_missile.ogg', cooldown_time = 2.5 SECONDS)
	AddComponent(		/datum/component/healing_touch,		heal_brute = 5,		heal_burn = 5,		heal_time = 0,		valid_targets_typecache = typecacheof(list(/mob/living/basic/void_creature)),		valid_biotypes = MOB_MINING | MOB_SPECIAL,		self_targeting = HEALING_TOUCH_NOT_SELF,		action_text = "%SOURCE% begins reweaving %TARGET%'s structural essence.",		complete_text = "%TARGET%'s essence is restored.",		show_health = TRUE,		heal_color = "#8A2BE2",	)

/mob/living/basic/void_creature/void_healer/do_void_creature_loot_drop()
	var/loot_type = pick_loot_from_table(void_healer_table)
	if(loot_type)
		new loot_type(drop_location())
