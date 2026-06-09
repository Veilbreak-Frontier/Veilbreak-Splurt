/*
	1.5x speed/action success chance on surgery.
	Fun fact fail_prob_index is flat amounts so we are actually giving a -50 flat which is hella busted, but also imho surgery failure chance doesn't exist outside of ghetto.
*/

/datum/power/expert/master_surgeon
	name = "Master Surgeon"
	desc = " Surgery takes composure and skill which you have aplenty. Increases your success rate and action speed with surgery by a factor of 1.5x."
	security_record_text = "Subject has an unusual skill in surgery."
	value = 4
	/// 1.5x faster => multiply time by 1/1.5
	var/surgery_speed_mult = 1 / 1.5
	/// Flat reduction to failure chance (percentage points)
	var/surgery_fail_reduction = 50

/datum/power/expert/master_surgeon/add()
	power_holder.add_surgery_speed_mod(REF(src), surgery_speed_mult)

/datum/power/expert/master_surgeon/remove()
	power_holder.remove_surgery_speed_mod(REF(src))

