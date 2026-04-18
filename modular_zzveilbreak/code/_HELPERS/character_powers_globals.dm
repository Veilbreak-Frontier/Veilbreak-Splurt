/// Prototype instances keyed by power typepath (see preference middleware / TGUI).
GLOBAL_LIST_INIT_TYPED(power_datum_instances, /datum/power, init_power_prototypes())

GLOBAL_LIST_INIT(all_powers, init_all_powers())

/proc/init_power_prototypes()
	var/list/power_list = list()
	for(var/datum/power/power_type as anything in typesof(/datum/power))
		if(!initial(power_type.name))
			continue
		if(!initial(power_type.is_accessible))
			continue
		power_list[power_type] = new power_type()
	return power_list

/proc/init_all_powers()
	var/list/powers_list = list()
	for(var/datum/power/power_type as anything in typesof(/datum/power))
		if(!initial(power_type.name))
			continue
		if(!initial(power_type.is_accessible))
			continue
		powers_list += power_type
	return powers_list
