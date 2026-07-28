/// Base datum for Veilbreak achievements
/datum/award/achievement/veilbreak
	category = "Veilbreak"

/// Awarded when a Succubus increases their mark on a victim to maximum level (Level 5)
/datum/award/achievement/veilbreak/succubus_max_mark
	name = "Marked to Perfection"
	desc = "Reach maximum mark level on a victim as a Succubus."
	database_id = MEDAL_SUCCUBUS_MAX_MARK
	icon = 'modular_zzveilbreak/icons/mob/succubus.dmi'
	icon_state = "apply"

/// Awarded for slaying Melos Vecare
/datum/award/achievement/veilbreak/melos_vecare_kill
	name = "I never liked your voice"
	desc = "Kill Melos Vecare."
	database_id = MEDAL_MELOS_VECARE_KILL
	icon = 'modular_zzveilbreak/icons/bosses/melos.dmi'
	icon_state = "idle"

/// Awarded for slaying Inai
/datum/award/achievement/veilbreak/inai_kill
	name = "Not another step."
	desc = "Kill Inai."
	database_id = MEDAL_INAI_KILL
	icon = 'modular_zzveilbreak/icons/bosses/inai_model.dmi'
	icon_state = "inai"

