// Base templates, loot definitions, visual effects, and aggressive targeting logic.

#define BB_VOID_SUMMON_COOLDOWN "void_summon_cooldown"
#define BB_VOID_HEAL_COOLDOWN "void_heal_cooldown"
#define BB_HEAL_TARGET "heal_target"
#define BB_VOIDBUG_LAST_PACK_CALL "voidbug_last_pack_call"
#define VEILBREAK_VOID_CREATURE_LOOT_CHANCE 10

/mob/living/basic/void_creature
	name = "Void Creature"
	desc = "A creature from the void."
	faction = list(FACTION_VOID)
	gender = NEUTER
	mob_biotypes = MOB_MINING|MOB_SPECIAL
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

/mob/living/basic/void_creature/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)
	AddElement(/datum/element/ai_retaliate)
	faction |= FACTION_HOSTILE
	AddElement(/datum/element/relay_attackers)
	apply_veilbreak_void_creature_stat_scaling()

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

/datum/targeting_strategy/basic/void_aggressive

/datum/targeting_strategy/basic/void_aggressive/is_valid_target(mob/living/living_mob, atom/the_target, vision_range, datum/ai_controller/controller = null)
	if(!..())
		return FALSE
	var/turf/source_turf = get_turf(living_mob)
	var/turf/target_turf = get_turf(the_target)
	if(!source_turf || !target_turf)
		return FALSE
	for(var/turf/check_turf in get_line(source_turf, target_turf))
		if(check_turf == source_turf || check_turf == target_turf)
			continue
		if(check_turf.opacity)
			return FALSE
		for(var/atom/A in check_turf)
			if(ismob(A))
				continue
			if(A.density)
				return FALSE
	if(ishuman(the_target))
		var/mob/living/carbon/human/H = the_target
		if(istype(H.dna?.species, /datum/species/protean))
			var/datum/species/protean/P = H.dna.species
			if(H.loc == P.species_modsuit)
				return FALSE
			var/obj/item/organ/brain/protean/orchestrator = H.get_organ_slot(ORGAN_SLOT_BRAIN)
			if(!orchestrator || orchestrator.dead)
				return FALSE
	if(isliving(the_target))
		var/mob/living/L = the_target
		if(istype(living_mob, /mob/living/basic/void_creature/voidbug))
			var/mob/living/basic/void_creature/voidbug/VB = living_mob
			VB.alert_allies(L)
		return TRUE
	if(istype(the_target, /obj/vehicle/sealed/mecha) || istype(the_target, /mob/living/silicon))
		return TRUE
	return FALSE

/obj/projectile/magic/voidbolt
	name = "void bolt"
	icon = 'modular_zzveilbreak/icons/item_icons/voidring.dmi'
	icon_state = "voidbolt"
	damage = 5
	damage_type = BURN
	range = 14
	speed = 2
	hitsound = 'sound/effects/magic/magic_missile.ogg'

/obj/projectile/magic/voidbolt/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(isliving(target) && blocked < 100)
		var/mob/living/L = target
		L.adjust_stutter(4 SECONDS)

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
