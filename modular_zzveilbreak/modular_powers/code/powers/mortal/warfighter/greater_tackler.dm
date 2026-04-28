/*
	+3 to skill mod, +2 to range, 0.5s to knockdown duration.
*/
/datum/power/warfighter/tackler/greater_tackler
	name = "Greater Tackler"
	desc = "Your chances of landing a succesful tackle are greatly increased, as are your range and the duration you knockdown tackled foes."
	security_record_text = "Subject is exceedingly good at landing tackles."
	security_threat = POWER_THREAT_MAJOR
	value = 5

	required_powers = list(/datum/power/warfighter/tackler)

	/// bonuses to success chance
	var/skill_mod_bonus = 3
	/// bonuses to range
	var/tackle_range_bonus = 2
	/// bonuses to knockdown duration
	var/knockdown_bonus = 0.5 SECONDS

/datum/power/warfighter/tackler/greater_tackler/post_add()
	. = ..()
	var/datum/power/warfighter/tackler/base_tackler = power_holder.get_power(/datum/power/warfighter/tackler)
	var/datum/component/tackler/component = power_holder.GetComponent(/datum/component/tackler)
	var/list/params = component?.tackle_source_params?[base_tackler]
	if(!params)
		return
	params["skill_mod"] += skill_mod_bonus
	params["range"] += tackle_range_bonus
	params["base_knockdown"] += knockdown_bonus
	component.refresh_tackle_stats()

/datum/power/warfighter/tackler/greater_tackler/remove()
	var/datum/power/warfighter/tackler/base_tackler = power_holder.get_power(/datum/power/warfighter/tackler)
	var/datum/component/tackler/component = power_holder.GetComponent(/datum/component/tackler)
	var/list/params = component?.tackle_source_params?[base_tackler]
	if(!params)
		return
	params["skill_mod"] -= skill_mod_bonus
	params["range"] -= tackle_range_bonus
	params["base_knockdown"] -= knockdown_bonus
	component.refresh_tackle_stats()
