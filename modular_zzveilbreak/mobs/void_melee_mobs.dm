// Melee controllers and specific mob paths for Voidlings and Voidbugs.

/datum/ai_controller/basic_controller/simple/hostile/void_melee
	behavior_tree_json = "modular_zzveilbreak/modules/void_melee.json"
	ai_movement = /datum/ai_movement/basic_avoidance
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/void_aggressive,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_AGGRO_RANGE = 10
	)

/mob/living/basic/void_creature/voidling
	name = "Voidling"
	desc = "You struggle to comprehend the details of this creature, it keeps shifting and changing constantly."
	icon = 'modular_zzveilbreak/icons/mob/mobs.dmi'
	icon_state = "voidling"
	icon_living = "voidling"
	icon_dead = "voidling_dead"
	ai_controller = /datum/ai_controller/basic_controller/simple/hostile/void_melee
	maxHealth = 60
	health = 60
	melee_damage_lower = 8
	melee_damage_upper = 12
	speed = 0.8
	armor = list(
		BLUNT = 25, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0,
		BOMB = 0, BIO = 0, FIRE = 0, ACID = 0, MAGIC = 0, RADIATION = 0,
	)

/mob/living/basic/void_creature/voidling/do_void_creature_loot_drop()
	var/loot_type = pick_loot_from_table(voidling_loot_table)
	if(loot_type)
		new loot_type(drop_location())

/mob/living/basic/void_creature/voidling/Move()
	. = ..()
	if(.)
		flick("voidling_2", src)

/mob/living/basic/void_creature/voidbug
	name = "Voidbug"
	desc = "A resilient bug-like creature from the void, its chitinous plates deflect attacks with ease."
	icon = 'modular_zzveilbreak/icons/mob/mobs.dmi'
	icon_state = "void_bug"
	icon_living = "void_bug"
	icon_dead = "void_bug_dead"
	ai_controller = /datum/ai_controller/basic_controller/simple/hostile/void_melee
	maxHealth = 140
	health = 140
	melee_damage_lower = 5
	melee_damage_upper = 7
	speed = 1.3
	armor = list(
		BLUNT = 30, PUNCTURE = 30, SLASH = 30, LASER = -10, ENERGY = 0,
		BOMB = 0, BIO = 50, FIRE = -50, ACID = 0, MAGIC = 30, RADIATION = 80,
	)
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
	if(!target || target.stat == DEAD || (FACTION_VOID in target.faction))
		return
	last_alert_time = world.time
	visible_message(span_danger("[src] lets out a resonant, vibrating hum, alerting nearby void creatures!"))
	playsound(src, 'sound/effects/hallucinations/growl1.ogg', 70, TRUE)
	new /obj/effect/temp_visual/void_tear(loc)
	for(var/mob/living/basic/void_creature/V in view(7, src))
		if(V == src || V.stat == DEAD || !V.ai_controller)
			continue
		V.ai_controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, target)
		new /obj/effect/temp_visual/void_alert(V.loc)
