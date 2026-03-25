#define SET_REACTION_RESULTS(amount) air.reaction_results[type] = amount

/// Temperature (kelvin) at which delirium forces a breakdown to gas "recipe" products.
#define DELIRIUM_BREAKDOWN_MIN_TEMP 300000

/datum/gas_reaction/delirium_breakdown
	name = "Delirium High-Temp Breakdown"
	id = "delirium_high_temp_breakdown"
	priority_group = PRIORITY_PRE_FORMATION
	desc = "At extreme temperatures, delirium breaks certain gases down to their formation recipe."

/datum/gas_reaction/delirium_breakdown/init_reqs()
	requirements = list(
		/datum/gas/delirium = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = DELIRIUM_BREAKDOWN_MIN_TEMP,
	)

/datum/gas_reaction/delirium_breakdown/react(datum/gas_mixture/air, datum/holder)
	. = NO_REACTION

	var/list/cached_gases = air.gases
	var/total_moles_converted = 0
	var/energy_delta = 0 // Positive = exothermic (heats up), Negative = endothermic (cools down).

	// Snapshot before any moles are changed; we'll compute the final temperature once.
	var/temperature = air.temperature
	var/old_heat_capacity = air.heat_capacity()

	/*
	 * Reverse all veilbreak gas "formation" recipes.
	 *
	 * We do it in a dependency order so intermediate gases produced by earlier
	 * breakdown steps are themselves breakdown-able in the same tick.
	 */

	// Healium -> BZ + Freon
	var/list/healium = cached_gases[/datum/gas/healium]
	if(healium && healium[MOLES] > 0)
		var/healium_moles = healium[MOLES]
		var/healium_units = healium_moles / 3 // healium_formation makes 3 healium per "unit"

		healium[MOLES] = 0
		air.assert_gas(/datum/gas/bz)
		air.assert_gas(/datum/gas/freon)

		// Reverse stoichiometry of healium_formation:
		// healium_formation: 3 healium <= 0.25 BZ + 2.75 freon (plus energy).
		cached_gases[/datum/gas/bz][MOLES] += healium_units * 0.25
		cached_gases[/datum/gas/freon][MOLES] += healium_units * 2.75

		total_moles_converted += healium_moles
		// healium_formation is exothermic => the reverse is endothermic.
		energy_delta -= healium_units * HEALIUM_FORMATION_ENERGY

	// Zauker -> Nitrium + Hyper-Noblium
	var/list/zauker = cached_gases[/datum/gas/zauker]
	if(zauker && zauker[MOLES] > 0)
		var/zauker_moles = zauker[MOLES]

		zauker[MOLES] = 0
		air.assert_gas(/datum/gas/nitrium)
		air.assert_gas(/datum/gas/hypernoblium)

		// zauker_formation: zauker = heat_efficiency * 0.5
		// -> heat_efficiency = 2 * zauker
		// hypernoblium consumed = heat_efficiency * 0.01 = 0.02 * zauker
		// nitrium consumed = heat_efficiency * 0.5 = 1.0 * zauker
		cached_gases[/datum/gas/hypernoblium][MOLES] += zauker_moles * 0.02
		cached_gases[/datum/gas/nitrium][MOLES] += zauker_moles

		total_moles_converted += zauker_moles
		// zauker_formation is exothermic => the reverse is endothermic.
		energy_delta -= (2 * zauker_moles) * ZAUKER_FORMATION_ENERGY

	// Proto-Nitrate -> Pluoxium + Hydrogen
	var/list/proto_nitrate = cached_gases[/datum/gas/proto_nitrate]
	if(proto_nitrate && proto_nitrate[MOLES] > 0)
		var/proto_nitrate_moles = proto_nitrate[MOLES]

		proto_nitrate[MOLES] = 0
		air.assert_gas(/datum/gas/pluoxium)
		air.assert_gas(/datum/gas/hydrogen)

		// proto_nitrate_formation: proto_nitrate = heat_efficiency * 2.2
		// -> heat_efficiency = proto_nitrate / 2.2 = proto_nitrate * 5 / 11
		// pluoxium consumed = heat_efficiency * 0.2 = proto_nitrate / 11
		// hydrogen consumed = heat_efficiency * 2 = proto_nitrate * 10 / 11
		cached_gases[/datum/gas/pluoxium][MOLES] += proto_nitrate_moles / 11
		cached_gases[/datum/gas/hydrogen][MOLES] += proto_nitrate_moles * 10 / 11

		total_moles_converted += proto_nitrate_moles
		// proto_nitrate_formation is exothermic => the reverse is endothermic.
		energy_delta -= proto_nitrate_moles * 5 * PN_FORMATION_ENERGY / 11

	// Pluoxium -> CO2 + Oxygen + Tritium
	var/list/pluoxium = cached_gases[/datum/gas/pluoxium]
	if(pluoxium && pluoxium[MOLES] > 0)
		var/pluoxium_moles = pluoxium[MOLES]

		pluoxium[MOLES] = 0
		air.assert_gas(/datum/gas/carbon_dioxide)
		air.assert_gas(/datum/gas/oxygen)
		air.assert_gas(/datum/gas/tritium)

		// pluox_formation:
		// - CO2 consumed: 1.0 per pluoxium
		// - O2 consumed: 0.5 per pluoxium
		// - tritium consumed: 0.01 per pluoxium
		cached_gases[/datum/gas/carbon_dioxide][MOLES] += pluoxium_moles
		cached_gases[/datum/gas/oxygen][MOLES] += pluoxium_moles * 0.5
		cached_gases[/datum/gas/tritium][MOLES] += pluoxium_moles * 0.01

		total_moles_converted += pluoxium_moles
		// pluox_formation is exothermic => the reverse is endothermic.
		energy_delta -= pluoxium_moles * PLUOXIUM_FORMATION_ENERGY

	// Hyper-Noblium -> Nitrogen + Tritium
	var/list/hypernoblium = cached_gases[/datum/gas/hypernoblium]
	if(hypernoblium && hypernoblium[MOLES] > 0)
		var/hypernoblium_moles = hypernoblium[MOLES]

		// Compute catalyst-dependent factors before we add new tritium.
		var/list/bz_for_nob = cached_gases[/datum/gas/bz]
		var/list/tritium_for_nob = cached_gases[/datum/gas/tritium]
		var/bz_moles_for_nob = bz_for_nob ? bz_for_nob[MOLES] : 0
		var/tritium_moles_for_nob = tritium_for_nob ? tritium_for_nob[MOLES] : 0
		var/denom = tritium_moles_for_nob + bz_moles_for_nob
		var/reduction_factor = denom > 0 ? clamp(tritium_moles_for_nob / denom, 0.001, 1) : 1

		hypernoblium[MOLES] = 0
		air.assert_gas(/datum/gas/nitrogen)
		air.assert_gas(/datum/gas/tritium)

		// nobliumformation:
		// - nitrogen consumed: 10 * nob_formed
		// - tritium consumed: 5 * nob_formed * reduction_factor
		cached_gases[/datum/gas/nitrogen][MOLES] += hypernoblium_moles * 10
		cached_gases[/datum/gas/tritium][MOLES] += hypernoblium_moles * 5 * reduction_factor

		total_moles_converted += hypernoblium_moles
		// nobliumformation is extremely exothermic => the reverse is endothermic.
		var/energy_released = hypernoblium_moles * NOBLIUM_FORMATION_ENERGY / max(bz_moles_for_nob, 1)
		energy_delta -= energy_released

	// Nitrium -> Tritium + Nitrogen + BZ
	var/list/nitrium = cached_gases[/datum/gas/nitrium]
	if(nitrium && nitrium[MOLES] > 0)
		var/nitrium_moles = nitrium[MOLES]

		nitrium[MOLES] = 0
		air.assert_gas(/datum/gas/tritium)
		air.assert_gas(/datum/gas/nitrogen)
		air.assert_gas(/datum/gas/bz)

		// nitrium_formation:
		// nitrium = heat_efficiency
		// -> tritium consumed = heat_efficiency
		// -> nitrogen consumed = heat_efficiency
		// -> bz consumed = heat_efficiency * 0.05
		cached_gases[/datum/gas/tritium][MOLES] += nitrium_moles
		cached_gases[/datum/gas/nitrogen][MOLES] += nitrium_moles
		cached_gases[/datum/gas/bz][MOLES] += nitrium_moles * 0.05

		total_moles_converted += nitrium_moles
		// nitrium_formation is endothermic => the reverse is exothermic.
		energy_delta += nitrium_moles * NITRIUM_FORMATION_ENERGY

	// Freon -> Plasma + CO2 + BZ
	var/list/freon = cached_gases[/datum/gas/freon]
	if(freon && freon[MOLES] > 0)
		var/freon_moles = freon[MOLES]

		freon[MOLES] = 0
		air.assert_gas(/datum/gas/plasma)
		air.assert_gas(/datum/gas/carbon_dioxide)
		air.assert_gas(/datum/gas/bz)

		// freonformation:
		// plasma consumed: 0.6 per freon
		// CO2 consumed: 0.3 per freon
		// BZ consumed: 0.1 per freon
		cached_gases[/datum/gas/plasma][MOLES] += freon_moles * 0.6
		cached_gases[/datum/gas/carbon_dioxide][MOLES] += freon_moles * 0.3
		cached_gases[/datum/gas/bz][MOLES] += freon_moles * 0.1

		total_moles_converted += freon_moles
		// freonformation is endothermic => the reverse is exothermic.
		var/energy_consumed = (7000 / (1 + NUM_E ** (-0.0015 * (temperature - 6000))) + 1000) * freon_moles * 0.1
		energy_delta += energy_consumed

	// BZ -> N2O + Plasma
	var/list/bz = cached_gases[/datum/gas/bz]
	if(bz && bz[MOLES] > 0)
		var/bz_moles = bz[MOLES]

		bz[MOLES] = 0
		air.assert_gas(/datum/gas/nitrous_oxide)
		air.assert_gas(/datum/gas/plasma)

		// bzformation (factor=0):
		// 1 BZ consumes 0.4 N2O and 0.8 plasma.
		cached_gases[/datum/gas/nitrous_oxide][MOLES] += bz_moles * 0.4
		cached_gases[/datum/gas/plasma][MOLES] += bz_moles * 0.8

		total_moles_converted += bz_moles
		// bzformation is exothermic => the reverse is endothermic.
		energy_delta -= bz_moles * BZ_FORMATION_ENERGY

	// N2O -> N2 + O
	var/list/nitrous_oxide = cached_gases[/datum/gas/nitrous_oxide]
	if(nitrous_oxide && nitrous_oxide[MOLES] > 0)
		var/n2o_moles = nitrous_oxide[MOLES]

		nitrous_oxide[MOLES] = 0
		air.assert_gas(/datum/gas/nitrogen)
		air.assert_gas(/datum/gas/oxygen)

		// nitrousformation consumes:
		// - 1 nitrogen per N2O
		// - 0.5 oxygen per N2O (O2 has 2 oxygen atoms)
		cached_gases[/datum/gas/nitrogen][MOLES] += n2o_moles
		cached_gases[/datum/gas/oxygen][MOLES] += n2o_moles * 0.5

		total_moles_converted += n2o_moles
		// nitrousformation is endothermic => the reverse is exothermic.
		energy_delta += n2o_moles * N2O_FORMATION_ENERGY

	if(total_moles_converted <= 0)
		return NO_REACTION

	// Apply temperature delta once, after all conversions.
	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = max(((temperature * old_heat_capacity + energy_delta) / new_heat_capacity), TCMB)

	SET_REACTION_RESULTS(total_moles_converted)
	. |= REACTING
	return .
