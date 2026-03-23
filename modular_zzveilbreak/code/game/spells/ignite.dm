/datum/action/cooldown/spell/pointed/ignite
	name = "Ignite"
	desc = "Ignites a target tile, burning any flammable gases."
	button_icon_state = "sacredflame"

	school = SCHOOL_EVOCATION
	cooldown_time = 10 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

	invocation = "Ignis!"
	invocation_type = INVOCATION_SHOUT
	cast_range = 1

/datum/action/cooldown/spell/pointed/ignite/is_valid_target(atom/cast_on)
	return ..() || isopenturf(cast_on)

/datum/action/cooldown/spell/pointed/ignite/cast(atom/cast_on)
	. = ..()

	// Handle reagents in the target directly (e.g. beakers)
	if(cast_on.reagents && cast_on.reagents.total_volume)
		cast_on.reagents.expose_temperature(550)
		if(isitem(cast_on))
			cast_on.visible_message(span_notice("[cast_on] reacts to the heat!"))

	// Handle the turf environment
	var/turf/open/T = get_turf(cast_on)
	if(istype(T))
		T.hotspot_expose(1000, 125)
		do_sparks(1, FALSE, T)

		// Ignite oil pools and other cleanables on the turf
		for(var/obj/effect/decal/cleanable/cleanable in T)
			// Force reagent initialization for things like oil that might be dormant
			cleanable.lazy_init_reagents()
			if(cleanable.reagents && cleanable.reagents.total_volume)
				cleanable.reagents.expose_temperature(550)
