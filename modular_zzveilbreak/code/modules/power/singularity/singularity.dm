/obj/singularity/process(seconds_per_tick)
	. = ..()
	pulse_radiation()

/obj/singularity/proc/pulse_radiation()
	if(!SSradiation.can_fire)
		return
	var/rad_range = current_size * 3
	var/rad_chance = 15 + (current_size * 5)
	radiation_pulse(src, max_range = rad_range, threshold = 0.2, chance = rad_chance)
