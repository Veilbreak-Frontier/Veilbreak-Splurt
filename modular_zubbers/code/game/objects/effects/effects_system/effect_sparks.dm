/// A version of sparks for cosmetic purposes that doesn't set things on fire.
/proc/do_harmless_sparks(number, cardinal_only, datum/source)
	var/datum/effect_system/basic/spark_spread/quantum/harmless/sparks = new(get_turf(source), number, cardinal_only)
	sparks.attach(source)
	sparks.autocleanup = TRUE
	sparks.start()

/obj/effect/particle_effect/sparks/quantum/harmless
	name = "inert quantum sparks"

/obj/effect/particle_effect/sparks/quantum/harmless/affect_location(turf/location, just_initialized = FALSE)
	return

/obj/effect/particle_effect/sparks/quantum/harmless/sparks_touched(datum/source, atom/singed)
	return

/datum/effect_system/basic/spark_spread/quantum/harmless
	effect_type = /obj/effect/particle_effect/sparks/quantum/harmless
