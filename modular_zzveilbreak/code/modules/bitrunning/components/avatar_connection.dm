/*
FIX: Bitrunners dropping straight into terminal critical condition or dying upon avatar death.
WHY: Prevents simulation feedback damage from double-dipping with the physical netpod's forceful disconnection brain damage penalty.
*/

/datum/component/avatar_connection/proc/on_linked_damage(datum/source, damage, damage_type, def_zone, blocked, ...)
	SIGNAL_HANDLER

	var/mob/living/carbon/old_body = old_body_ref?.resolve()
	if(isnull(old_body) || damage_type == STAMINA || damage_type == OXYLOSS)
			return

	var/max_allowed_health = ishuman(old_body) ? HUMAN_MAXHEALTH : MAX_LIVING_HEALTH
	if(damage >= max_allowed_health)
			full_avatar_disconnect(cause_damage = TRUE)
			return

	if(damage > 30 && prob(30))
			INVOKE_ASYNC(old_body, TYPE_PROC_REF(/mob/living, emote), "scream")

	var/zone = def_zone
	if(isbodypart(def_zone))
			zone = astype(def_zone, /obj/item/bodypart).body_zone

	var/safe_damage = clamp(damage, 0, max(0, old_body.health - 1))
	if(safe_damage > 0)
			old_body.apply_damage(safe_damage, damage_type, zone, blocked, wound_bonus = CANT_WOUND)

	if(IS_UNCONSCIOUS(old_body) || old_body.health <= 0)
			full_avatar_disconnect(cause_damage = TRUE)

	nohit = FALSE
