/// Magazine and SMG types referenced by Zubbers gun cases (paths were never defined in modular_zubbers).

/obj/item/ammo_box/magazine/recharge/ntusp
	name = "NT22-HCS magazine"
	desc = "A rechargeable battery magazine for .22HL hardlight rounds."
	ammo_type = /obj/item/ammo_casing/caseless/c22hl
	caliber = ENERGY
	max_ammo = 15

/obj/item/ammo_box/magazine/recharge/ntusp/laser
	ammo_type = /obj/item/ammo_casing/caseless/c22ls
	caliber = LASER

/obj/item/ammo_box/magazine/recharge/ntusp/empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/recharge/ntusp/laser/empty
	start_empty = TRUE

/obj/item/gun/ballistic/automatic/ntmp5
	name = "\improper NT22-HCS-MP 'Lancer'"
	desc = "A compact automatic weapon feeding proprietary hardlight magazines."
	icon = 'modular_zubbers/icons/obj/weapons/guns/ballistic.dmi'
	icon_state = "ntmp5"
	base_icon_state = "ntmp5"
	w_class = WEIGHT_CLASS_NORMAL
	accepted_magazine_type = /obj/item/ammo_box/magazine/recharge/ntmp5
	burst_size = 3
	fire_delay = 2
	can_suppress = TRUE
	mag_display = TRUE

/obj/item/ammo_box/magazine/recharge/ntmp5
	name = "NT22-HCS-MP magazine"
	ammo_type = /obj/item/ammo_casing/caseless/c22hl
	caliber = ENERGY
	max_ammo = 30

/obj/item/ammo_box/magazine/recharge/ntmp5/laser
	ammo_type = /obj/item/ammo_casing/caseless/c22ls
	caliber = LASER
