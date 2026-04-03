// Veilbreak: voidshard cargo import (supply pack) and export bounties.

/datum/supply_pack/imports/voidshard
	name = "Voidshard Crate"
	desc = "One voidshard delivered in a standard crate. No departmental requisition required—just credits."
	cost = 25000
	contains = list(/obj/item/voidshard = 1)
	crate_name = "voidshard crate"

/datum/export/veilbreak_voidshard
	cost = 15000
	unit_name = "voidshard"
	export_types = list(/obj/item/voidshard)
