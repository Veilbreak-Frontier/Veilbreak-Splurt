// This patch merges assistant alt titles across conflicting Bubber, Splurt, and Veilbreak downstream layers.
// It compiles last to overwrite Splurt's broken constructor and stitch all datasets into a unique array.
/datum/job/assistant/New()
	..()
	src.alt_titles = list()

	var/list/bubber_dataset = list(
		"Assistant",
		"Ambassador",
		"Artist",
		"Actor",
		"Businessman",
		"Businesswoman",
		"Butler",
		"Colonist",
		"Contractor",
		"Civilian",
		"Duchess",
		"Duke",
		"Diplomat",
		"Entertainer"
	)

	var/list/splurt_dataset = list(
		"All-Purpose Dildo",
		"All-Purpose Fleshlight",
		"Bard",
		"Bear Communist",
		"Belly Massager",
		"Blacksmith",
		"Boxer",
		"Clerk",
		"Coffee Runner",
		"Comedic Foil",
		"Cumdump",
		"Emotional Support",
		"Errand Boy",
		"Errand Girl",
		"Escort",
		"Freeloader",
		"Greytider",
		"Intern",
		"Pet"
	)

	var/list/veilbreak_dataset = list(
		"Chewtoy"
	)

	src.alt_titles |= bubber_dataset
	src.alt_titles |= splurt_dataset
	src.alt_titles |= veilbreak_dataset
