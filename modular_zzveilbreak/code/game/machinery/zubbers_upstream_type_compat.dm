/// Types and globals referenced by modular_zubbers before upstream added them (or paths diverged).
GLOBAL_LIST_EMPTY(active_rbmk_machines)

/obj/machinery/power/rbmk2
	var/auto_vent_upgrade = FALSE
	var/safeties_upgrade = FALSE
	var/overclocked_upgrade = FALSE

/// Called from modular_zubbers burger_reactor reactor.dm when `active` changes and from Destroy.
/obj/machinery/power/rbmk2/proc/sync_active_rbmk_glob()
	if(active)
		GLOB.active_rbmk_machines |= src
	else
		GLOB.active_rbmk_machines -= src

/obj/structure/table
	/// Oversized mobs buckling / sitting (modular_zubbers datums/elements/climbable.dm).
	var/list/oversized_sit_directions

/mob/living/carbon/human
	/// Footstep pref applies to future leg bodyparts (modular_zubbers footstep_sound.dm).
	var/footstep_type
