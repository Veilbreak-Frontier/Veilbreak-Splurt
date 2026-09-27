/turf/open/floor/void_tile
	name = "Void Floor"
	desc = "A tile made from the very fabric of void itself. How are you even standing on this..."
	icon = 'modular_zzveilbreak/icons/tiles/void_tile.dmi'
	icon_state = "void_tile"
	baseturfs = /turf/open/floor/void_tile
	initial_gas_mix = VOID_ATMOS
	planetary_atmos = TRUE
	light_range = 2.0
	light_power = 0.9
	light_color = LIGHT_COLOR_DEFAULT
	thermal_conductivity = 0.1
	heat_capacity = INFINITY
	footstep = FOOTSTEP_PLATING
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_turf = FALSE
	turf_flags = IS_SOLID | NO_RUST
	rcd_proof = TRUE
	rust_resistance = RUST_RESISTANCE_ABSOLUTE
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | BOMB_PROOF

	// Glass floor properties for proper layering and transparency
	layer = GLASS_FLOOR_LAYER
	underfloor_accessibility = UNDERFLOOR_VISIBLE

/turf/open/floor/void_tile/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/turf/open/floor/void_tile/LateInitialize()
	ADD_TURF_TRANSPARENCY(src, INNATE_TRAIT)

/turf/open/floor/void_tile/break_tile()
	return //unbreakable

/turf/open/floor/void_tile/burn_tile()
	return //unbreakable

/turf/open/floor/void_tile/make_plating(force = FALSE)
	if(force)
		return ..()
	return //unplateable

/turf/open/floor/void_tile/ex_act(severity, target)
	if(fish_source)
		GLOB.preset_fish_sources[fish_source].spawn_reward_from_explosion(src, severity)
	return FALSE

/turf/open/floor/void_tile/narsie_act(force, ignore_mobs, probability = 20)
	. = (prob(probability) || force)
	for(var/I in src)
		var/atom/A = I
		if(ignore_mobs && ismob(A))
			continue
		if(ismob(A) || .)
			A.narsie_act()

/turf/open/floor/void_tile/acid_melt()
	return

/turf/open/floor/void_tile/Melt()
	to_be_destroyed = FALSE
	return src

/turf/open/floor/void_tile/singularity_act()
	return

/turf/open/floor/void_tile/TerraformTurf(path, new_baseturf, flags, defer_change = FALSE, ignore_air = FALSE)
	return

// ==========================================
// PATH UNSEEN PUZZLE TILE & DOOR INTEGRATION
// ==========================================

/// Void tile descendant that opens a linked door after a 5-second channel by a player with the Path Unseen achievement.
/turf/open/floor/void_tile/path_unseen
	name = "Path Unseen void floor"
	desc = "A void tile that pulses with bright cyan energy. It responds only to those who have mastered the Path Unseen."
	icon_state = "void_tile"
	color = "#02d3f9"
	light_color = "#05f3ff"
	baseturfs = /turf/open/floor/void_tile/path_unseen
	/// Linked door instance
	var/obj/machinery/door/linked_door
	/// Search radius for auto-linking the nearest door
	var/door_search_range = 7

/turf/open/floor/void_tile/path_unseen/LateInitialize()
	. = ..()
	add_filter("path_unseen_glow", 1, list("type" = "outline", "color" = "#00ffff", "size" = 1))
	get_linked_door()

/// Finds and caches the nearest door within 7 tiles range
/turf/open/floor/void_tile/path_unseen/proc/get_linked_door()
	if(linked_door && !QDELETED(linked_door))
		return linked_door

	var/obj/machinery/door/best_door = null
	var/best_dist = INFINITY

	// Search for path_unseen blast door first
	for(var/obj/machinery/door/poddoor/path_unseen/P in range(door_search_range, src))
		var/dist = get_dist(src, P)
		if(dist < best_dist)
			best_dist = dist
			best_door = P

	// Fallback to any door within range
	if(!best_door)
		for(var/obj/machinery/door/D in range(door_search_range, src))
			var/dist = get_dist(src, D)
			if(dist < best_dist)
				best_dist = dist
				best_door = D

	linked_door = best_door
	return linked_door

/turf/open/floor/void_tile/path_unseen/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(isliving(arrived))
		var/mob/living/L = arrived
		if(L.client)
			if(L.client.get_award_status(/datum/award/achievement/veilbreak/path_unseen))
				INVOKE_ASYNC(src, PROC_REF(channel_open_door), L)
			else
				to_chat(L, span_warning("The void tile remains inert. You have not unlocked the Path Unseen."))

/// Channels for 5 seconds with a progress bar before permanently opening the door
/turf/open/floor/void_tile/path_unseen/proc/channel_open_door(mob/living/L)
	var/obj/machinery/door/target_door = get_linked_door()
	if(!target_door || !target_door.density)
		return

	to_chat(L, span_boldnotice("You stand on the void tile and begin channeling energy into the Path Unseen mechanism..."))
	playsound(src, 'sound/effects/phasein.ogg', 30, TRUE)

	if(do_after(L, 5 SECONDS, target = src))
		if(target_door && target_door.density)
			to_chat(L, span_boldnotice("The void tile resonates powerfully! The door unlocks and opens."))
			playsound(src, 'sound/effects/phasein.ogg', 60, TRUE)
			INVOKE_ASYNC(target_door, TYPE_PROC_REF(/obj/machinery/door, open))
	else
		to_chat(L, span_warning("Channel interrupted! You must remain standing on the void tile."))

/// Indestructible blast door designed to be controlled by the Path Unseen void tile.
/obj/machinery/door/poddoor/path_unseen
	name = "Path Unseen blast door"
	desc = "An ancient, indestructible blast door bound to a void pressure mechanism."
	icon = 'icons/obj/doors/blastdoor.dmi'
	icon_state = "closed"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	can_open_with_hands = FALSE
	autoclose = FALSE

/obj/machinery/door/poddoor/path_unseen/screwdriver_act(mob/living/user, obj/item/tool)
	balloon_alert(user, "sealed by void energy!")
	return ITEM_INTERACT_BLOCKING

/obj/machinery/door/poddoor/path_unseen/crowbar_act(mob/living/user, obj/item/tool)
	balloon_alert(user, "sealed by void energy!")
	return ITEM_INTERACT_BLOCKING

/obj/machinery/door/poddoor/path_unseen/wirecutter_act(mob/living/user, obj/item/tool)
	balloon_alert(user, "sealed by void energy!")
	return ITEM_INTERACT_BLOCKING

/obj/machinery/door/poddoor/path_unseen/welder_act(mob/living/user, obj/item/tool)
	balloon_alert(user, "sealed by void energy!")
	return ITEM_INTERACT_BLOCKING

/obj/machinery/door/poddoor/path_unseen/attack_alien(mob/living/carbon/alien/adult/user, list/modifiers)
	balloon_alert(user, "sealed by void energy!")
	return FALSE

