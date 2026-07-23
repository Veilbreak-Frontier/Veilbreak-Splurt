/datum/wires/interactable(mob/user)
    if(isliving(user))
        var/mob/living/L = user
        if(L.stat || L.IsStun() || L.IsKnockdown() || L.IsParalyzed())
            return FALSE
    return ..()
