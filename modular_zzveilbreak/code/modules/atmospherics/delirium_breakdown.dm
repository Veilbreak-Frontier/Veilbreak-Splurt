#define SET_REACTION_RESULTS(amount) air.reaction_results[type] = amount

/// Temperature (kelvin) at which delirium forces a breakdown to gas "recipe" products.
#define DELIRIUM_BREAKDOWN_MIN_TEMP 30

/datum/gas_reaction/delirium_breakdown
	name = "Delirium Breakdown"
	id = "delirium_breakdown"
	priority_group = PRIORITY_PRE_FORMATION
	desc = "As it was in the beginning, the Void makes it so again. "

/datum/gas_reaction/delirium_breakdown/init_reqs()
	requirements = list(
		/datum/gas/delirium = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = DELIRIUM_BREAKDOWN_MIN_TEMP,
	)

/datum/gas_reaction/delirium_breakdown/react(datum/gas_mixture/air, datum/holder)
	. = NO_REACTION

	var/list/cached_moles = air.moles
	var/total_moles_converted = 0
	var/energy_delta = 0 // Positive = exothermic (heats up), Negative = endothermic (cools down).

	// Snapshot before any moles are changed; we'll compute the final temperature once.
	var/temperature = air.temperature
	var/old_heat_capacity = air.heat_capacity()

	var/delirium_moles = cached_moles[/datum/gas/delirium]
	var/moles_available_to_process = delirium_moles * 0.4

	if (moles_available_to_process <= 0)
		return NO_REACTION

	/*
	 * Reverse all veilbreak gas "formation" recipes.
	 *
	 * We do it in a dependency order so intermediate gases produced by earlier
	 * breakdown steps are themselves breakdown-able in the same tick.
	 */

	// Healium -> BZ + Freon
	var/healium_moles = cached_moles[/datum/gas/healium]
	if(healium_moles > 0 && moles_available_to_process > 0)
		var/moles_to_process = min(healium_moles, moles_available_to_process)
		var/healium_units = moles_to_process / 3 // healium_formation makes 3 healium per "unit"

		cached_moles[/datum/gas/healium] -= moles_to_process
		air.assert_gas(/datum/gas/bz)
		air.assert_gas(/datum/gas/freon)

		// Reverse stoichiometry of healium_formation:
		// healium_formation: 3 healium <= 0.25 BZ + 2.75 freon (plus energy).
		cached_moles[/datum/gas/bz] += healium_units * 0.25
		cached_moles[/datum/gas/freon] += healium_units * 2.75

		total_moles_converted += moles_to_process
		moles_available_to_process -= moles_to_process
		// healium_formation is exothermic => the reverse is endothermic.
		energy_delta -= healium_units * HEALIUM_FORMATION_ENERGY

	// Zauker -> Nitrium + Hyper-Noblium
	var/zauker_moles = cached_moles[/datum/gas/zauker]
	if(zauker_moles > 0 && moles_available_to_process > 0)
		var/moles_to_process = min(zauker_moles, moles_available_to_process)

		cached_moles[/datum/gas/zauker] -= moles_to_process
		air.assert_gas(/datum/gas/nitrium)
		air.assert_gas(/datum/gas/hypernoblium)

		// zauker_formation: zauker = heat_efficiency * 0.5
		// -> heat_efficiency = 2 * zauker
		// hypernoblium consumed = heat_efficiency * 0.01 = 0.02 * zauker
		// nitrium consumed = heat_efficiency * 0.5 = 1.0 * zauker
		cached_moles[/datum/gas/hypernoblium] += moles_to_process * 0.02
		cached_moles[/datum/gas/nitrium] += moles_to_process

		total_moles_converted += moles_to_process
		moles_available_to_process -= moles_to_process
		// zauker_formation is exothermic => the reverse is endothermic.
		energy_delta -= (2 * moles_to_process) * ZAUKER_FORMATION_ENERGY

	// Proto-Nitrate -> Pluoxium + Hydrogen
	var/proto_nitrate_moles = cached_moles[/datum/gas/proto_nitrate]
	if(proto_nitrate_moles > 0 && moles_available_to_process > 0)
		var/moles_to_process = min(proto_nitrate_moles, moles_available_to_process)

		cached_moles[/datum/gas/proto_nitrate] -= moles_to_process
		air.assert_gas(/datum/gas/pluoxium)
		air.assert_gas(/datum/gas/hydrogen)

		// proto_nitrate_formation: proto_nitrate = heat_efficiency * 2.2
		// -> heat_efficiency = proto_nitrate / 2.2 = proto_nitrate * 5 / 11
		// pluoxium consumed = heat_efficiency * 0.2 = proto_nitrate / 11
		// hydrogen consumed = heat_efficiency * 2 = proto_nitrate * 10 / 11
		cached_moles[/datum/gas/pluoxium] += moles_to_process / 11
		cached_moles[/datum/gas/hydrogen] += moles_to_process * 10 / 11

		total_moles_converted += moles_to_process
		moles_available_to_process -= moles_to_process
		// proto_nitrate_formation is exothermic => the reverse is endothermic.
		energy_delta -= moles_to_process * 5 * PN_FORMATION_ENERGY / 11

	// Pluoxium -> CO2 + Oxygen + Tritium
	var/pluoxium_moles = cached_moles[/datum/gas/pluoxium]
	if(pluoxium_moles > 0 && moles_available_to_process > 0)
		var/moles_to_process = min(pluoxium_moles, moles_available_to_process)

		cached_moles[/datum/gas/pluoxium] -= moles_to_process
		air.assert_gas(/datum/gas/carbon_dioxide)
		air.assert_gas(/datum/gas/oxygen)
		air.assert_gas(/datum/gas/tritium)

		// pluox_formation:
		// - CO2 consumed: 1.0 per pluoxium
		// - O2 consumed: 0.5 per pluoxium
		// - tritium consumed: 0.01 per pluoxium
		cached_moles[/datum/gas/carbon_dioxide] += moles_to_process
		cached_moles[/datum/gas/oxygen] += moles_to_process * 0.5
		cached_moles[/datum/gas/tritium] += moles_to_process * 0.01

		total_moles_converted += moles_to_process
		moles_available_to_process -= moles_to_process
		// pluox_formation is exothermic => the reverse is endothermic.
		energy_delta -= moles_to_process * PLUOXIUM_FORMATION_ENERGY

	// Hyper-Noblium -> Nitrogen + Tritium
	var/hypernoblium_moles = cached_moles[/datum/gas/hypernoblium]
	if(hypernoblium_moles > 0 && moles_available_to_process > 0)
		var/moles_to_process = min(hypernoblium_moles, moles_available_to_process)

		// Compute catalyst-dependent factors before we add new tritium.
		var/bz_moles_for_nob = cached_moles[/datum/gas/bz] || 0
		var/tritium_moles_for_nob = cached_moles[/datum/gas/tritium] || 0
		var/denom = tritium_moles_for_nob + bz_moles_for_nob
		var/reduction_factor = denom > 0 ? clamp(tritium_moles_for_nob / denom, 0.001, 1) : 1

		cached_moles[/datum/gas/hypernoblium] -= moles_to_process
		air.assert_gas(/datum/gas/nitrogen)
		air.assert_gas(/datum/gas/tritium)

		// nobliumformation:
		// - nitrogen consumed: 10 * nob_formed
		// - tritium consumed: 5 * nob_formed * reduction_factor
		cached_moles[/datum/gas/nitrogen] += moles_to_process * 10
		cached_moles[/datum/gas/tritium] += moles_to_process * 5 * reduction_factor

		total_moles_converted += moles_to_process
		moles_available_to_process -= moles_to_process
		// nobliumformation is extremely exothermic => the reverse is endothermic.
		var/energy_released = moles_to_process * NOBLIUM_FORMATION_ENERGY / max(bz_moles_for_nob, 1)
		energy_delta -= energy_released

	// Nitrium -> Tritium + Nitrogen + BZ
	var/nitrium_moles = cached_moles[/datum/gas/nitrium]
	if(nitrium_moles > 0 && moles_available_to_process > 0)
		var/moles_to_process = min(nitrium_moles, moles_available_to_process)

		cached_moles[/datum/gas/nitrium] -= moles_to_process
		air.assert_gas(/datum/gas/tritium)
		air.assert_gas(/datum/gas/nitrogen)
		air.assert_gas(/datum/gas/bz)

		// nitrium_formation:
		// nitrium = heat_efficiency
		// -> tritium consumed = heat_efficiency
		// -> nitrogen consumed = heat_efficiency
		// -> bz consumed = heat_efficiency * 0.05
		cached_moles[/datum/gas/tritium] += moles_to_process
		cached_moles[/datum/gas/nitrogen] += moles_to_process
		cached_moles[/datum/gas/bz] += moles_to_process * 0.05

		total_moles_converted += moles_to_process
		moles_available_to_process -= moles_to_process
		// nitrium_formation is endothermic => the reverse is exothermic.
		energy_delta += moles_to_process * NITRIUM_FORMATION_ENERGY

	// Freon -> Plasma + CO2 + BZ
	var/freon_moles = cached_moles[/datum/gas/freon]
	if(freon_moles > 0 && moles_available_to_process > 0)
		var/moles_to_process = min(freon_moles, moles_available_to_process)

		cached_moles[/datum/gas/freon] -= moles_to_process
		air.assert_gas(/datum/gas/plasma)
		air.assert_gas(/datum/gas/carbon_dioxide)
		air.assert_gas(/datum/gas/bz)

		// freonformation:
		// plasma consumed: 0.6 per freon
		// CO2 consumed: 0.3 per freon
		// BZ consumed: 0.1 per freon
		cached_moles[/datum/gas/plasma] += moles_to_process * 0.6
		cached_moles[/datum/gas/carbon_dioxide] += moles_to_process * 0.3
		cached_moles[/datum/gas/bz] += moles_to_process * 0.1

		total_moles_converted += moles_to_process
		moles_available_to_process -= moles_to_process
		// freonformation is endothermic => the reverse is exothermic.
		var/energy_consumed = (7000 / (1 + NUM_E ** (-0.0015 * (temperature - 6000))) + 1000) * moles_to_process * 0.1
		energy_delta += energy_consumed

	// BZ -> N2O + Plasma
	var/bz_moles = cached_moles[/datum/gas/bz]
	if(bz_moles > 0 && moles_available_to_process > 0)
		var/moles_to_process = min(bz_moles, moles_available_to_process)

		cached_moles[/datum/gas/bz] -= moles_to_process
		air.assert_gas(/datum/gas/nitrous_oxide)
		air.assert_gas(/datum/gas/plasma)

		// bzformation (factor=0):
		// 1 BZ consumes 0.4 N2O and 0.8 plasma.
		cached_moles[/datum/gas/nitrous_oxide] += moles_to_process * 0.4
		cached_moles[/datum/gas/plasma] += moles_to_process * 0.8

		total_moles_converted += moles_to_process
		moles_available_to_process -= moles_to_process
		// bzformation is exothermic => the reverse is endothermic.
		energy_delta -= moles_to_process * BZ_FORMATION_ENERGY

	// N2O -> N2 + O
	var/nitrous_oxide_moles = cached_moles[/datum/gas/nitrous_oxide]
	if(nitrous_oxide_moles > 0 && moles_available_to_process > 0)
		var/moles_to_process = min(nitrous_oxide_moles, moles_available_to_process)

		cached_moles[/datum/gas/nitrous_oxide] -= moles_to_process
		air.assert_gas(/datum/gas/nitrogen)
		air.assert_gas(/datum/gas/oxygen)

		// nitrousformation consumes:
		// - 1 nitrogen per N2O
		// - 0.5 oxygen per N2O (O2 has 2 oxygen atoms)
		cached_moles[/datum/gas/nitrogen] += moles_to_process
		cached_moles[/datum/gas/oxygen] += moles_to_process * 0.5

		total_moles_converted += moles_to_process
		moles_available_to_process -= moles_to_process
		// nitrousformation is endothermic => the reverse is exothermic.
		energy_delta += moles_to_process * N2O_FORMATION_ENERGY

	if(total_moles_converted <= 0)
		return NO_REACTION

	// Apply temperature delta once, after all conversions.
	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = max(((temperature * old_heat_capacity + energy_delta) / new_heat_capacity), TCMB)

	SET_REACTION_RESULTS(total_moles_converted)
	. |= REACTING
	return .
