/datum/status_effect/ashwalker_damage
	id = "ashwalker_damage"
	duration = STATUS_EFFECT_PERMANENT
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	var/total_damage = 0

/datum/status_effect/ashwalker_damage/proc/register_mob_damage(mob/living/target)
	RegisterSignal(target, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(calculate_total), override = TRUE)

/datum/status_effect/ashwalker_damage/proc/calculate_total(datum/source, damage, damagetype, def_zone)
	SIGNAL_HANDLER

	if(!QDELETED(src))
		total_damage += damage
	UnregisterSignal(source, COMSIG_MOB_APPLY_DAMAGE)
