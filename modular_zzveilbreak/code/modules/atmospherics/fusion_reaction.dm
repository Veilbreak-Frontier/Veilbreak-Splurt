#define SET_REACTION_RESULTS(amount) air.reaction_results[type] = amount

/// Fusion (and plasmafire handoff) begins at this temperature when healium is present as a catalyst.
#define FUSION_MINIMUM_TEMPERATURE 80000
/// Without healium, fusion only starts at this temperature so ordinary plasma fires do not accidentally fuse.
#define FUSION_UNCATALYZED_MIN_TEMPERATURE 120000
#define FUSION_QUARK_MATTER_THRESHOLD 800000
#define FUSION_LEVEL_TEMP_STEP 75000
#define FUSION_BASE_BURN_RATE_DIVISOR 15

/proc/fusion_mixture_ready(datum/gas_mixture/air, temperature)
	var/list/healium_gas = air.gases[/datum/gas/healium]
	if(healium_gas && healium_gas[MOLES] >= MINIMUM_MOLE_COUNT)
		return TRUE
	return temperature >= FUSION_UNCATALYZED_MIN_TEMPERATURE

/datum/gas_reaction/fusion
	name = "Fusion"
	id = "fusion"
	priority_group = 4
	expands_hotspot = TRUE

/datum/gas_reaction/fusion/init_reqs()
	requirements = list(
		/datum/gas/plasma = MINIMUM_MOLE_COUNT,
		/datum/gas/oxygen = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = FUSION_MINIMUM_TEMPERATURE
	)

/datum/gas_reaction/fusion/react(datum/gas_mixture/air, atom/holder)
	var/temperature = air.temperature
	if(!fusion_mixture_ready(air, temperature))
		return NO_REACTION
	var/old_heat_capacity = air.heat_capacity()
	var/plasma_moles = air.gases[/datum/gas/plasma][MOLES]
	var/oxygen_moles = air.gases[/datum/gas/oxygen][MOLES]

	var/energy_released = 0
	var/burned_fuel = 0

	// Resolve location for hotspot/radiation (holder can be turf or pipeline)
	var/turf/open/location
	if(istype(holder, /datum/pipeline))
		var/datum/pipeline/pipenet = holder
		location = pick(pipenet.members)
	else if(isturf(holder))
		location = holder

	// Quark-gluon plasma transition: at extreme temperatures, all matter deconfines into quark matter
	if(temperature >= FUSION_QUARK_MATTER_THRESHOLD)
		var/total_moles = air.total_moles()
		air.gases.Cut()
		air.assert_gas(/datum/gas/quark_matter)
		air.gases[/datum/gas/quark_matter][MOLES] = total_moles
		SET_REACTION_RESULTS(total_moles)
		energy_released = -500000000
		radiation_pulse(location || holder, max_range = 25, threshold = 0.05, chance = 100)
		for(var/i in 1 to 8)
			(location || holder).fire_nuclear_particle()
		. |= REACTING | VOLATILE_REACTION
	else
		// Heat-based reaction levels: level 1 at 100k K, scaling up to level 10 at 127k K
		var/reaction_level = clamp(floor((temperature - FUSION_MINIMUM_TEMPERATURE) / FUSION_LEVEL_TEMP_STEP) + 1, 1, 10)

		// Fuel burn rate increases with level - level 10 burns ~3.25x faster than level 1
		var/level_burn_multiplier = 1 + (reaction_level - 1) * 0.25
		var/fuel_burn_rate = (plasma_moles * level_burn_multiplier) / FUSION_BASE_BURN_RATE_DIVISOR
		burned_fuel = min(fuel_burn_rate, oxygen_moles, plasma_moles)

		if(burned_fuel > 0)
			air.gases[/datum/gas/plasma][MOLES] -= burned_fuel
			air.gases[/datum/gas/oxygen][MOLES] -= burned_fuel
			air.assert_gas(/datum/gas/carbon_dioxide)
			air.gases[/datum/gas/carbon_dioxide][MOLES] += burned_fuel

			// Heat released replaces plasma burn and scales with level - level 1 = same as plasma, level 10 = 10x
			energy_released = burned_fuel * FIRE_PLASMA_ENERGY_RELEASED * (reaction_level + 1)
			SET_REACTION_RESULTS(burned_fuel)
			. |= REACTING

			// Radiation and nuclear particles scale with level
			var/rad_range = clamp(reaction_level * 4, 2, GAS_REACTION_MAXIMUM_RADIATION_PULSE_RANGE)
			var/rad_chance = clamp(15 + reaction_level * 6, 20, 85)
			radiation_pulse(location || holder, max_range = rad_range, threshold = 0.4 - reaction_level * 0.02, chance = rad_chance)

			if(prob(reaction_level * 2))
				var/nuclear_particle_count = clamp(floor(reaction_level / 2), 0, 3)
				for(var/i in 1 to nuclear_particle_count)
					(location || holder).fire_nuclear_particle()

	if(. & REACTING)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = (temperature * old_heat_capacity + energy_released) / new_heat_capacity

	if(istype(location))
		var/final_temp = air.temperature
		if(final_temp > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
			location.hotspot_expose(final_temp, CELL_VOLUME)

	return .

// When fusion actually runs, plasma burn is replaced by fusion - suppress plasmafire only then (avoids dead air between 80k and uncatalyzed fusion)
/datum/gas_reaction/plasmafire/react(datum/gas_mixture/air, datum/holder)
	if(air.temperature >= FUSION_MINIMUM_TEMPERATURE && fusion_mixture_ready(air, air.temperature))
		return NO_REACTION
	return ..()
