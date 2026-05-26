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
    var/mob/living/spawned_mob = ..(mob_possessor, newname, apply_prefs)

    if(!spawned_mob)
        return null

    if(!apply_prefs)
        if(ishuman(spawned_mob))
            var/mob/living/carbon/human/H = spawned_mob
            var/datum/language_holder/holder = H.get_language_holder()
            holder.get_selected_language()
        return spawned_mob

    if(spawned_mob.client && spawned_mob.client.prefs)
        spawned_mob.client.prefs.safe_transfer_prefs_to(spawned_mob)

    if(ishuman(spawned_mob))
        var/mob/living/carbon/human/H = spawned_mob
        if(H.dna)
            H.dna.update_dna_identity()
            if(H.mind)
                H.mind.name = H.real_name
            H.dna.species.give_important_for_life(H)

        if(quirks_enabled)
            SSquirks.AssignQuirks(H, H.client)
            H.cleanse_power_datums()
            SSpowers.assign_powers(H, H.client)

        if(loadout_enabled)
            ASYNC
                H.equip_outfit_and_loadout(outfit, H.client.prefs)
        else
            equip(H)
    else
        equip(spawned_mob)

    var/obj/machinery/computer/cryopod/control_computer = find_control_computer()
    var/alt_name = get_spawner_outfit_name()
    GLOB.ghost_records.Add(list(list("name" = spawned_mob.real_name, "rank" = alt_name ? alt_name : name)))
    if(control_computer)
        control_computer.announce("CRYO_JOIN", spawned_mob.real_name, name)

    return spawned_mob


// Anything that can potentially be overwritten by transferring prefs must go in this proc
// This is needed because safe_transfer_prefs_to() can override some things that get set in special() for certain roles, like name replacement
// In those cases, please override this proc as well as special()
// TODO: refactor create() and special() so that this is no longer necessary
/obj/effect/mob_spawn/ghost_role/proc/post_transfer_prefs(mob/living/new_spawn)
	return
