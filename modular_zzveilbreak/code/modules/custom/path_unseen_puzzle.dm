// System for the "Path Unseen" multi-part discovery and combination puzzle.
// Players collect 4 hidden fragments from distinct gameplay paths, combine them into the Relic of the Unseen,
// channel it for 25 seconds, and unlock the Path Unseen achievement and power hook.

#define PATH_UNSEEN_FRAG_MAINT    (1 << 0)
#define PATH_UNSEEN_FRAG_VOID     (1 << 1)
#define PATH_UNSEEN_FRAG_VAULT    (1 << 2)
#define PATH_UNSEEN_FRAG_ARCHAEO (1 << 3)
#define PATH_UNSEEN_FRAG_ALL      (PATH_UNSEEN_FRAG_MAINT | PATH_UNSEEN_FRAG_VOID | PATH_UNSEEN_FRAG_VAULT | PATH_UNSEEN_FRAG_ARCHAEO)
#define PATH_UNSEEN_MAX_MINING_SHARDS 3

// ==========================================
// 1. FRAGMENTS & COMBINATION
// ==========================================

/obj/item/path_unseen_fragment
	name = "Fragment of the Unseen"
	desc = "An ancient, enigmatic fragment of a long-forgotten artifact. It pulsates with a subtle, otherworldly resonance."
	icon = 'modular_zzveilbreak/icons/item_icons/voidshard.dmi'
	icon_state = "voidshard"
	w_class = WEIGHT_CLASS_TINY
	light_range = 1.5
	light_power = 0.6
	light_color = "#8a2be2"
	/// Bitflag indicating which specific piece this fragment represents
	var/fragment_bit = NONE
	/// Bitmask tracking all pieces attached to this item
	var/attached_mask = NONE
	/// Lore backstory section for this piece
	var/fragment_lore = ""
	/// Display title for this piece in the lore view
	var/fragment_title = ""

/obj/item/path_unseen_fragment/Initialize(mapload)
	. = ..()
	if(fragment_bit && !attached_mask)
		attached_mask = fragment_bit

/obj/item/path_unseen_fragment/proc/get_fragment_count()
	var/count = 0
	if(attached_mask & PATH_UNSEEN_FRAG_MAINT)
		count++
	if(attached_mask & PATH_UNSEEN_FRAG_VOID)
		count++
	if(attached_mask & PATH_UNSEEN_FRAG_VAULT)
		count++
	if(attached_mask & PATH_UNSEEN_FRAG_ARCHAEO)
		count++
	return count

/obj/item/path_unseen_fragment/examine(mob/user)
	. = ..()
	. += span_notice("The fragment is etched with glowing ancient script:")
	if(attached_mask & PATH_UNSEEN_FRAG_MAINT)
		. += span_boldnotice("--- Fragment I: Shard of Remembrance ---")
		. += span_info("\"Record I: We look at the stars and fear the dark, forgetting the void is what makes the light visible.\"")
	if(attached_mask & PATH_UNSEEN_FRAG_VOID)
		. += span_boldnotice("--- Fragment II: Shard of Emptiness ---")
		. += span_info("\"Record II: The delirium does not come from seeing the abyss. It comes from realizing the abyss is already inside you, beating in the hollow of your chest where compassion used to be.\"")
	if(attached_mask & PATH_UNSEEN_FRAG_VAULT)
		. += span_boldnotice("--- Fragment III: Shard of Secrets ---")
		. += span_info("\"Record III: We swallow our grief, our guilt, our quiet tragedies. We think them forgotten, but they merely settle at the bottom of our minds, forming the very abyss we are so terrified to look into.\"")
	if(attached_mask & PATH_UNSEEN_FRAG_ARCHAEO)
		. += span_boldnotice("--- Fragment IV: Shard of Persistence ---")
		. += span_info("\"Record IV: Bring the four truths together. Bind the shattered reflection of yourself. Accept the emptiness within.\"")

	var/count = get_fragment_count()


	if(count < 4)
		. += span_warning("Assembly Status: [count]/4 fragments combined.")
	else
		. += span_boldnotice("Assembly Status: All 4 fragments are combined!")

/obj/item/path_unseen_fragment/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/path_unseen_fragment))
		return NONE

	var/obj/item/path_unseen_fragment/other = tool
	if(attached_mask & other.attached_mask)
		to_chat(user, span_warning("These fragments share piece(s) that are already combined in [src]!"))
		return ITEM_INTERACT_BLOCKING

	attached_mask |= other.attached_mask
	qdel(other)

	playsound(src, 'sound/machines/click.ogg', 50, TRUE)

	if(attached_mask == PATH_UNSEEN_FRAG_ALL)
		to_chat(user, span_boldnotice("All four fragments snap together with a blinding surge of energy! The relic is complete!"))
		playsound(src, 'sound/effects/magic/charge.ogg', 75, TRUE)
		var/obj/item/path_unseen_artifact/completed = new(get_turf(user))
		user.put_in_hands(completed)
		qdel(src)
		return ITEM_INTERACT_SUCCESS

	var/count = get_fragment_count()
	name = "Partial Unseen Relic ([count]/4 Fragments)"
	to_chat(user, span_notice("You attach the fragment to [src]. ([count]/4 fragments assembled)"))
	return ITEM_INTERACT_SUCCESS

// --- Subtypes for Spawning ---

// Method A: Maintenance Loot
/obj/item/path_unseen_fragment/maint
	name = "Shard of Remembrance"
	desc = "A violet crystal shard recovered from deep maintenance. It hums with faint memory vibrations."
	color = "#9b59b6"
	fragment_bit = PATH_UNSEEN_FRAG_MAINT

// Method B: Void Dungeons
/obj/item/path_unseen_fragment/void
	name = "Shard of the Abyss"
	desc = "A cyan crystal shard pulsing with void energy, retrieved from the dark depths of a void dungeon."
	color = "#1abc9c"
	fragment_bit = PATH_UNSEEN_FRAG_VOID

// Method C: Locked Vault Safe
/obj/item/path_unseen_fragment/vault
	name = "Shard of the Vault"
	desc = "A radiant golden shard that was locked away inside a high-security vault."
	color = "#f1c40f"
	fragment_bit = PATH_UNSEEN_FRAG_VAULT

// Method D: Archaeology / Mining
/obj/item/path_unseen_fragment/archaeo
	name = "Shard of Prehistory"
	desc = "A deep crimson shard unearthly in origin, discovered through excavation and artifact research."
	color = "#e74c3c"
	fragment_bit = PATH_UNSEEN_FRAG_ARCHAEO

// ==========================================
// 2. COMPLETED ARTIFACT & CHANNELING
// ==========================================

/obj/item/path_unseen_artifact
	name = "Relic of the Unseen"
	desc = "A fully reassembled ancient artifact. Four glowing crystal shards hum together in perfect harmony around a dark void core. Activating it in-hand will channel its primordial power."
	icon = 'modular_zzveilbreak/icons/item_icons/voidshard.dmi'
	icon_state = "voidshard"
	color = "#8a2be2"
	light_range = 3
	light_power = 1.5
	light_color = "#8a2be2"
	w_class = WEIGHT_CLASS_SMALL
	/// Prevents overlapping channeling attempts
	var/is_channeling = FALSE
	/// Cooldown timestamp after a failed attempt
	var/cooldown_until = 0

/obj/item/path_unseen_artifact/attack_self(mob/living/user)
	. = ..()
	if(is_channeling)
		to_chat(user, span_warning("You are already channeling the relic!"))
		return
	if(world.time < cooldown_until)
		to_chat(user, span_warning("The relic is still stabilizing from a disrupted channel!"))
		return

	is_channeling = TRUE
	to_chat(user, span_boldnotice("You begin channeling the Relic of the Unseen... Hold still!"))

	var/turf/user_turf = get_turf(user)
	var/obj/effect/temp_visual/cult/rune_spawn/circle = new(user_turf, 25 SECONDS, "#8a2be2")
	var/obj/effect/temp_visual/drawing_heretic_rune/heretic_rune = new(user_turf, "#8a2be2")
	playsound(user_turf, 'sound/effects/magic/lightning_chargeup.ogg', 75, TRUE)

	// Start periodic ambient message loop during 25-second channel
	INVOKE_ASYNC(src, PROC_REF(channel_ambient_loop), user)

	var/success = do_after(user, 25 SECONDS, src, timed_action_flags = NONE)
	is_channeling = FALSE

	if(!QDELETED(circle))
		qdel(circle)
	if(!QDELETED(heretic_rune))
		qdel(heretic_rune)

	if(!success)
		cooldown_until = world.time + 5 SECONDS
		to_chat(user, span_warning("Your channeling of [src] was interrupted!"))
		return

	// --- SUCCESSFUL CHANNELING ---
	new /obj/effect/temp_visual/energy_dash_afterimage(user_turf, user)

	to_chat(user, span_boldnotice("The Relic of the Unseen unleashes its primordial power, infusing with your very soul itself."))

	// Visual & Audio Feedback
	playsound(user, 'sound/effects/magic/staff_change.ogg', 100, TRUE)
	shake_camera(user, 3 SECONDS, 2)
	addtimer(CALLBACK(user, TYPE_PROC_REF(/mob/living, flash_act), 1, 0, 0, TRUE, /atom/movable/screen/fullscreen/flash, 2 SECONDS), 0.2 SECONDS)

	// Total stamina drain
	user.adjustStaminaLoss(user.max_stamina)


	// Achievement Award
	if(user.client)
		user.client.give_award(/datum/award/achievement/veilbreak/path_unseen, user)

	// Unlock Path Unseen Power Hook
	user.unlock_unseen_power()

	// Consume artifact
	qdel(src)

// Temporary visual afterimage effect spawned on successful channel completion
/obj/effect/temp_visual/energy_dash_afterimage
	name = "energy afterimage"
	duration = 1 SECONDS
	layer = ABOVE_MOB_LAYER

/obj/effect/temp_visual/energy_dash_afterimage/Initialize(mapload, mob/living/target_mob)
	. = ..()
	if(target_mob)
		appearance = target_mob.appearance
		dir = target_mob.dir
		color = "#8a2be2"
		alpha = 220
		animate(src, alpha = 0, time = 0.8 SECONDS, easing = EASE_OUT)


/obj/item/path_unseen_artifact/proc/channel_ambient_loop(mob/living/user)
	var/list/messages = list(
		"Arcane glyphs revolve rhythmically around [user]!",
		"A deep hum echoes through the air as the Relic of the Unseen glows brighter!",
		"The fabric of space bends slightly around [user]'s hands!",
		"Energy surges from the Relic of the Unseen into [user]!"
	)
	var/ticks = 0
	while(is_channeling && user && src && ticks < 5)
		sleep(5 SECONDS)
		ticks++
		if(is_channeling && user && src)
			user.visible_message(span_notice(pick(messages)))
			playsound(get_turf(user), 'sound/effects/magic/lightning_chargeup.ogg', 40, TRUE)

// ==========================================
// 3. MOB POWER HOOK & ACHIEVEMENT DATUM
// ==========================================

/// Proc hook called upon successfully channeling the Relic of the Unseen.
/mob/proc/unlock_unseen_power()
	to_chat(src, span_boldnotice("A cosmic rift opens within your mind. You have unlocked the Initiate of the Void!"))
	if(isliving(src))
		var/mob/living/L = src
		var/datum/power/void/path_unseen_initiate/existing = locate() in L.powers
		if(!existing)
			var/datum/power/void/path_unseen_initiate/P = new()
			P.add_to_holder(L)


/// Achievement granted upon completing the Path Unseen puzzle.
/datum/award/achievement/veilbreak/path_unseen
	name = "Path Unseen"
	desc = "Assembled the four lost fragments and successfully channeled the Relic of the Unseen."
	database_id = MEDAL_PATH_UNSEEN
	category = "Veilbreak"
	icon = ACHIEVEMENTS_SET
	icon_state = "basemisc"

// ==========================================
// 4. SPAWNING & PLACEMENT INTEGRATIONS
// ==========================================

GLOBAL_LIST_EMPTY(all_station_safes)

/obj/structure/safe/Initialize(mapload)
	. = ..()
	GLOB.all_station_safes += src

/obj/structure/safe/Destroy()
	GLOB.all_station_safes -= src
	return ..()

/mob/living
	/// Number of maintenance trash piles searched by this person this shift
	var/path_unseen_maint_searches = 0
	/// Tracks whether this mob has obtained their maintenance fragment this shift
	var/path_unseen_maint_found = FALSE

/mob/living/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_LIVING_SEARCHED_TRASH_PILE, PROC_REF(on_searched_trash_pile_unseen))

/mob/living/proc/on_searched_trash_pile_unseen(mob/living/source, obj/structure/trash_pile/trash)
	SIGNAL_HANDLER

	if(path_unseen_maint_found)
		return

	path_unseen_maint_searches++

	// Chance to get lucky: base 10%, scaling up to 90% with search count
	var/luck_chance = min(90, 8 + path_unseen_maint_searches * 2)
	if(!prob(luck_chance))
		return

	path_unseen_maint_found = TRUE

	var/turf/spawn_turf = trash ? get_turf(trash) : get_turf(src)
	if(!spawn_turf)
		return

	new /obj/item/path_unseen_fragment/maint(spawn_turf)
	playsound(spawn_turf, 'sound/effects/magic/charge.ogg', 50, TRUE)
	to_chat(src, span_boldnotice("Your persistence pays off! Deep within the heap, your fingers brush against a glowing Shard of Remembrance!"))
	balloon_alert(src, "found a shard of remembrance!")

/// Auto-setup procedure for fragment placement
/proc/setup_path_unseen_spawns()
	// Method A: Maintenance fragment is awarded dynamically per person searching trash piles (COMSIG_LIVING_SEARCHED_TRASH_PILE)
	// Method B: Void fragment spawns 1 per dungeon in a cache via spawn_dungeon_void_fragment()

	// Method C Fallback: If no /obj/structure/safe/unseen_vault was mapped, put Fragment 3 in a random safe on station
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(setup_path_unseen_vault_fallback)), 5 SECONDS)
	return TRUE

/// Spawns void fragment designations across up to 5 dungeon caches (veilbreak_lootbox). The first one opened yields the fragment, and the remaining chests revert to normal loot.
/proc/spawn_dungeon_void_fragment(z_level)
	if(!z_level)
		return
	var/list/obj/structure/closet/crate/veilbreak_lootbox/crates = list()
	for(var/obj/structure/closet/crate/veilbreak_lootbox/C in world)
		if(C.z == z_level)
			crates += C
	if(length(crates))
		var/count_to_designate = min(5, length(crates))
		for(var/i in 1 to count_to_designate)
			var/obj/structure/closet/crate/veilbreak_lootbox/chosen = pick_n_take(crates)
			chosen.has_unseen_void_shard = TRUE
			// Replace default loot generated at map load with the void fragment
			for(var/atom/movable/AM in chosen)
				qdel(AM)
			new /obj/item/path_unseen_fragment/void(chosen)
	else
		var/turf/T = locate(round(DUNGEON_WIDTH / 2), round(DUNGEON_HEIGHT / 2), z_level)
		if(T)
			new /obj/item/path_unseen_fragment/void(T)

/// Called when one of the designated void fragment chests is opened. Clears designation on other chests on the Z-level, rerolling their contents into standard loot.
/proc/claim_unseen_void_shard(obj/structure/closet/crate/veilbreak_lootbox/opened_crate)
	if(!opened_crate)
		return
	opened_crate.has_unseen_void_shard = FALSE
	var/target_z = opened_crate.z
	for(var/obj/structure/closet/crate/veilbreak_lootbox/other_crate in world)
		if(other_crate == opened_crate || other_crate.z != target_z)
			continue
		if(!other_crate.has_unseen_void_shard)
			continue

		other_crate.has_unseen_void_shard = FALSE

		// Replace the void fragment in other designated crates with standard weighted loot
		for(var/obj/item/path_unseen_fragment/void/frag in other_crate)
			qdel(frag)
			var/obj_type = pick_loot_from_table(veilbreak_lootbox_table)
			if(obj_type)
				new obj_type(other_crate)


GLOBAL_LIST_INIT(path_unseen_spawns_init, setup_path_unseen_spawns())

/proc/setup_path_unseen_vault_fallback()
	var/obj/structure/safe/unseen_vault/existing_vault = locate()
	if(existing_vault)
		return // Mapper manually placed an unseen vault safe on the map!

	var/list/obj/structure/safe/candidate_safes = list()
	for(var/obj/structure/safe/S in GLOB.all_station_safes)
		if(S.loc && is_station_level(S.z))
			candidate_safes += S
	if(length(candidate_safes))
		var/obj/structure/safe/chosen = pick(candidate_safes)
		new /obj/item/path_unseen_fragment/vault(chosen)

// Method C: Locked Vault Safe type (for mapping placement or admin spawning)
/obj/structure/safe/unseen_vault
	name = "ancient sealed safe"
	desc = "A heavy, runic steel safe. Fine print on the dial indicates it houses a shard of an ancient relic."

/obj/structure/safe/unseen_vault/Initialize(mapload)
	. = ..()
	new /obj/item/path_unseen_fragment/vault(src)

// Method D: Archaeology & Rock Mining Drops
GLOBAL_VAR_INIT(path_unseen_mining_shards_spawned, 0)

/turf/closed/mineral/gets_drilled(mob/user, exp_multiplier = 0)
	. = ..()
	if(GLOB.path_unseen_mining_shards_spawned < PATH_UNSEEN_MAX_MINING_SHARDS && prob(2))
		GLOB.path_unseen_mining_shards_spawned++
		new /obj/item/path_unseen_fragment/archaeo(src)
		if(user)
			to_chat(user, span_boldnotice("Your mining pick unearths an ancient crimson fragment embedded in the rock!"))

/obj/item/relic/reveal()
	. = ..()
	if(GLOB.path_unseen_mining_shards_spawned < PATH_UNSEEN_MAX_MINING_SHARDS && prob(25))
		GLOB.path_unseen_mining_shards_spawned++
		new /obj/item/path_unseen_fragment/archaeo(drop_location())

