// VEILBREAK OVERRIDES - SMART CLOTHING AIRFLOW AND FLUID LEAKAGE REGISTRY
// Combines native bitflag checks with path text matching to ensure long dresses and kilts leak correctly while excluding tight gear.

/datum/interaction/lewd/portal/post_climax(mob/living/carbon/human/cumming, mob/living/carbon/human/came_in, position)
	..() // Fire previous master portal validation layers first
	
	if(!cumming || !istype(cumming))
		return
		
	var/turf/floor_turf = get_turf(cumming)
	if(!floor_turf)
		return

	var/clothing_leakage_pass = FALSE
	
	var/obj/item/clothing/under/U = cumming.w_uniform
	var/obj/item/clothing/suit/S = cumming.wear_suit
	
	// 1. Evaluate uniform inner layers (Uniform slot)
	if(U && !istype(U, /obj/item/clothing/sextoy))
		// Pass if it inherently clears the legs flag (mini-skirts, sweaters, open tops)
		if(!(U.body_parts_covered & LEGS))
			clothing_leakage_pass = TRUE
		// Fallback check: Pass if it is a long skirt/dress/kilt that developers forced to use the LEGS flag for sprite hiders
		else if(findtext(U.name, "skirt") || findtext(U.name, "dress") || findtext(U.name, "kilt") || findtext(U.name, "gown") || findtext(U.name, "kimono") || findtext(U.name, "qipao"))
			clothing_leakage_pass = TRUE
			
	// 2. Evaluate suit outer layers (Suit slot)
	if(S && !istype(S, /obj/item/clothing/sextoy))
		if(!(S.body_parts_covered & LEGS))
			clothing_leakage_pass = TRUE
		else if(findtext(S.name, "skirt") || findtext(S.name, "dress") || findtext(S.name, "cloak") || findtext(S.name, "gown") || findtext(S.name, "kimono"))
			clothing_leakage_pass = TRUE

	// Execute floor splattering loops if they are bottomless or pass our loose wardrobe validation layers
	if(cumming.is_bottomless() || clothing_leakage_pass)
		// Handle Male/Penis Ejaculation Leakage paths
		var/obj/item/organ/genital/testicles/testies = cumming.get_organ_slot(ORGAN_SLOT_TESTICLES)
		if(testies && testies.reagents)
			if(HAS_TRAIT(cumming, TRAIT_MESSY))
				var/datum/reagents/R = new(testies.cumshot_size)
				R.add_reagent(initial(testies.internal_fluid_datum), testies.cumshot_size)
				floor_turf.add_liquid_from_reagents(R, FALSE, 1)
				qdel(R)
			else
				add_cum_splatter_floor(floor_turf, cum_reagent = testies.internal_fluid_datum)
			return

		// Handle Female/Squirting Leakage paths
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
