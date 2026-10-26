/obj/machinery/smartfridge/organ/status_examine()
	// Run the original smartfridge status_examine logic first to keep base features intact
	. = ..()

	// Add modular fuzzy speed tracking
	if(repair_rate <= 0)
		. += span_notice("Its cellular stabilization systems are unpowered or offline; it will only store organs.")
		return .

	var/speed_text = ""
	switch(repair_rate)
		if(0 to 0.6 * STANDARD_ORGAN_HEALING)
			speed_text = "at a sluggish, minor pace"
		if(0.6 * STANDARD_ORGAN_HEALING to 1.1 * STANDARD_ORGAN_HEALING)
			speed_text = "at a steady, moderate pace"
		if(1.1 * STANDARD_ORGAN_HEALING to INFINITY)
			speed_text = "at an accelerated, rapid pace"

	. += span_info("The stabilization monitors indicate it is actively [EXAMINE_HINT("repairing organic contents")] [speed_text].")
