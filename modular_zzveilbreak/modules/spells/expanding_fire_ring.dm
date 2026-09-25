/// Expanding Fire Ring Spell
/// Deals fire damage in an expanding circle around the caster.
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
	spell_requirements = NONE // Robeless.

	/// Furthest radius the ring expands to.
	var/max_range = 7
	/// Damage dealt to each victim, per ring that passes over them.
	var/fire_damage = 15
	/// Delay between successive rings.
	var/expansion_delay = 0.5 SECONDS
	/// Radius the first ring spawns at. 0 = the caster's own tile.
	var/start_radius = 1
	/// Visual effect spawned on each affected turf. Null disables it.
	var/visual_effect = /obj/effect/temp_visual/fire_ring
	/// Whether the caster takes damage from their own ring.
	var/damage_caster = FALSE
	/// Temperature (in Kelvin) the ring leaves on each turf it passes over.
	var/turf_temperature = 700
	/// Hotspot volume left on each turf.
	var/turf_hotspot_volume = 50

/datum/action/cooldown/spell/expanding_fire_ring/is_valid_target(atom/cast_on)
	return isliving(cast_on)

/datum/action/cooldown/spell/expanding_fire_ring/cast(mob/living/cast_on)
	. = ..()
	if(!isturf(cast_on.loc))
		return

	var/turf/center = get_turf(cast_on)
	if(!center)
		return

	// Queue one timer per ring. The first ring fires immediately, each
	// subsequent ring is delayed by expansion_delay.
	for(var/radius in start_radius to max_range)
		var/delay = (radius - start_radius) * expansion_delay
		addtimer(CALLBACK(src, PROC_REF(expand_ring), center, radius, cast_on), delay)

/datum/action/cooldown/spell/expanding_fire_ring/proc/expand_ring(turf/center, radius, mob/living/caster)
	if(QDELETED(src) || QDELETED(caster) || QDELETED(center))
		return

	for(var/turf/affected as anything in ring_turfs(center, radius))
		if(visual_effect)
			new visual_effect(affected)

		for(var/mob/living/victim in affected)
			if(victim == caster && !damage_caster)
				continue
			if(victim.can_block_magic(antimagic_flags))
				continue

			victim.apply_damage(fire_damage, BURN, wound_bonus = CANT_WOUND)
			if(victim != caster)
				to_chat(victim, span_userdanger("You are burned by the expanding fire ring!"))

		affected.hotspot_expose(turf_temperature, turf_hotspot_volume)

/// Returns every turf at exactly `radius` Chebyshev distance from `center`.
/// radius <= 0 returns the centre tile by itself.
/datum/action/cooldown/spell/expanding_fire_ring/proc/ring_turfs(turf/center, radius)
	if(radius <= 0)
		return list(center)

	var/list/turf/ring = list()
	for(var/turf/candidate as anything in RANGE_TURFS(radius, center))
		if(get_dist(center, candidate) == radius)
			ring += candidate
	return ring

/// Visual effect for the fire ring.
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
