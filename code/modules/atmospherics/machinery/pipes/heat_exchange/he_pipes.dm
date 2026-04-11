/// Mole-based conductivity uses `1 + (this - 1) * n/(n+K)` — approaches this multiplier as tile moles → ∞
#define HE_PIPE_CONDUCTIVITY_MOLE_CAP 6
/// Moles at which extra air is halfway between 1x and HE_PIPE_CONDUCTIVITY_MOLE_CAP (one standard cell of gas)
#define HE_PIPE_CONDUCTIVITY_MOLE_K MOLES_CELLSTANDARD

/obj/machinery/atmospherics/pipe/heat_exchanging
	var/minimum_temperature_difference = 0
	var/thermal_conductivity = 1
	color = "#404040"
	buckle_lying = NO_BUCKLE_LYING
	var/icon_temperature = T20C //stop small changes in temperature causing icon refresh
	resistance_flags = LAVA_PROOF | FIRE_PROOF

	hide = FALSE

	has_gas_visuals = FALSE

/obj/machinery/atmospherics/pipe/heat_exchanging/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_UNDERTILE_UPDATED, PROC_REF(on_hide))

	add_atom_colour("#404040", FIXED_COLOUR_PRIORITY)

/obj/machinery/atmospherics/pipe/heat_exchanging/examine(mob/user)
	. = ..()
	. += span_notice("Effective thermal conductivity: [round(get_thermal_conductivity_for_turf(get_turf(src)), 0.001)].")

/obj/machinery/atmospherics/pipe/heat_exchanging/is_connectable(obj/machinery/atmospherics/pipe/heat_exchanging/target, given_layer, HE_type_check = TRUE)
	if(istype(target, /obj/machinery/atmospherics/pipe/heat_exchanging) != HE_type_check)
		return FALSE
	. = ..()

/obj/machinery/atmospherics/pipe/heat_exchanging/proc/get_tile_moles(turf/local_turf)
	if(!istype(local_turf, /turf/open))
		return 0
	if(islava(local_turf))
		return 0
	if(local_turf.liquids && local_turf.liquids.liquid_state >= LIQUID_STATE_FOR_HEAT_EXCHANGERS)
		return 0

	var/datum/gas_mixture/tile_air = local_turf.return_air()
	if(!tile_air)
		return 0
	return tile_air.total_moles()

/obj/machinery/atmospherics/pipe/heat_exchanging/proc/get_thermal_conductivity_for_turf(turf/local_turf)
	var/tile_moles = max(get_tile_moles(local_turf), 0)
	var/mole_mult = 1 + (HE_PIPE_CONDUCTIVITY_MOLE_CAP - 1) * (tile_moles / (tile_moles + HE_PIPE_CONDUCTIVITY_MOLE_K))
	return thermal_conductivity * mole_mult

/obj/machinery/atmospherics/pipe/heat_exchanging/process_atmos()
	var/environment_temperature = 0
	var/datum/gas_mixture/pipe_air = return_air()

	var/turf/local_turf = loc
	if(istype(local_turf))
		if(islava(local_turf))
			environment_temperature = 5000 //Yuck
		//SKYRAT EDIT ADDITION
		else if (local_turf.liquids && local_turf.liquids.liquid_state >= LIQUID_STATE_FOR_HEAT_EXCHANGERS)
			environment_temperature = local_turf.liquids.temp
		//SKYRAT EDIT END
		else if(local_turf.blocks_air)
			environment_temperature = local_turf.temperature
		else
			var/turf/open/open_local = local_turf
			environment_temperature = open_local.GetTemperature()
	else
		environment_temperature = local_turf.temperature
	if(abs(environment_temperature-pipe_air.temperature) > minimum_temperature_difference)
		parent.temperature_interact(local_turf, volume, get_thermal_conductivity_for_turf(local_turf))


	//heatup/cooldown any mobs buckled to ourselves based on our temperature
	if(has_buckled_mobs())
		var/hc = pipe_air.heat_capacity()
		var/mob/living/heat_source = buckled_mobs[1]
		//Best guess-estimate of the total bodytemperature of all the mobs, since they share the same environment it's ~ok~ to guess like this
		var/avg_temp = (pipe_air.temperature * hc + (heat_source.bodytemperature * buckled_mobs.len) * 3500) / (hc + (buckled_mobs ? buckled_mobs.len * 3500 : 0))
		for(var/mob/living/buckled_mob as anything in buckled_mobs)
			buckled_mob.bodytemperature = avg_temp
		pipe_air.temperature = avg_temp

/obj/machinery/atmospherics/pipe/heat_exchanging/process(seconds_per_tick)
	if(!parent)
		return //machines subsystem fires before atmos is initialized so this prevents race condition runtimes

	var/datum/gas_mixture/pipe_air = return_air()

	//Heat causes pipe to glow
	if(pipe_air.temperature && (icon_temperature > 500 || pipe_air.temperature > 500)) //glow starts at 500K
		if(abs(pipe_air.temperature - icon_temperature) > 10)
			icon_temperature = pipe_air.temperature

			var/h_r = heat2colour_r(icon_temperature)
			var/h_g = heat2colour_g(icon_temperature)
			var/h_b = heat2colour_b(icon_temperature)

			if(icon_temperature < 2000)//scale glow until 2000K
				var/scale = (icon_temperature - 500) / 1500
				h_r = 64 + (h_r - 64) * scale
				h_g = 64 + (h_g - 64) * scale
				h_b = 64 + (h_b - 64) * scale

			animate(src, color = rgb(h_r, h_g, h_b), time = 20, easing = SINE_EASING)

	//burn any mobs buckled based on temperature
	if(!has_buckled_mobs())
		return
	var/heat_limit = 1000
	if(pipe_air.temperature > heat_limit + 1)
		for(var/mob/living/buckled_mob as anything in buckled_mobs)
			buckled_mob.apply_damage(seconds_per_tick * 2 * log(pipe_air.temperature - heat_limit), BURN, BODY_ZONE_CHEST)

/obj/machinery/atmospherics/pipe/heat_exchanging/update_pipe_icon()
	return
