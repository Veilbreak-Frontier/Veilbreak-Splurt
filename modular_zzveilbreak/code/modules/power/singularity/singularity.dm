/obj/singularity
	/// World time when the singularity will next throw nuclear particles
	var/next_particle_fire_time = 0

/obj/singularity/process(seconds_per_tick)
	. = ..()
	pulse_radiation()
	fire_nuclear_particles_burst()

/obj/singularity/proc/pulse_radiation()
	if(!SSradiation.can_fire)
		return
	var/rad_range = current_size * 5
	var/rad_chance = 15 + (current_size * 5)
	radiation_pulse(src, max_range = rad_range, threshold = 0.2, chance = rad_chance)

/obj/singularity/proc/fire_nuclear_particles_burst()
	if(world.time < next_particle_fire_time)
		return
	next_particle_fire_time = world.time + rand(20, 60)
	var/particle_count = rand(2, 8)
	for(var/i in 1 to particle_count)
		fire_nuclear_particle(rand(0, 360))

