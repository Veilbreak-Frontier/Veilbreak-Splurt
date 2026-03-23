#define TOTAL_MOLES_SPECIFIC(cached_gases, gas_id, out_var)\
	out_var = 0;\
	for(var/total_moles_id in cached_gases){\
		if(total_moles_id == gas_id){\
			out_var += cached_gases[total_moles_id][MOLES];\
		}\
	}

///The shared bluespace network for all senders and vendors.
var/global/datum/gas_mixture/bluespace_shared_network

/**
 * Returns the shared bluespace gas network, creating it if it doesn't exist.
 */
/proc/get_shared_bluespace_network()
	if(!bluespace_shared_network)
		bluespace_shared_network = new()
		for(var/gas_id in GLOB.meta_gas_info)
			bluespace_shared_network.assert_gas(gas_id)
	return bluespace_shared_network

/obj/item/circuitboard/machine/bluespace_sender
	name = "Bluespace Sender (Machine Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/atmospherics/components/unary/bluespace_sender
	req_components = list(
		/obj/item/stack/cable_coil = 10,
		/obj/item/stack/sheet/glass = 10,
		/obj/item/stack/sheet/plasteel = 5)


/datum/crafting_recipe/bluespace_vendor_mount
	name = "Bluespace Vendor Wall Mount"
	result = /obj/item/wallframe/bluespace_vendor_mount
	time = 6 SECONDS
	reqs = list(/obj/item/stack/sheet/iron = 15,
				/obj/item/stack/sheet/glass = 10,
				/obj/item/stack/cable_coil = 10,
				)
	category = CAT_MISC


