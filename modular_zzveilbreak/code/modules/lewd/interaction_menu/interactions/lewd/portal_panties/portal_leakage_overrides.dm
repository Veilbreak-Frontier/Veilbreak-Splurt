// VEILBREAK OVERRIDES - PORTAL PANNTIES FLUID LEAKAGE SIMULATION
// Overrides post_climax on portal items to drop liquid splatters onto the floor underneath the user simultaneously.

/datum/interaction/lewd/portal/post_climax(mob/living/carbon/human/cumming, mob/living/carbon/human/came_in, position)
	..() // Fire any base portal post-climax logic first
	
	if(!cumming || !istype(cumming))
		return
		
	var/turf/floor_turf = get_turf(cumming)
	if(!floor_turf)
		return

	// 1. Handle Penis/Ejaculation Leakage paths
	var/obj/item/organ/genital/testicles/testies = cumming.get_organ_slot(ORGAN_SLOT_TESTICLES)
	if(testies && testies.reagents)
		if(HAS_TRAIT(cumming, TRAIT_MESSY))
			// Duplicate fluid volume into the local turf liquids component system
			var/datum/reagents/R = new(testies.cumshot_size)
			R.add_reagent(initial(testies.internal_fluid_datum), testies.cumshot_size)
			floor_turf.add_liquid_from_reagents(R, FALSE, 1)
			qdel(R)
		else
			// Drop standard visual floor decals underneath the user
			add_cum_splatter_floor(floor_turf, cum_reagent = testies.internal_fluid_datum)
		return

	// 2. Handle Vagina/Squirting Leakage paths
	var/obj/item/organ/genital/vagina/vag = cumming.get_organ_slot(ORGAN_SLOT_VAGINA)
	if(vag && vag.reagents)
		if(HAS_TRAIT(cumming, TRAIT_MESSY))
			var/datum/reagents/R = new(vag.internal_fluid_maximum)
			R.add_reagent(initial(vag.internal_fluid_datum), vag.reagents.total_volume)
			floor_turf.add_liquid_from_reagents(R, FALSE, 1)
			qdel(R)
		else
			add_cum_splatter_floor(floor_turf, female = TRUE, cum_reagent = vag.internal_fluid_datum)
		return
