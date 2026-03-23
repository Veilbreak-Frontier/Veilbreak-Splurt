/// Status effect that ticks subversion progress for a succubus-marked victim (level 2+).
/datum/status_effect/succubus_subversion
	id = "succubus_subversion"
	tick_interval = 20 SECONDS
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	/// Ref to the mark datum
	var/datum/succubus_mark/mark_datum
	/// Stored ref for REMOVE_TRAIT when mark is gone
	var/mark_trait_ref

/datum/status_effect/succubus_subversion/on_creation(mob/living/new_owner, datum/succubus_mark/mark)
	. = ..()
	if(!.)
		return
	if(!istype(mark))
		return FALSE
	mark_datum = mark
	mark_trait_ref = REF(mark)

/datum/status_effect/succubus_subversion/tick(seconds_between_ticks)
	if(!mark_datum || mark_datum.level < 3)
		qdel(src)
		return
	mark_datum.subversion_progress = min(100, mark_datum.subversion_progress + SUCCUBUS_SUBVERSION_RATE)
	// At 100% add a trait
	if(mark_datum.subversion_progress >= 100 && !HAS_TRAIT(owner, TRAIT_SUCCUBUS_SERVANT))
		ADD_TRAIT(owner, TRAIT_SUCCUBUS_SERVANT, mark_trait_ref)
		to_chat(owner, span_pink("You feel an overwhelming desire to serve [mark_datum.owner_mind?.current?.name || "your master"]."))

/datum/status_effect/succubus_subversion/on_remove()
	if(owner && mark_trait_ref && HAS_TRAIT(owner, TRAIT_SUCCUBUS_SERVANT))
		REMOVE_TRAIT(owner, TRAIT_SUCCUBUS_SERVANT, mark_trait_ref)
	mark_datum = null
	return ..()
