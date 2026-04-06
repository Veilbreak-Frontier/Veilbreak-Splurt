/datum/quirk/quick_step
    name = "Quick Step"
    desc = "You walk with determined strides, and out-pace most people when walking."
    value = 2
    mob_trait = TRAIT_SPEEDY_STEP
    gain_text = span_notice("You feel determined. No time to lose.")
    lose_text = span_danger("You feel less determined. What's the rush, man?")
    medical_record_text = "Patient scored highly on racewalking tests."
    icon = FA_ICON_PERSON_RUNNING

/datum/quirk/quick_step/add(client/client_source)
    . = ..()
    RegisterSignal(quirk_holder, COMSIG_MOB_MOVESPEED_UPDATED, PROC_REF(handle_speed_update))
    handle_speed_update(quirk_holder)

/datum/quirk/quick_step/remove()
    UnregisterSignal(quirk_holder, COMSIG_MOB_MOVESPEED_UPDATED)
    quirk_holder.remove_movespeed_modifier(/datum/movespeed_modifier/quick_step)
    . = ..()

/datum/quirk/quick_step/proc/handle_speed_update(mob/living/L)
    SIGNAL_HANDLER
    if(!istype(L))
        return

    var/is_walking = (L.move_intent == MOVE_INTENT_WALK)

    if(is_walking)
        L.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/quick_step, multiplicative_slowdown = -0.5, update = FALSE)
    else
        L.remove_movespeed_modifier(/datum/movespeed_modifier/quick_step, update = FALSE)

/datum/movespeed_modifier/quick_step
    variable = TRUE
