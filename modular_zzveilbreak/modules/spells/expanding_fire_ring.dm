/// Expanding Fire Ring Spell
/// Deals fire damage in an expanding circle around the caster
/datum/action/cooldown/spell/expanding_fire_ring
	name = "Expanding Fire Ring"
	desc = "Creates a ring of fire that expands outward from you, dealing fire damage to all in its path."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "fireball"
	background_icon_state = "bg_spell"
	overlay_icon_state = "bg_spell_border"

	sound = 'sound/effects/magic/fireball.ogg'
	school = SCHOOL_EVOCATION
	cooldown_time = 30 SECONDS

	invocation = "MY SOUL TO KEEP!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE // Can be cast robeless

	/// Maximum range the fire ring expands to
	var/max_range = 7
	/// Damage dealt per ring expansion
	var/fire_damage = 15
	/// Time between each ring expansion (in deciseconds)
	var/expansion_delay = 0.5 SECONDS
	/// Starting radius (usually 0, but can be adjusted)
	var/start_radius = 1
	/// Visual effect to spawn on affected turfs
	var/visual_effect = /obj/effect/temp_visual/fire_ring
	/// Whether to damage the caster
	var/damage_caster = FALSE

/datum/action/cooldown/spell/expanding_fire_ring/is_valid_target(atom/cast_on)
	return isliving(cast_on)

/datum/action/cooldown/spell/expanding_fire_ring/cast(mob/living/cast_on)
	. = ..()
	if(!isturf(cast_on.loc))
		return

	var/turf/center_turf = get_turf(cast_on)
	playsound(center_turf, sound, 50, TRUE)

	// Start expanding from the starting radius
	var/current_radius = start_radius
	var/expansion_step = 0

	// Create expanding rings
	while(current_radius <= max_range)
		addtimer(CALLBACK(src, PROC_REF(expand_ring), center_turf, current_radius, cast_on), expansion_step * expansion_delay)
		current_radius++
		expansion_step++

/datum/action/cooldown/spell/expanding_fire_ring/proc/expand_ring(turf/center, radius, mob/living/caster)
	if(QDELETED(caster) || QDELETED(center))
		return

	// Get all turfs in the ring at this radius
	var/list/turf/ring_turfs = get_ring_turfs(center, radius)

	for(var/turf/target_turf in ring_turfs)
		// Create visual effect
		if(visual_effect)
			new visual_effect(target_turf)

		// Deal damage to living mobs on this turf
		for(var/mob/living/victim in target_turf)
			if(victim == caster && !damage_caster)
				continue
			if(victim.can_block_magic(antimagic_flags))
				continue

			victim.apply_damage(fire_damage, BURN, wound_bonus = CANT_WOUND)
			if(victim != caster)
				to_chat(victim, span_userdanger("You are burned by the expanding fire ring!"))

		// Heat up the turf
		target_turf.hotspot_expose(700, 50, 1)

/datum/action/cooldown/spell/expanding_fire_ring/proc/get_ring_turfs(turf/center, radius)
	var/list/turf/ring_turfs = list()

	if(radius == 0)
		// Center tile only
		ring_turfs += center
		return ring_turfs

	// Get all turfs at exactly this distance (ring shape)
	// We need turfs at radius but not at radius-1
	var/list/turf/inner_turfs = radius > 1 ? circle_range_turfs(center, radius - 1) : list()
	var/list/turf/outer_turfs = circle_range_turfs(center, radius)

	// Ring is outer minus inner
	ring_turfs = outer_turfs - inner_turfs

	return ring_turfs

/// Visual effect for the fire ring
/obj/effect/temp_visual/fire_ring
	name = "fire ring"
	icon = 'icons/effects/fire.dmi'
	icon_state = "heavy"
	duration = 0.5 SECONDS
	light_color = LIGHT_COLOR_FIRE
	light_range = LIGHT_RANGE_FIRE
	light_power = 1

/obj/effect/temp_visual/fire_ring/Initialize(mapload)
	. = ..()
	set_light(light_range, light_power, light_color)
	playsound(src, 'sound/effects/magic/fireball.ogg', 30, TRUE)

