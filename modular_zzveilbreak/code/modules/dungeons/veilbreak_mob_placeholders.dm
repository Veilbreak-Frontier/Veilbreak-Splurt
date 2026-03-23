/obj/effect/mob_placeholder
	name = "mob placeholder"
	icon = 'modular_zzveilbreak/icons/mob/mobs.dmi'
	icon_state = "void_bug"
	var/mob_type
	var/mob_name
	var/list/mob_faction

/obj/effect/mob_placeholder/Initialize(mapload)
	. = ..()
	if(mob_type && ispath(mob_type, /mob/living))
		var/mob/living/L = new mob_type(loc)
		if(L)
			GLOB.basic_mobs += L
	return INITIALIZE_HINT_QDEL
