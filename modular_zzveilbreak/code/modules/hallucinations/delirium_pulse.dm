var/Dradius = 150
var/Ddura = 50 SECONDS
var/Dmax = 50 SECONDS
GLOBAL_LIST_EMPTY(delirium_cooldowns)
/proc/visible_hallucination_pulse_delirium(atom/center, radius = Dradius, hallucination_duration = Ddura)
	for(var/mob/living/nearby_living in range(center, radius))
		var/dist = sqrt(1 / max(1, get_dist(nearby_living, center)))
		nearby_living.adjust_hallucinations_up_to(hallucination_duration * dist, Dmax)
		if(world.time - (GLOB.delirium_cooldowns[nearby_living] || 0) > 50 SECONDS)
			to_chat(nearby_living, "<span class='hallucination' style='color:#8a2be2; font-style:italic;'>" + pick(GLOB.delirious_table) + "</span>")
			GLOB.delirium_cooldowns[nearby_living] = world.time
