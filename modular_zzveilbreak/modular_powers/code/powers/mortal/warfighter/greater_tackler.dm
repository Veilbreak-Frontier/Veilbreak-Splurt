/*
	+3 to skill mod, +2 to range, 0.5s to knockdown duration.
*/
/datum/power/warfighter/tackler/greater_tackler
	name = "Greater Tackler"
	desc = "Your chances of landing a successful tackle are greatly increased, as are your range and the duration you knockdown tackled foes."
	security_record_text = "Subject is exceedingly good at landing tackles."
	security_threat = POWER_THREAT_MAJOR
	value = 5
	required_powers = list(/datum/power/warfighter/tackler)

	menu_icon = 'icons/obj/clothing/gloves.dmi'
	menu_icon_state = "gorilla"

	/// bonuses to success chance
	var/skill_mod_bonus = 3
	/// bonuses to range
	var/tackle_range_bonus = 2
	/// bonuses to knockdown duration
	var/knockdown_bonus = 0.5 SECONDS

/datum/power/warfighter/tackler/greater_tackler/add()
	var/tackle_stam_cost = 25
	var/base_knockdown = 1.5 SECONDS
	var/tackle_range = 6
	var/min_distance = 0
	var/tackle_speed = 1
	var/skill_mod = 5

	tackler = power_holder.AddComponentFrom(src, /datum/component/tackler, stamina_cost=tackle_stam_cost, base_knockdown = base_knockdown, range = tackle_range, speed = tackle_speed, skill_mod = skill_mod, min_distance = min_distance)

/datum/power/warfighter/tackler/greater_tackler/remove()
	power_holder.RemoveComponentSource(src, /datum/component/tackler)
