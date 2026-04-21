#define BB_VOID_SUMMON_COOLDOWN "void_summon_cooldown"
#define BB_VOID_HEAL_COOLDOWN "void_heal_cooldown"
#define BB_HEAL_TARGET "heal_target"
#define BB_VOIDBUG_LAST_PACK_CALL "voidbug_last_pack_call"
/// Chance (0-100) for trash void mobs to run their weighted loot table on death.
#define VEILBREAK_VOID_CREATURE_LOOT_CHANCE 10

/mob/living/basic/void_creature
	name = "Void Creature"
	desc = "A creature from the void."
	faction = list(FACTION_VOID)
	gender = NEUTER
	speak_emote = list("hums")
	response_help_continuous = "touches"
	response_help_simple = "touch"
	response_disarm_continuous = "pushes"
	response_disarm_simple = "push"
	response_harm_continuous = "hits"
	response_harm_simple = "hit"
	maxHealth = 50
	health = 50
	melee_damage_lower = 10
	melee_damage_upper = 15
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	attack_sound = 'modular_zzveilbreak/sound/weapons/voidling_attack.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	status_flags = CANPUSH
	obj_damage = 30
	movement_type = GROUND
	basic_mob_flags = DEL_ON_DEATH
	ai_controller = /datum/ai_controller/basic_controller/void

/mob/living/basic/void_creature/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)
	AddElement(/datum/element/ai_retaliate)
	faction |= FACTION_HOSTILE
	apply_veilbreak_void_creature_stat_scaling()

/// Applies GLOB veilbreak_void_creature_*_scale to this mob (void trash only; megafauna use another type path).
/mob/living/basic/void_creature/proc/apply_veilbreak_void_creature_stat_scaling()
	var/h_mult = GLOB.veilbreak_void_creature_health_scale
	var/d_mult = GLOB.veilbreak_void_creature_damage_scale
	if(h_mult == 1 && d_mult == 1)
		return
	if(h_mult != 1)
		maxHealth = max(1, ROUND_UP(maxHealth * h_mult))
		health = maxHealth
	if(d_mult != 1)
		melee_damage_lower = max(0, ROUND_UP(melee_damage_lower * d_mult))
		melee_damage_upper = max(melee_damage_lower, ROUND_UP(melee_damage_upper * d_mult))
		obj_damage = max(0, ROUND_UP(obj_damage * d_mult))

/mob/living/basic/void_creature/death(gibbed)
	if(!gibbed)
		drop_loot()
	. = ..()
	visible_message(span_danger("[src] collapses into void dust!"))
	dust(just_ash = FALSE, drop_items = FALSE)
	return TRUE

/mob/living/basic/void_creature/proc/drop_loot()
	if(!prob(VEILBREAK_VOID_CREATURE_LOOT_CHANCE))
		return
	do_void_creature_loot_drop()

/mob/living/basic/void_creature/proc/do_void_creature_loot_drop()
	return

/mob/living/basic/void_creature/voidling
	name = "Voidling"
	desc = "You struggle to comprehend the details of this creature, it keeps shifting and changing constantly."
	icon = 'modular_zzveilbreak/icons/mob/mobs.dmi'
	icon_state = "voidling"
	icon_living = "voidling"
	icon_dead = "voidling_dead"
	maxHealth = 60
	health = 60
	melee_damage_lower = 8
	melee_damage_upper = 12
	speed = 0.8
	armor = list(
		BLUNT = 25, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0,
		BOMB = 0, BIO = 0, FIRE = 0, ACID = 0, MAGIC = 0, RADIATION = 0,
	)
	ai_controller = /datum/ai_controller/basic_controller/void/voidling

/mob/living/basic/void_creature/voidling/do_void_creature_loot_drop()
	var/loot_type = pick_loot_from_table(voidling_loot_table)
	if(loot_type)
		new loot_type(drop_location())

/mob/living/basic/void_creature/voidling/Move()
	. = ..()
	if(.)
		flick("voidling_2", src)

/mob/living/basic/void_creature/consumed_pathfinder
	name = "Consumed Pathfinder"
	desc = "A pathfinder just like you, consumed by the void. It moves with unnatural purpose."
	icon = 'modular_zzveilbreak/icons/mob/mobs.dmi'
	icon_state = "consumed"
	icon_living = "consumed"
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
	ai_controller = /datum/ai_controller/basic_controller/void_pathfinder

/mob/living/basic/void_creature/consumed_pathfinder/Initialize(mapload)
	. = ..()
	AddComponent(\
		/datum/component/ranged_attacks,\
		projectile_type = /obj/projectile/magic/voidbolt,\
		projectile_sound = 'sound/effects/magic/magic_missile.ogg',\
		cooldown_time = 2 SECONDS,\
	)

/mob/living/basic/void_creature/consumed_pathfinder/do_void_creature_loot_drop()
	var/loot_type = pick_loot_from_table(consumed_pathfinder_drops)
	if(loot_type)
		new loot_type(drop_location())

/mob/living/basic/void_creature/voidbug
	name = "Voidbug"
	desc = "A resilient bug-like creature from the void, its chitinous plates deflect attacks with ease."
	icon = 'modular_zzveilbreak/icons/mob/mobs.dmi'
	icon_state = "void_bug"
	icon_living = "void_bug"
	icon_dead = "void_bug_dead"
	maxHealth = 140
	health = 140
	melee_damage_lower = 5
	melee_damage_upper = 7
	speed = 1.3
	armor = list(
		BLUNT = 30, PUNCTURE = 30, SLASH = 30, LASER = -10, ENERGY = 0,
		BOMB = 0, BIO = 50, FIRE = -50, ACID = 0, MAGIC = 30, RADIATION = 80,
	)
	ai_controller = /datum/ai_controller/basic_controller/void/voidbug
	var/block_chance = 40
	var/last_alert_time = 0
	var/alert_cooldown = 30 SECONDS

/mob/living/basic/void_creature/voidbug/do_void_creature_loot_drop()
	var/loot_type = pick_loot_from_table(voidbug_loot_table)
	if(loot_type)
		new loot_type(drop_location())

/mob/living/basic/void_creature/voidbug/bullet_act(obj/projectile/P, def_zone, piercing_hit)
	if(prob(block_chance) && !piercing_hit)
		visible_message(span_warning("[src]'s chitin deflects the projectile!"))
		playsound(src, 'sound/effects/magic/cosmic_energy.ogg', 50, TRUE)
		return BULLET_ACT_BLOCK
	return ..()

/mob/living/basic/void_creature/voidbug/proc/alert_allies(mob/living/target)
	if(world.time < last_alert_time + alert_cooldown || stat == DEAD)
		return
	if(!target || target.stat == DEAD || compare_factions(src, target))
		return
	last_alert_time = world.time
	visible_message(span_danger("[src] lets out a resonant, vibrating hum, alerting nearby void creatures!"))
	playsound(src, 'sound/effects/hallucinations/growl1.ogg', 70, TRUE)
	new /obj/effect/temp_visual/void_tear(loc)
	for(var/mob/living/basic/void_creature/V in view(7, src))
		if(V == src || V.stat == DEAD || !V.ai_controller)
			continue
		if(!can_see(V))
			continue
		V.ai_controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, target)
		new /obj/effect/temp_visual/void_alert(V.loc)

/mob/living/basic/void_creature/void_healer
	name = "Void Healer"
	desc = "A benevolent void entity that mends its allies."
	icon = 'modular_zzveilbreak/icons/mob/mobs.dmi'
	icon_state = "void_healer"
	icon_living = "void_healer"
	icon_dead = "void_healer_dead"
	maxHealth = 40
	health = 40
	speed = 0.7
	melee_damage_lower = 0
	melee_damage_upper = 0
	armor = list(
		BLUNT = -20, PUNCTURE = -20, SLASH = -20, LASER = -10, ENERGY = 0,
		BOMB = 0, BIO = 50, FIRE = 30, ACID = 0, MAGIC = 30, RADIATION = 80,
	)
	ai_controller = /datum/ai_controller/basic_controller/void_healer

/mob/living/basic/void_creature/void_healer/Initialize(mapload)
	. = ..()
	AddComponent(\
		/datum/component/ranged_attacks,\
		projectile_type = /obj/projectile/magic/voidbolt,\
		projectile_sound = 'sound/effects/magic/magic_missile.ogg',\
		cooldown_time = 2.5 SECONDS,\
	)

/mob/living/basic/void_creature/void_healer/do_void_creature_loot_drop()
	var/loot_type = pick_loot_from_table(void_healer_table)
	if(loot_type)
		new loot_type(drop_location())

/obj/projectile/magic/voidbolt
	name = "void bolt"
	icon = 'modular_zzveilbreak/icons/item_icons/voidring.dmi'
	icon_state = "voidbolt"
	damage = 5
	damage_type = BURN
	range = 14
	speed = 2.5
	hitsound = 'sound/effects/magic/magic_missile.ogg'

/obj/projectile/magic/voidbolt/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(isliving(target) && blocked < 100)
		var/mob/living/L = target
		L.adjust_stutter(4 SECONDS)

// --- AI CONTROLLERS ---

/datum/ai_controller/basic_controller/void
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/void_aggressive,
		BB_AGGRO_RANGE = 10,
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/target_retaliate/check_faction,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree
	)

/datum/ai_controller/basic_controller/void/voidling
	// Same as base void: find target, melee, no flee (tanky attacker)

/datum/ai_controller/basic_controller/void/voidbug
	// Voidbug tanks and never runs: pack call + find target + melee, no flee. Aggressive on sight.
	planning_subtrees = list(
		/datum/ai_planning_subtree/voidbug_pack_call,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/target_retaliate/check_faction,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_controller/basic_controller/void_pathfinder
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/void_aggressive,
		BB_VOID_SUMMON_COOLDOWN = 0,
		BB_RANGED_SKIRMISH_MIN_DISTANCE = 3,
		BB_RANGED_SKIRMISH_MAX_DISTANCE = 8
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/maintain_distance,
		/datum/ai_planning_subtree/void_pathfinder_summon,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/void_creature
	)

/datum/ai_controller/basic_controller/void_healer
	blackboard = list(
		BB_VOID_HEAL_COOLDOWN = 0,
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/void_aggressive,
		BB_AGGRO_RANGE = 10,
		BB_RANGED_SKIRMISH_MIN_DISTANCE = 3,
		BB_RANGED_SKIRMISH_MAX_DISTANCE = 8,
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/void_healer_find_and_heal,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/target_retaliate/check_faction,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/maintain_distance,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/void_creature
	)

/// Longer line-of-sight window than default basic_ranged_attack (3) so void bolts match skirmish range.
/datum/ai_behavior/basic_ranged_attack/void_creature
	required_distance = 9
	chase_range = 12

/datum/ai_planning_subtree/basic_ranged_attack_subtree/void_creature
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/void_creature

// --- SUBTREES ---

/// Voidbug rally: when we have a target, alert nearby void creatures so they attack it too (unique "spell").
/datum/ai_planning_subtree/voidbug_pack_call
	var/pack_call_cooldown = 15 SECONDS

/datum/ai_planning_subtree/voidbug_pack_call/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!controller.blackboard_key_exists(BB_BASIC_MOB_CURRENT_TARGET))
		return
	var/last_pack_call = controller.blackboard[BB_VOIDBUG_LAST_PACK_CALL] || 0
	if(world.time < last_pack_call + pack_call_cooldown)
		return
	controller.queue_behavior(/datum/ai_behavior/voidbug_call_pack, BB_BASIC_MOB_CURRENT_TARGET)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/voidbug_call_pack
	action_cooldown = 15 SECONDS

/datum/ai_behavior/voidbug_call_pack/setup(datum/ai_controller/controller, target_key)
	var/atom/target = controller.blackboard[target_key]
	if(!target)
		return FALSE
	return ..()

/datum/ai_behavior/voidbug_call_pack/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/mob/living/living_pawn = controller.pawn
	var/atom/target = controller.blackboard[target_key]
	if(!target)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/turf/source_turf = get_turf(living_pawn)
	var/pack_called = FALSE
	var/pawn_angle = dir2angle(living_pawn.dir)

	for(var/mob/living/basic/void_creature/void_mob in view(7, living_pawn))
		if(void_mob == living_pawn || void_mob.stat == DEAD || !void_mob.ai_controller)
			continue

		var/deg_to_ally = get_angle(living_pawn, void_mob)
		var/diff = deg_to_ally - pawn_angle
		while(diff <= -180) diff += 360
		while(diff > 180) diff -= 360

		if(abs(diff) > 45)
			continue

		var/turf/ally_turf = get_turf(void_mob)
		var/blocked = FALSE

		for(var/turf/check_turf in get_line(source_turf, ally_turf))
			if(check_turf == source_turf || check_turf == ally_turf)
				continue

			if(check_turf.opacity)
				blocked = TRUE
				break

			for(var/atom/movable/AM in check_turf)
				if(AM.density && AM != living_pawn && AM != void_mob)
					blocked = TRUE
					break

			if(blocked)
				break

		if(blocked)
			continue

		if(void_mob.faction.Find(FACTION_VOID) && !void_mob.ai_controller.blackboard_key_exists(BB_BASIC_MOB_CURRENT_TARGET))
			void_mob.ai_controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, target)
			pack_called = TRUE

	if(pack_called)
		living_pawn.visible_message(span_warning("[living_pawn] lets out a chittering call, rallying nearby void creatures!"))
		playsound(living_pawn, 'sound/effects/hallucinations/growl1.ogg', 50, TRUE)

	controller.blackboard[BB_VOIDBUG_LAST_PACK_CALL] = world.time
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_planning_subtree/void_pathfinder_summon/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(world.time <= controller.blackboard[BB_VOID_SUMMON_COOLDOWN])
		return
	var/mob/living/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(!target) return
	var/allies = 0
	for(var/mob/living/basic/void_creature/voidling/V in view(7, controller.pawn))
		allies++
	if(allies >= 3) return
	controller.queue_behavior(/datum/ai_behavior/void_summon, BB_BASIC_MOB_CURRENT_TARGET)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_planning_subtree/void_healer_find_and_heal/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(world.time <= controller.blackboard[BB_VOID_HEAL_COOLDOWN])
		return
	var/mob/living/owner = controller.pawn
	var/mob/living/best_target
	var/worst_health_ratio = 1
	// Find wounded void-faction ally in heal range (4 tiles) - no movement required
	for(var/mob/living/L in view(4, owner))
		if(L == owner || L.stat == DEAD || !L.faction)
			continue
		if(!(FACTION_VOID in L.faction))
			continue
		if(L.health >= L.maxHealth)
			continue
		var/hp_ratio = L.health / L.maxHealth
		if(hp_ratio < worst_health_ratio)
			worst_health_ratio = hp_ratio
			best_target = L
	if(best_target)
		controller.set_blackboard_key(BB_HEAL_TARGET, best_target)
		controller.queue_behavior(/datum/ai_behavior/void_heal, BB_HEAL_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING

// --- BEHAVIORS ---

/datum/ai_behavior/void_summon
	action_cooldown = 25 SECONDS
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/void_summon/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/mob/living/owner = controller.pawn
	var/mob/living/target = controller.blackboard[target_key]
	if(!target) return AI_BEHAVIOR_FAILED
	owner.visible_message(span_warning("[owner] begins to channel the void..."))
	if(!do_after(owner, 30, target = target)) return AI_BEHAVIOR_FAILED
	var/summon_count = rand(1, 2)
	for(var/i in 1 to summon_count)
		var/mob/living/basic/void_creature/voidling/V = new(owner.loc)
		V.faction = owner.faction.Copy()
		if(V.ai_controller) V.ai_controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, target)
	controller.set_blackboard_key(BB_VOID_SUMMON_COOLDOWN, world.time + action_cooldown)
	playsound(owner, 'sound/effects/magic/summon_magic.ogg', 50, TRUE)
	return AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/void_heal
	action_cooldown = 2.5 SECONDS

/datum/ai_behavior/void_heal/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/mob/living/healer = controller.pawn
	var/mob/living/target = controller.blackboard[target_key]
	if(!target || QDELETED(target) || target.stat == DEAD)
		controller.clear_blackboard_key(target_key)
		return AI_BEHAVIOR_FAILED
	if(target.health >= target.maxHealth)
		controller.clear_blackboard_key(target_key)
		return AI_BEHAVIOR_FAILED
	if(!(FACTION_VOID in target.faction))
		controller.clear_blackboard_key(target_key)
		return AI_BEHAVIOR_FAILED
	if(get_dist(healer, target) > 4)
		return AI_BEHAVIOR_FAILED
	// Moderate burst heal, 2.5s cooldown
	target.adjust_brute_loss(-35)
	target.adjust_fire_loss(-35)
	target.adjust_tox_loss(-15)
	healer.visible_message(span_notice("[healer] channels void energy into [target], mending their wounds."))
	new /obj/effect/temp_visual/heal(target.loc, "#8A2BE2")
	playsound(target, 'sound/effects/magic/staff_healing.ogg', 50, TRUE)
	controller.set_blackboard_key(BB_VOID_HEAL_COOLDOWN, world.time + action_cooldown)
	controller.clear_blackboard_key(target_key)
	return AI_BEHAVIOR_SUCCEEDED

// --- UTILS & VISUALS ---

/datum/targeting_strategy/basic/void_aggressive/can_attack(mob/living/owner, atom/target, vision_range)
	if(!target || isobserver(target))
		return FALSE

	var/turf/source_turf = get_turf(owner)
	var/turf/target_turf = get_turf(target)

	if(!source_turf || !target_turf)
		return FALSE

	if(get_dist(source_turf, target_turf) > 7)
		return FALSE

	var/deg_to_target = get_angle(owner, target)
	var/dir_angle = dir2angle(owner.dir)

	var/diff = deg_to_target - dir_angle
	while(diff <= -180) diff += 360
	while(diff > 180) diff -= 360
	diff = abs(diff)

	if(diff > 45)
		return FALSE

	for(var/turf/check_turf in get_line(source_turf, target_turf))
		if(check_turf == source_turf || check_turf == target_turf)
			continue

		if(check_turf.opacity)
			return FALSE

		for(var/atom/movable/AM in check_turf)
			if(AM.density && AM != owner && AM != target)
				return FALSE

	if(ismob(target))
		var/mob/living/L = target
		if(L.stat == DEAD)
			return FALSE

		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			if(istype(H.dna?.species, /datum/species/protean))
				var/datum/species/protean/P = H.dna.species
				if(H.loc == P.species_modsuit)
					return FALSE

				var/obj/item/organ/brain/protean/orchestrator = H.get_organ_slot(ORGAN_SLOT_BRAIN)
				if(!orchestrator || orchestrator.dead)
					return FALSE

		if(!compare_factions(owner, L))
			if(istype(owner, /mob/living/basic/void_creature/voidbug))
				var/mob/living/basic/void_creature/voidbug/VB = owner
				VB.alert_allies(L)
			return TRUE

	if(istype(target, /obj/vehicle/sealed/mecha))
		if(!compare_factions(owner, target))
			return TRUE

	return FALSE

/proc/compare_factions(mob/living/owner, atom/target)
	if(!owner.faction) return FALSE
	var/list/tf
	if(ismob(target))
		var/mob/M = target
		tf = M.faction
	else if(istype(target, /obj/vehicle/sealed/mecha))
		var/obj/vehicle/sealed/mecha/Mech = target
		tf = Mech.faction
	if(!tf) return FALSE
	for(var/F in owner.faction)
		if(F in tf) return TRUE
	return FALSE

/obj/effect/temp_visual/heal
	icon = 'icons/effects/effects.dmi'
	icon_state = "heal"
	duration = 10

/obj/effect/temp_visual/heal/Initialize(mapload, color)
	. = ..()
	if(color) add_atom_colour(color, FIXED_COLOUR_PRIORITY)

/obj/effect/temp_visual/void_alert
	icon = 'icons/effects/effects.dmi'
	icon_state = "sec_holo"
	duration = 5

/obj/effect/temp_visual/void_alert/Initialize(mapload)
	. = ..()
	add_atom_colour("#8A2BE2", FIXED_COLOUR_PRIORITY)

/obj/effect/temp_visual/void_tear
	name = "void tear"
	desc = "A shimmering rift in reality."
	icon = 'icons/effects/effects.dmi'
	icon_state = "emppulse"
	duration = 8

/obj/effect/temp_visual/void_tear/Initialize(mapload)
	. = ..()
	add_atom_colour("#4B0082", FIXED_COLOUR_PRIORITY)
	set_light(2, 1, "#4B0082")
