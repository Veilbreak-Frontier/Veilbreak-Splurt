// Increase maximum NIFsofts
// Compensates for quirks being converted to NIFs

/obj/item/organ/cyberimp/brain/nif
	max_nifsofts = 10

/obj/item/organ/cyberimp/brain/nif/roleplay_model
	max_nifsofts = 6


/obj/item/organ/cyberimp/brain/nif/sobnif
	name = "SOB Jailbroke NIF"
	desc = "A cracked and Jailbroke Nanite Implant Framework. This particular framework seems to be modified from the original to influence the emotional region of the brain, while still seamlessly bonding with a user like the standard edition. This framework seems to constantly stimulate the dopamine receptors of the brain, forcing a perpetual state of joy."
	manufacturer_notes = "Snake Oil Biosolutions is liable for any issues this product causes. We just don't care and our lawyers are better than yours."

/obj/item/organ/cyberimp/brain/nif/sobnif/on_mob_insert(mob/living/carbon/human/H, special, movement_flags)
	. = ..()  // run parent behavior first
	if(H)
		// Apply the nanite happiness mood effect
		H.add_mood_event("sob_nif_happy", /datum/mood_event/nanite_happiness)

/obj/item/organ/cyberimp/brain/nif/sobnif/on_mob_remove(mob/living/carbon/human/H, special, movement_flags)
	. = ..()  // run parent behavior first
	if(H)
		// Remove the mood effect when the NIF is removed
		H.clear_mood_event("sob_nif_happy")
