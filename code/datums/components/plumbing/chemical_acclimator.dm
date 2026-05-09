/datum/component/plumbing/acclimator
	demand_connects = WEST
	supply_connects = EAST
	var/obj/machinery/plumbing/acclimator/myacclimator

/datum/component/plumbing/acclimator/Initialize(ducting_layer)
	if(!istype(parent, /obj/machinery/plumbing/acclimator))
		return COMPONENT_INCOMPATIBLE
	return ..()

/datum/component/plumbing/acclimator/can_give(amount, reagent)
	var/obj/machinery/plumbing/acclimator/myacclimator = parent

	return myacclimator.emptying && ..()

///We're overriding process and not send_request, because all process does is do the requests, so we might aswell cut out the middle man and save some code from running
/datum/component/plumbing/acclimator/process()
	var/obj/machinery/plumbing/acclimator/myacclimator = parent
	if(!myacclimator.emptying)
		..()

// VEILBREAK/SPLURT fork sync: procs present in fork but missing from upstream (auto-restored)
/datum/component/plumbing/acclimator/Initialize(start=TRUE, _ducting_layer, _turn_connects=TRUE, datum/reagents/custom_receiver)
	. = ..()
	if(!istype(parent, /obj/machinery/plumbing/acclimator))
		return COMPONENT_INCOMPATIBLE
	myacclimator = parent

/datum/component/plumbing/acclimator/Destroy(force)
	myacclimator = null
	return ..()
