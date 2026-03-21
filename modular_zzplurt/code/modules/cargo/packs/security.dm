
/datum/supply_pack/security/armory/sec_glock_ammo_fancy
	name = "'Murphy' Service Pistol Specialized Ammo Crate"
	desc = "Contains 5 magazines with various types of rounds for the 'Murphy' service pistol."
	cost = CARGO_CRATE_VALUE * 6
	contains = list(
		/obj/item/ammo_box/magazine/security/true_strike = 1,
		/obj/item/ammo_box/magazine/security/dumdum = 1,
		/obj/item/ammo_box/magazine/security/hotshot = 1,
		/obj/item/ammo_box/magazine/security/iceblox = 1,
		/obj/item/ammo_box/magazine/security/flare = 1,
	)
	crate_name = "'Murphy' service pistol specialized ammo crate"
	access_view = ACCESS_WEAPONS
  
/datum/supply_pack/security/armory/mps5
	name = "Security Submachine Gun Crate"
	desc = "The best thing you can buy for when you love automatics. \
		Contains three MP-S5 VIG's."
	cost = CARGO_CRATE_VALUE * 23
	contains = list(/obj/item/gun/ballistic/automatic/mps5 = 3,
					/obj/item/ammo_box/magazine/mps5 = 6)
	crate_name = "submachine guns crate"
