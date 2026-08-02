/mob/living/proc/is_vored()
    return istype(loc, /obj/vore_belly)

/mob/living/proc/has_belly_occupants()
    for(var/obj/vore_belly/belly in contents)
        if(LAZYLEN(belly.contents))
            return TRUE
    return FALSE

/datum/terror_handler/simple_source/monophobia/check_condition(seconds_per_tick, terror_buildup)
    . = ..()
    if(!.)
        return

    if(owner.is_vored())
        return FALSE

    if(owner.has_belly_occupants())
        return FALSE

    for(var/mob/living/M in oview(owner, 7))
        if(M == owner)
            continue
        if(owner.has_ally(M) || istype(M, /mob/living/basic/pet) || M.ckey)
            return FALSE

    for(var/obj/item/I in owner.held_items)
        if(ismob(I))
            var/mob/living/M = I
            if(owner.has_ally(M) || istype(M, /mob/living/basic/pet) || M.ckey)
                return FALSE
        for(var/mob/living/M in I.contents)
            if(owner.has_ally(M) || istype(M, /mob/living/basic/pet) || M.ckey)
                return FALSE

    if(ishuman(owner))
        var/mob/living/carbon/human/H = owner
        for(var/obj/item/I in H.get_equipped_items())
            if(ismob(I))
                var/mob/living/M = I
                if(owner.has_ally(M) || istype(M, /mob/living/basic/pet) || M.ckey)
                    return FALSE
            for(var/mob/living/M in I.contents)
                if(owner.has_ally(M) || istype(M, /mob/living/basic/pet) || M.ckey)
                    return FALSE

    return .
