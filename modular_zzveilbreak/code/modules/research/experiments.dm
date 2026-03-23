/datum/experiment/scanning/voidshard_analysis
	name = "Voidshard Analysis"
	description = "Our understanding of the void will increase, allowing us to build better stock parts."
	exp_tag = "Destructive"
	traits = EXPERIMENT_TRAIT_DESTRUCTIVE
	required_atoms = list(/obj/item/voidshard = 1)
	allowed_experimentors = list(/obj/machinery/destructive_scanner)
