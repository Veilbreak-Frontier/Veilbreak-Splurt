/// Base datum for Veilbreak achievements
/datum/award/achievement/veilbreak
	category = "Veilbreak"
	icon = ACHIEVEMENTS_SET
	icon_state = "basemisc"

/// Awarded when a Succubus increases their mark on a victim to maximum level (Level 5)
/datum/award/achievement/veilbreak/succubus_max_mark
	name = "Marked to Perfection"
	desc = "Reach maximum mark level on a victim as a Succubus."
	database_id = MEDAL_SUCCUBUS_MAX_MARK
	category = "Misc"
	icon = ACHIEVEMENTS_SET
	icon_state = "basemisc"

/// Awarded for slaying Melos Vecare
/datum/award/achievement/veilbreak/melos_vecare_kill
	name = "I never liked your voice"
	desc = "Kill Melos Vecare."
	database_id = MEDAL_MELOS_VECARE_KILL
	category = "Bosses"
	icon = ACHIEVEMENTS_SET
	icon_state = "firstboss"

/// Awarded for slaying Inai
/datum/award/achievement/veilbreak/inai_kill
	name = "Not another step."
	desc = "Kill Inai."
	database_id = MEDAL_INAI_KILL
	category = "Bosses"
	icon = ACHIEVEMENTS_SET
	icon_state = "firstboss"

