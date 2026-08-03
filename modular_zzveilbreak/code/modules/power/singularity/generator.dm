/obj/machinery/the_singularitygen
	name = "Gravitational Singularity Generator"
	desc = "An odd device which produces a Gravitational Singularity when set up."
	icon = 'modular_zzveilbreak/icons/obj/singularity.dmi'
	icon_state = "TheSingGen"
	anchored = FALSE
	density = TRUE
	use_power = NO_POWER_USE
	resistance_flags = FIRE_PROOF
	can_buckle = TRUE
	buckle_lying = FALSE
	buckle_requires_restraints = TRUE
	var/energy = 0
	var/creation_type = /obj/singularity

/obj/machinery/the_singularitygen/wrench_act(mob/living/user, obj/item/tool)
	default_unfasten_wrench(user, tool)
	return TRUE

/obj/machinery/the_singularitygen/process()
	if(energy > 0)
		if(energy >= 200)
			var/turf/T = get_turf(src)
			SSblackbox.record_feedback("tally", "engine_started", 1, type)
			var/obj/singularity/S = new creation_type(T, 50)
			transfer_fingerprints_to(S)
			qdel(src)
		else
			energy -= 1
