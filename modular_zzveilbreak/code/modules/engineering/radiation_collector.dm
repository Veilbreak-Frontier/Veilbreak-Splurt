/* Temporarily disabled: radiation collector under development

/obj/machinery/power/radiation_collector
	name = "radiation collector"
	desc = "A machine that passively collects radiation and converts it into power."
	icon = 'modularzz_veilbreak/icons/obj/machines/radiation_collector.dmi'
	icon_state = "off"
	density = TRUE
	anchored = TRUE

	var/radiation_collected = 0
	var/power_generation_rate = 1000

	var/last_process_time = 0

/obj/machinery/power/radiation_collector/New()
	..()
	last_process_time = world.time
	RegisterSignal(src, "nuclear_particle_hit", .proc/on_nuclear_particle_hit)
	START_PROCESSING(SSmachines, src)

/obj/machinery/power/radiation_collector/proc/on_nuclear_particle_hit(obj/projectile/energy/nuclear_particle/P)
	. = TRUE
	radiation_collected += 100

/obj/machinery/power/radiation_collector/process()
	var/delta_time = world.time - last_process_time
	last_process_time = world.time

	var/list/particles = list()
	var/const/PARTICLE_BOUNDS_X1 = 11
	var/const/PARTICLE_BOUNDS_Y1 = 12
	var/const/PARTICLE_BOUNDS_X2 = 22
	var/const/PARTICLE_BOUNDS_Y2 = 28

	var/turf/T = get_turf(src)
	if(!T)
		return

	var/radiation_level = SSradiation.get_turf_radiation(T)
	radiation_collected += radiation_level * delta_time

	if(radiation_collected > 0)
		var/power_generated = min(radiation_collected * power_generation_rate, 10000)
		add_power(power_generated)
		radiation_collected -= power_generated / power_generation_rate
		icon_state = "on"
	else
		icon_state = "off"

	update_particles()

/obj/machinery/power/radiation_collector/proc/update_particles()
	var/target_particles = round(radiation_collected / 10)

	while(particles.len < target_particles)
		var/datum/particle/P = new()
		P.x = rand(PARTICLE_BOUNDS_X1, PARTICLE_BOUNDS_X2)
		P.y = rand(PARTICLE_BOUNDS_Y1, PARTICLE_BOUNDS_Y2)
		P.dx = rand(-1, 1)
		P.dy = rand(-1, 1)

		P.overlay = image('modularzz_veilbreak/icons/obj/machines/particle.dmi')
		P.overlay.pixel_x = P.x - 16
		P.overlay.pixel_y = P.y - 16
		overlays += P.overlay
		particles += P

	while(particles.len > target_particles)
		var/datum/particle/P = particles[1]
		overlays -= P.overlay
		particles.Remove(P)
		qdel(P)

	for(var/datum/particle/P in particles)
		P.x += P.dx
		P.y += P.dy

		if(P.x <= PARTICLE_BOUNDS_X1 || P.x >= PARTICLE_BOUNDS_X2)
			P.dx = -P.dx
			P.x += P.dx

		if(P.y <= PARTICLE_BOUNDS_Y1 || P.y >= PARTICLE_BOUNDS_Y2)
			P.dy = -P.dy
			P.y += P.dy

		P.overlay.pixel_x = P.x - 16
		P.overlay.pixel_y = P.y - 16

/obj/machinery/power/radiation_collector/power_change()
	..()
	update_power()

/datum/particle
	var/x
	var/y
	var/dx
	var/dy
	var/image/overlay


/atom/proc/on_nuclear_particle_hit(obj/projectile/energy/nuclear_particle/P)
	return

*/
