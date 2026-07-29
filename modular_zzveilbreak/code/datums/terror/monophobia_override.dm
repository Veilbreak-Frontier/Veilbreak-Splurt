/mob/living/proc/is_vored()
    return istype(loc, /obj/vore_belly)

/datum/terror_handler/simple_source/monophobia/check_condition(seconds_per_tick, terror_buildup)
    . = ..()
    if (!.)
        return

    if (owner.is_vored())
        return FALSE
