// Placeholder for quark matter gas
/datum/gas/quark_matter
	id = "quark_matter"
	name = "Quark-Gluon Plasma"
	specific_heat = 10
	fusion_power = 1
	rarity = 1
	desc = "A state of matter where quarks and gluons are deconfined. It is extremely unstable under normal conditions."
	primary_color = "#ff00ff"
	gas_overlay = "freon_old" // Placeholder, maybe a new overlay is needed
	moles_visible = MOLES_GAS_VISIBLE

#define SET_REACTION_RESULTS(amount) air.reaction_results[type] = amount
#define QUARK_DECAY_MOLE_THRESHOLD 5
#define QUARK_DECAY_COOLDOWN_DS 10 // deciseconds = 1 second
#define QUARK_DECAY_SCIENCE_PER_MOLE 0.01 // science points granted per mole of quark matter decayed

/datum/gas_reaction/quark_matter_decay
	name = "Quark Matter Decay"
	id = "quark_matter_decay"
	priority_group = PRIORITY_PRE_FORMATION
	var/static/list/last_decay_times = list()

/datum/gas_reaction/quark_matter_decay/init_reqs()
	requirements = list(
		/datum/gas/quark_matter = MINIMUM_MOLE_COUNT
	)

/datum/gas_reaction/quark_matter_decay/react(datum/gas_mixture/air, atom/holder)
	var/moles = air.gases[/datum/gas/quark_matter][MOLES]
	if(moles < MINIMUM_MOLE_COUNT)
		return NO_REACTION

	var/last = last_decay_times[air]
	if(last && (world.time - last) < QUARK_DECAY_COOLDOWN_DS)
		return NO_REACTION

	last_decay_times[air] = world.time
	// Cleanup old entries to avoid unbounded growth (drop entries older than 30 seconds)
	if(length(last_decay_times) > 500)
		var/list/to_remove = list()
		for(var/datum/gas_mixture/key in last_decay_times)
			if(world.time - last_decay_times[key] > 300)
				to_remove += key
		for(var/key in to_remove)
			last_decay_times -= key

	var/removed
	if(moles < QUARK_DECAY_MOLE_THRESHOLD)
		removed = moles
		air.gases[/datum/gas/quark_matter][MOLES] = 0
		air.garbage_collect(list(/datum/gas/quark_matter))
	else
		removed = moles * 0.5
		air.gases[/datum/gas/quark_matter][MOLES] -= removed

	// Grant science points per mole while quark matter is active and decaying
	if(removed > 0)
		var/datum/techweb/station_web = locate(/datum/techweb/science) in SSresearch.techwebs
		if(station_web)
			station_web.add_point_list(list(TECHWEB_POINT_TYPE_GENERIC = FLOOR(removed * QUARK_DECAY_SCIENCE_PER_MOLE, 0.1)))

	SET_REACTION_RESULTS(removed)
	return REACTING

