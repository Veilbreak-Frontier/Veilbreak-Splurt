/*
	1.5x speed on surgery.
*/

/datum/power/expert/master_surgeon
	name = "Master Surgeon"
	desc = "Surgery takes composure and skill which you have aplenty. Increases your action speed with surgery by a factor of 1.5x."
	security_record_text = "Subject has an unusual skill in surgery."
	value = 3

	menu_icon = 'icons/obj/medical/surgery_tools.dmi'
	menu_icon_state = "scalpel"

	/// 1.5x faster => multiply time by 1/1.5
	var/surgery_speed_mult = 1 / 1.5

/datum/power/expert/master_surgeon/add()
	. = ..()
	if(power_holder)
		power_holder.add_surgery_speed_mod(REF(src), surgery_speed_mult, null)

/datum/power/expert/master_surgeon/remove()
	if(power_holder)
		power_holder.remove_surgery_speed_mod(REF(src))
	. = ..()
