/mob/living/carbon/proc/protean_main_ui()
	var/datum/species/protean/species = dna.species
	if(!istype(species))
		return
	species.ui_interact(src)
