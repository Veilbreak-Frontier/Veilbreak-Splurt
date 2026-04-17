/obj/effect/mob_spawn/ghost_role/
	/// set this to make the spawner use the outfit.name instead of its name var for things like cryo announcements and ghost records
	/// modifying the actual name during the game will cause issues with the GLOB.mob_spawners associative list
	var/use_outfit_name
	/// Do we use a random appearance for this ghost role?
	var/random_appearance = TRUE
	/// Can we use our loadout for this role?
	var/loadout_enabled = FALSE
	/// Can we use our quirks for this role?
	var/quirks_enabled = FALSE
	/// Are we limited to a certain species type? LISTED TYPE
	var/restricted_species

/obj/effect/mob_spawn/ghost_role/create(mob/mob_possessor, newname, apply_prefs = FALSE)
	var/mob/living/L = ..(mob_possessor, newname, apply_prefs)

	if(!istype(L))
		return L

	if(!apply_prefs)
		var/datum/language_holder/holder = L.get_language_holder()
		holder.get_selected_language()
		return L

	if(iscarbon(L))
		var/mob/living/carbon/C = L
		C.client?.prefs?.safe_transfer_prefs_to(C)
		if(C.dna)
			C.dna.update_dna_identity()
			C.dna.species.give_important_for_life(C)

		if(quirks_enabled)
			SSquirks.AssignQuirks(C, C.client)

		post_transfer_prefs(C)

		// ROOT CAUSE FIX: Use equip() which handles the spawner's assigned outfit
		equip(C)
	else
		equip(L)

	if(L.mind)
		L.mind.name = L.real_name

	var/obj/machinery/computer/cryopod/control_computer = find_control_computer()
	var/alt_name = get_spawner_outfit_name()
	GLOB.ghost_records.Add(list(list("name" = L.real_name, "rank" = alt_name ? alt_name : name)))

	if(control_computer)
		control_computer.announce("CRYO_JOIN", L.real_name, name)

	return L


// Anything that can potentially be overwritten by transferring prefs must go in this proc
// This is needed because safe_transfer_prefs_to() can override some things that get set in special() for certain roles, like name replacement
// In those cases, please override this proc as well as special()
// TODO: refactor create() and special() so that this is no longer necessary
/obj/effect/mob_spawn/ghost_role/proc/post_transfer_prefs(mob/living/new_spawn)
	return
