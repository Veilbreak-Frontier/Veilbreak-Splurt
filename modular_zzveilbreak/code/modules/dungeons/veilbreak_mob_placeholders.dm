/obj/effect/mob_placeholder
	name = "mob placeholder"
	desc = "A placeholder for a mob that will be properly initialized."
	icon = 'icons/effects/effects.dmi'
	icon_state = "sparkles"
	invisibility = INVISIBILITY_ABSTRACT
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/mob_type
	var/list/mob_faction
	var/mob_name
	var/spawn_z_level

/obj/effect/mob_placeholder/Initialize(mapload)
	. = ..()

	if(!mob_type)
		determine_mob_type_from_self()

	var/turf/T = get_turf(src)
	if(!T)
		return INITIALIZE_HINT_QDEL

	if(!SSmapping.level_trait(T.z, PORTAL_TRAIT_DUNGEON))
		var/mob/living/L = new mob_type(T)
		if(L)
			if(mob_faction)
				L.faction = mob_faction.Copy()
			if(mob_name && mob_name != "mob placeholder")
				L.name = mob_name
			if(!(L in GLOB.basic_mobs))
				GLOB.basic_mobs += L
		return INITIALIZE_HINT_QDEL

	return INITIALIZE_HINT_NORMAL

/obj/effect/mob_placeholder/proc/determine_mob_type_from_self()
	if(name && name != "mob placeholder")
		var/name_lower = lowertext(name)
		switch(name_lower)
			if("void healer", "healer")
				mob_type = /mob/living/basic/void_creature/void_healer
			if("voidbug", "bug")
				mob_type = /mob/living/basic/void_creature/voidbug
			if("consumed pathfinder", "pathfinder")
				mob_type = /mob/living/basic/void_creature/consumed_pathfinder
			if("voidling")
				mob_type = /mob/living/basic/void_creature/voidling
			if("boss", "megafauna", "inai")
				mob_type = /mob/living/simple_animal/hostile/megafauna/inai

	if(!mob_type)
		switch(icon_state)
			if("void_bug")
				mob_type = /mob/living/basic/void_creature/voidbug
			if("void_soldier")
				mob_type = /mob/living/basic/void_creature/consumed_pathfinder
			else
				mob_type = /mob/living/basic/void_creature/voidling
