/datum/sm_gas/delirium
	gas_path = /datum/gas/delirium
	heat_modifier = 15
	power_transmission = 6
	heat_power_generation = 1.7
	powerloss_inhibition = 2
	desc = "Strong fuel with unknown properties. Take proper caution when testing."

/datum/sm_gas/delirium/extra_effects(obj/machinery/power/supermatter_crystal/sm)
	var/delirium_ratio = clamp(sm.gas_percentage[/datum/gas/delirium], 0, 1)
	if(!delirium_ratio)
		return

	var/radius = round(LERP(10, 180, delirium_ratio))
	var/hallucination_duration = round(LERP(8, 60, delirium_ratio)) SECONDS
	visible_hallucination_pulse_delirium(
		center = sm,
		radius = radius,
		hallucination_duration = hallucination_duration,
	)


