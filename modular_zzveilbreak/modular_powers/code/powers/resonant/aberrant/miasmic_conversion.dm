/*
	You passively convert your brute and burn damage into toxins damage at a defined ratio.
*/
/datum/power/aberrant/miasmic_conversion
    name = "Miasmic Conversion"
    desc = "Your body mends itself disturbingly well, but creates toxic backlash in your system. You passively convert 1 brute or burn damage per second to toxins damage, at a 90% ratio. You also passively heal a tiny amount of toxins damage per second."
    security_record_text = "Subject extremely rapidly regenerates, but experiences toxic backlash when they do."
    value = 4
    power_flags = POWER_HUMAN_ONLY | POWER_PROCESSES

    required_powers = list(/datum/power/aberrant_root/monstrous)

    var/passive_tox_healing = 0.05
    var/healing = 1
    var/conversion_rate = 0.90

/datum/power/aberrant/miasmic_conversion/process(seconds_per_tick)
    var/heal_amt = healing * seconds_per_tick
    if(heal_amt <= 0)
        return

    var/is_toxin_lover = HAS_TRAIT(power_holder, TRAIT_TOXINLOVER)

    if(!is_toxin_lover)
        var/passive_heal_sum = passive_tox_healing * seconds_per_tick
        power_holder.adjust_tox_loss(-passive_heal_sum)

    var/mob/living/carbon/mob = power_holder
    var/list/parts = mob.get_damaged_bodyparts(1, 1, BODYTYPE_ORGANIC)
    if(!parts.len)
        return
    var/obj/item/bodypart/bodypart = pick(parts)

    var/damage_before = bodypart.get_damage()
    if(bodypart.heal_damage(heal_amt, heal_amt, required_bodytype = BODYTYPE_ORGANIC))
        mob.update_damage_overlays()

    var/healed = damage_before - bodypart.get_damage()

    if(healed > 0 && !is_toxin_lover)
        power_holder.adjust_tox_loss(healed * conversion_rate)
