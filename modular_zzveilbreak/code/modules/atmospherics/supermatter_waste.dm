/obj/machinery/power/supermatter_crystal/proc/produce_waste()

    waste_multiplier_factors = calculate_waste_multiplier()
    var/device_energy = internal_energy * REACTION_POWER_MODIFIER
    var/turf/local_turf = loc
    #define UNIQUE_RELEASE_MODIFIER 1400
    if(!istype(local_turf))
        return

    var/datum/gas_mixture/env = local_turf.return_air()
    var/datum/gas_mixture/merged_gasmix = absorbed_gasmix.copy()

    var/max_gas
    var/max_percentage = 0
    for (var/gas_path in gas_percentage)
        if (gas_percentage[gas_path] > max_percentage)
            max_percentage = gas_percentage[gas_path]
            max_gas = gas_path

    merged_gasmix.temperature += device_energy * waste_multiplier / THERMAL_RELEASE_MODIFIER
    merged_gasmix.temperature = clamp(merged_gasmix.temperature, TCMB, 2500 * waste_multiplier)

    var/primary_production = max(device_energy * waste_multiplier / OXYGEN_RELEASE_MODIFIER, 0)
    var/secondary_production = max(device_energy * waste_multiplier / PLASMA_RELEASE_MODIFIER, 0)
    var/tetriary_production = max(device_energy * waste_multiplier / UNIQUE_RELEASE_MODIFIER, 0)

    switch(max_gas)
        // --- BASE GASES ---

        if(/datum/gas/oxygen)
            merged_gasmix.assert_gases(/datum/gas/nitrogen)
            merged_gasmix.gases[/datum/gas/nitrogen][MOLES] += tetriary_production

        if(/datum/gas/nitrogen)
            merged_gasmix.assert_gases(/datum/gas/healium)
            merged_gasmix.gases[/datum/gas/healium][MOLES] += tetriary_production

        if(/datum/gas/plasma)
            merged_gasmix.assert_gases(/datum/gas/hypernoblium)
            merged_gasmix.gases[/datum/gas/hypernoblium][MOLES] += tetriary_production

        if(/datum/gas/carbon_dioxide)
            merged_gasmix.assert_gases(/datum/gas/tritium)
            merged_gasmix.gases[/datum/gas/tritium][MOLES] += tetriary_production

        if(/datum/gas/water_vapor)
            merged_gasmix.assert_gases(/datum/gas/nitrium)
            merged_gasmix.gases[/datum/gas/nitrium][MOLES] += tetriary_production


        if(/datum/gas/hypernoblium)
            merged_gasmix.assert_gases(/datum/gas/zauker)
            merged_gasmix.gases[/datum/gas/zauker][MOLES] += tetriary_production

        if(/datum/gas/nitrous_oxide)
            merged_gasmix.assert_gases(/datum/gas/halon)
            merged_gasmix.gases[/datum/gas/halon][MOLES] += tetriary_production

        if(/datum/gas/tritium)
            merged_gasmix.assert_gases(/datum/gas/proto_nitrate)
            merged_gasmix.gases[/datum/gas/proto_nitrate][MOLES] += tetriary_production

        if(/datum/gas/bz)
            merged_gasmix.assert_gases(/datum/gas/nitrogen)
            merged_gasmix.gases[/datum/gas/nitrogen][MOLES] += tetriary_production

        if(/datum/gas/pluoxium)
            merged_gasmix.assert_gases(/datum/gas/zauker)
            merged_gasmix.gases[/datum/gas/zauker][MOLES] += tetriary_production

        if(/datum/gas/freon)
            merged_gasmix.assert_gases(/datum/gas/pluoxium)
            merged_gasmix.gases[/datum/gas/pluoxium][MOLES] += tetriary_production

        if(/datum/gas/miasma)
            merged_gasmix.assert_gases(/datum/gas/hydrogen)
            merged_gasmix.gases[/datum/gas/hydrogen][MOLES] += tetriary_production

        if(/datum/gas/hydrogen)
            merged_gasmix.assert_gases(/datum/gas/water_vapor)
            merged_gasmix.gases[/datum/gas/water_vapor][MOLES] += tetriary_production

        if(/datum/gas/healium)
            merged_gasmix.assert_gases(/datum/gas/nitrous_oxide)
            merged_gasmix.gases[/datum/gas/nitrous_oxide][MOLES] += tetriary_production

        if(/datum/gas/proto_nitrate)
            merged_gasmix.assert_gases(/datum/gas/freon)
            merged_gasmix.gases[/datum/gas/freon][MOLES] += tetriary_production

        if(/datum/gas/zauker)
            merged_gasmix.assert_gases(/datum/gas/hypernoblium)
            merged_gasmix.gases[/datum/gas/hypernoblium][MOLES] += tetriary_production

        if(/datum/gas/halon)
            merged_gasmix.assert_gases(/datum/gas/tritium)
            merged_gasmix.gases[/datum/gas/tritium][MOLES] += tetriary_production

        if(/datum/gas/nitrium)
            merged_gasmix.assert_gases(/datum/gas/freon)
            merged_gasmix.gases[/datum/gas/freon][MOLES] += tetriary_production

        if(/datum/gas/antinoblium)
            merged_gasmix.assert_gases(/datum/gas/hypernoblium)
            merged_gasmix.gases[/datum/gas/hypernoblium][MOLES] += tetriary_production

        if(/datum/gas/delirium)
            merged_gasmix.assert_gases(/datum/gas/hypernoblium)
            merged_gasmix.gases[/datum/gas/hypernoblium][MOLES] += tetriary_production

        else

    merged_gasmix.assert_gases(/datum/gas/plasma, /datum/gas/oxygen)
    merged_gasmix.gases[/datum/gas/plasma][MOLES] += secondary_production
    merged_gasmix.gases[/datum/gas/oxygen][MOLES] += primary_production

    merged_gasmix.garbage_collect()
    env.merge(merged_gasmix)
    air_update_turf(FALSE, FALSE)
