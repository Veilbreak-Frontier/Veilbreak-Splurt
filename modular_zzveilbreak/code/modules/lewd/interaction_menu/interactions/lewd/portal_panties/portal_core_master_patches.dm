// SYSTEMIC MASTER PATCHES - PORTAL MECHANICS
// Rectifies Mosley's array inversion, prevents engine fallback wire-crossings, and enables fluid dynamics.

/datum/interaction/lewd/portal/fuck_anus
	// 1. Correct the structural array definition layout
	cum_target = list(CLIMAX_POSITION_USER = ORGAN_SLOT_ANUS, CLIMAX_POSITION_TARGET = ORGAN_SLOT_PENIS)
	additional_details = list(INTERACTION_FILLS_CONTAINERS)

/datum/interaction/lewd/portal/fuck_anus/show_climax(mob/living/cumming, mob/living/came_in, position)
	// 2. Intercept the text layout calculation right before climax text resolution blocks execute
	var/obj/item/organ/genital/testicles/testies = cumming.get_organ_slot(ORGAN_SLOT_TESTICLES)
	
	// Dynamically override the choice text so fallback engines never evaluate it as a urethra string
	if(position == CLIMAX_POSITION_USER)
		// Force standard chat variables to string resolve as anus/asshole
		if(length(cum_message_text_overrides[position]))
			cum_message_text_overrides[position] = list("%CUMMING% shoots their load deep into %CAME_IN%'s anus through the portal fleshlight.")
		if(length(cum_self_text_overrides[position]))
			cum_self_text_overrides[position] = list("You shoot your load deep into %CAME_IN%'s anus through the portal fleshlight.")
		if(length(cum_partner_text_overrides[position]))
			cum_partner_text_overrides[position] = list("%CUMMING% shoots their load deep into your anus through the portal panties.")
			
	return ..()

/datum/interaction/lewd/portal/anal_ride
	cum_target = list(CLIMAX_POSITION_USER = ORGAN_SLOT_PENIS, CLIMAX_POSITION_TARGET = ORGAN_SLOT_ANUS)
	additional_details = list(INTERACTION_FILLS_CONTAINERS)

/datum/interaction/lewd/portal/fuck_vagina
	additional_details = list(INTERACTION_FILLS_CONTAINERS)

/datum/interaction/lewd/portal/fuck_urethra
	additional_details = list(INTERACTION_FILLS_CONTAINERS)

/datum/interaction/lewd/portal/urethral_ride
	additional_details = list(INTERACTION_FILLS_CONTAINERS)

/datum/interaction/lewd/portal/vaginal_ride
	additional_details = list(INTERACTION_FILLS_CONTAINERS)
