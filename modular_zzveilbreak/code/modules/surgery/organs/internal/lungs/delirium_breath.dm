/obj/item/organ/lungs/proc/consume_delirium(mob/living/carbon/breather, datum/gas_mixture/breath, delirium_pp, old_delirium_pp)
	breathe_gas_volume(breath, /datum/gas/delirium)
	if(delirium_pp <= gas_stimulation_min || HAS_TRAIT(breather, TRAIT_HALLUCINATION_IMMUNE))
		return
	breather.adjust_hallucinations_up_to(delirium_pp * 4 SECONDS, 80 SECONDS)
	if(prob(clamp(delirium_pp * 8, 5, 35)) && world.time - (GLOB.delirium_cooldowns[breather] || 0) > 25 SECONDS)
		to_chat(breather, "<span class='hallucination' style='color:#8a2be2; font-style:italic;'>" + pick(GLOB.delirious_table) + "</span>")
		GLOB.delirium_cooldowns[breather] = world.time
