/obj/singularity
	/// World time when the singularity will next throw nuclear particles
	var/next_particle_fire_time = 0

/obj/singularity/process(seconds_per_tick)
	. = ..()
	fire_nuclear_particles_burst()

/obj/singularity/proc/pulse_radiation()
	return

/obj/singularity/proc/fire_nuclear_particles_burst()
	if(world.time < next_particle_fire_time)
		return
	next_particle_fire_time = world.time + rand(20, 60)
	var/particle_count = rand(2, 8)
	for(var/i in 1 to particle_count)
		fire_nuclear_particle(rand(0, 360))

/obj/projectile/energy/nuclear_particle/singularity_act(current_size, obj/singularity/singularity)
	return 0

/obj/projectile/energy/nuclear_particle/singularity_pull(atom/singularity, current_size)
	return


