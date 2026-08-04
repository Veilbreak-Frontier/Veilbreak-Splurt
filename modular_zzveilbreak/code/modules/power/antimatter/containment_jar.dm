/obj/item/am_containment
	name = "antimatter containment jar"
	desc = "Holds antimatter."
	icon = 'modular_zzveilbreak/icons/obj/machines/antimatter.dmi'
	icon_state = "jar"
	density = FALSE
	anchored = FALSE
	force = 8
	throwforce = 10
	throw_speed = 1
	throw_range = 2

	var/fuel = 10000
	var/fuel_max = 10000
	var/stability = 100

/obj/item/am_containment/ex_act(severity, target, origin)
	switch(severity)
		if(1)
			explosion(get_turf(src), 1, 2, 3, 5)
			if(src)
				qdel(src)
		if(2)
			if(prob((fuel/10)-stability))
				explosion(get_turf(src), 1, 2, 3, 5)
				if(src)
					qdel(src)
				return
			stability -= 40
		if(3)
			stability -= 20
	return

/obj/item/am_containment/proc/usefuel(wanted)
	if(fuel < wanted)
		wanted = fuel
	fuel -= wanted
	return wanted
