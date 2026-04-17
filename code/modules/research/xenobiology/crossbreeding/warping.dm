/*
Warping extracts crossbreed
put up a rune with bluespace effects, lots of those runes are fluff or act as a passive buff, others are just griefing tools
*/

/proc/get_slime_type_path_from_extract(obj/item/slime_extract/extract)
	if(!istype(extract))
		return null
	for(var/datum/slime_type/slime_path as anything in subtypesof(/datum/slime_type))
		if(initial(slime_path.core_type) == extract.type)
			return slime_path
	return null

/obj/item/slimecross/warping
	name = "warped extract"
	desc = "It just won't stay in place."
	icon_state = "warping"
	effect = "warping"
	///what runes will be drawn depending on the crossbreed color
	var/obj/effect/warped_rune/runepath
	///time it takes to store the rune back into the crossbreed
	var/storing_time = 5 SECONDS
	///time it takes to draw the rune
	var/drawing_time = 5 SECONDS
	var/max_cooldown = 30 SECONDS
	COOLDOWN_DECLARE(drawing_cooldown)

/obj/effect/warped_rune
	name = "warped rune"
	desc = "An unstable rune born of the depths of bluespace"
	icon = 'icons/obj/science/slimecrossing.dmi'
	icon_state = "rune_grey"
	move_resist = INFINITY //here to avoid the rune being moved since it only sets it's turf once when it's drawn. doesn't include admin fuckery.
	anchored = TRUE
	layer = MID_TURF_LAYER
	resistance_flags = FIRE_PROOF
	var/dir_sound = 'sound/effects/phasein.ogg'
	var/activated_on_step = FALSE
	///is only used for bluespace crystal erasing as of now
	var/storing_time = 5 SECONDS
	///Nearly all runes needs to know which turf they are on
	var/turf/rune_turf
	var/remove_on_activation = TRUE

/obj/effect/warped_rune/Initialize(mapload)
	. = ..()
	add_overlay("blank")
	rune_turf = get_turf(src)
	RegisterSignal(rune_turf, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(clean_rune))
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/warped_rune/Moved(atom/OldLoc, Dir)
	. = ..()
	rune_turf = get_turf(src)

///runes can also be deleted by bluespace crystals relatively fast as an alternative to cleaning them.
/obj/effect/warped_rune/attackby(obj/item/used_item, mob/living/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(!istype(used_item, /obj/item/stack/ore/bluespace_crystal))
		return

	var/obj/item/stack/space_crystal = used_item
	if(do_after(user, storing_time, target = src))
		to_chat(user, span_notice("You nullify the effects of the rune with the bluespace crystal!"))
		space_crystal.use(1)
		playsound(src, 'sound/effects/phasein.ogg', 20, TRUE)
		qdel(src)

/obj/effect/warped_rune/acid_act()
	. = ..()
	visible_message(span_warning("[src] has been dissolved by the acid"))
	playsound(src, 'sound/items/tools/welder.ogg', 150, TRUE)
	qdel(src)

/obj/effect/warped_rune/proc/clean_rune()
	SIGNAL_HANDLER

	qdel(src)

/// Using the extract on a floor tile draws the rune; using it on your matching rune removes it after a delay.
/obj/item/slimecross/warping/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!user.Adjacent(interacting_with))
		return NONE

	if(istype(interacting_with, runepath))
		if(do_after(user, storing_time, target = interacting_with))
			qdel(interacting_with)
		return ITEM_INTERACT_BLOCKING

	if(isturf(interacting_with))
		if(locate(/obj/effect/warped_rune) in interacting_with)
			to_chat(user, span_warning("There is already a bluespace rune here!"))
			return ITEM_INTERACT_BLOCKING
		if(!isfloorturf(interacting_with))
			to_chat(user, span_warning("You cannot draw a rune here!"))
			return ITEM_INTERACT_BLOCKING
		if(!check_cd(user))
			return ITEM_INTERACT_BLOCKING
		if(do_after(user, drawing_time, target = interacting_with))
			if(!locate(/obj/effect/warped_rune) in interacting_with && check_cd(user))
				warping_crossbreed_spawn(interacting_with, user)
				COOLDOWN_START(src, drawing_cooldown, max_cooldown)
		return ITEM_INTERACT_BLOCKING

	return NONE

///spawns the rune
/obj/item/slimecross/warping/proc/warping_crossbreed_spawn(atom/target, mob/user)
	playsound(target, 'sound/effects/slosh.ogg', 20, TRUE)
	new runepath(target)
	to_chat(user, span_notice("You carefully draw the rune with [src]."))

/obj/item/slimecross/warping/proc/check_cd(user)
	if(!COOLDOWN_FINISHED(src, drawing_cooldown))
		if(user)
			to_chat(user, span_warning("[src] is recharging energy."))
		return FALSE
	return TRUE

/obj/effect/warped_rune/attack_hand(mob/living/user)
	. = ..()
	do_effect(user)

/obj/effect/warped_rune/proc/do_effect(mob/user)
	SHOULD_CALL_PARENT(TRUE)
	if(remove_on_activation)
		playsound(rune_turf, dir_sound, 20, TRUE)
		to_chat(user, (span_notice("[src] fades.")))
		qdel(src)

/obj/effect/warped_rune/proc/on_entered(datum/source, atom/movable/AM, oldloc)
	SIGNAL_HANDLER

	if(activated_on_step)
		playsound(rune_turf, dir_sound, 20, TRUE)
		visible_message(span_notice("[src] fades."))
		qdel(src)

/obj/item/slimecross/warping/grey
	name = "greyspace crossbreed"
	colour = SLIME_TYPE_GREY
	effect_desc = "Draws a rune. Extracts that are on the rune are absorbed, 8 extracts produces an adult slime of that color."
	runepath = /obj/effect/warped_rune/greyspace

/obj/effect/warped_rune/greyspace
	name = "greyspace rune"
	desc = "Death is merely a setback, anything can be rebuilt given the right components."
	icon_state = "rune_grey"
	/// Slime colour datum path matching absorbed extracts (see get_slime_type_path_from_extract).
	var/datum/slime_type/extract_slime_type
	var/req_extracts = 8

/obj/effect/warped_rune/greyspace/examine(mob/user)
	. = ..()
	var/desc_suffix = extract_slime_type ? initial(extract_slime_type.colour) : "slime"
	. += span_notice("Requires absorbing [req_extracts] [desc_suffix] extracts.")

/obj/effect/warped_rune/greyspace/do_effect(mob/user)
	for(var/obj/item/slime_extract/extract in rune_turf)
		var/datum/slime_type/this_type = get_slime_type_path_from_extract(extract)
		if(!this_type)
			continue
		if(!extract_slime_type || extract_slime_type == this_type)
			extract_slime_type = this_type
			qdel(extract)
			req_extracts--
			if(req_extracts <= 0)
				new /mob/living/basic/slime(rune_turf, extract_slime_type, SLIME_LIFE_STAGE_ADULT)
				req_extracts = initial(req_extracts)
				extract_slime_type = null
				return ..()
			playsound(rune_turf, 'sound/effects/splat.ogg', 20, TRUE)
		else
			to_chat(user, span_warning("This rune wants [initial(extract_slime_type.colour)] extracts."))


/obj/item/slimecross/warping/orange
	colour = SLIME_TYPE_ORANGE
	runepath = /obj/effect/warped_rune/orangespace
	effect_desc = "Draws a rune that can summon a bonfire."

/obj/effect/warped_rune/orangespace
	desc = "This can be activated to summon a bonfire."
	icon_state = "rune_orange"

/obj/effect/warped_rune/orangespace/do_effect(mob/user)
	var/obj/structure/bonfire/fire = new(rune_turf)
	fire.start_burning()
	. = ..()

/obj/item/slimecross/warping/purple
	colour = SLIME_TYPE_PURPLE
	runepath = /obj/effect/warped_rune/purplespace
	effect_desc = "Draws a rune that may be activated to summon two random medical items."

/obj/effect/warped_rune/purplespace
	desc = "This can be activated to summon two random medical."
	icon_state = "rune_purple"

/obj/effect/warped_rune/purplespace/do_effect(mob/user)
	var/list/medical = list(
		/obj/item/stack/medical/gauze,
		/obj/item/reagent_containers/hypospray/medipen,
		/obj/item/stack/medical/bruise_pack,
		/obj/item/stack/medical/ointment,
		/obj/item/reagent_containers/applicator/pill/oxandrolone,
		/obj/item/storage/pill_bottle/multiver,
		/obj/item/reagent_containers/applicator/pill/mutadone,
		/obj/item/reagent_containers/applicator/pill/potassiodide,
		/obj/item/reagent_containers/applicator/patch/libital,
		/obj/item/reagent_containers/applicator/patch/synthflesh,
		/obj/item/reagent_containers/applicator/patch/aiuri,
		/obj/item/healthanalyzer,
		/obj/item/surgical_drapes,
		/obj/item/scalpel,
		/obj/item/hemostat,
		/obj/item/cautery,
		/obj/item/circular_saw,
		/obj/item/surgicaldrill,
		/obj/item/retractor,
		/obj/item/blood_filter)

	for(var/i in 1 to 2)
		var/path = pick_n_take(medical)
		new path(rune_turf)
	. = ..()

/obj/item/slimecross/warping/blue
	colour = SLIME_TYPE_BLUE
	runepath = /obj/effect/warped_rune/cyanspace //we'll call the blue rune cyanspace to not mix it up with actual bluespace rune
	effect_desc = "Draw a rune that is slippery like water and may be activated to cover all adjacent tiles in ice."

/obj/effect/warped_rune/cyanspace
	icon_state = "rune_blue"
	desc = "Its slippery like water and may be activated to cover all adjacent tiles in ice."

/obj/effect/warped_rune/cyanspace/do_effect(mob/user)
	for(var/turf/open/T in RANGE_TURFS(1, src) - rune_turf)
		T.MakeSlippery(TURF_WET_PERMAFROST, 1 MINUTES)
	. = ..()

/obj/effect/warped_rune/cyanspace/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/slippery, 30)

/obj/effect/warped_rune/cyanspace/on_entered(datum/source, atom/movable/AM, oldloc)
	if(isliving(AM))
		activated_on_step = TRUE
	. = ..()

/obj/item/slimecross/warping/darkblue
	colour = SLIME_TYPE_DARK_BLUE
	runepath = /obj/effect/warped_rune/darkcyanspace //we'll call the blue rune cyanspace to not mix it up with actual bluespace rune
	effect_desc = "Draw a rune that can lower the temperature of whoever steps on it."

/obj/effect/warped_rune/darkcyanspace
	icon_state = "rune_dark_blue"
	desc = "Refreshing!"
	remove_on_activation = FALSE

/obj/effect/warped_rune/darkcyanspace/on_entered(datum/source, atom/movable/AM, oldloc)
	if(isliving(AM))
		var/mob/living/L = AM
		L.adjust_bodytemperature(-300)
		activated_on_step = TRUE
	. = ..()

/obj/item/slimecross/warping/metal
	colour = SLIME_TYPE_METAL
	runepath = /obj/effect/warped_rune/metalspace
	effect_desc = "Draws a rune that may be activated to create a 3x3 block of invisible walls."

//It's a wall what do you want from me
/obj/effect/warped_rune/metalspace
	desc = "This can be activated to to create a 3x3 block of invisible walls."
	icon_state = "rune_metal"

/obj/effect/warped_rune/metalspace/do_effect(mob/user)
	for(var/turf/open/T in RANGE_TURFS(1, src))
		new /obj/effect/forcefield/mime(T)
	. = ..()

/obj/item/slimecross/warping/yellow
	colour = SLIME_TYPE_YELLOW
	runepath = /obj/effect/warped_rune/yellowspace
	effect_desc = "Draw a rune that causes electrical interference."

/obj/effect/warped_rune/yellowspace
	desc = "Be careful with taking power cells with you!"
	icon_state = "rune_yellow"
	remove_on_activation = FALSE

/obj/effect/warped_rune/yellowspace/on_entered(datum/source, atom/movable/AM, oldloc)
	var/obj/item/stock_parts/power_store/cell/C = AM.get_cell()
	if(!C && isliving(AM))
		var/mob/living/L = AM
		for(var/obj/item/I in L.get_all_contents())
			C = I.get_cell()
			if(C?.charge)
				break
	if(C?.charge)
		do_sparks(5, FALSE, C)
		INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(empulse), rune_turf, 1, 1, src)
		C.use(C.charge)
		activated_on_step = TRUE
	. = ..()

/obj/item/slimecross/warping/darkpurple
	colour = SLIME_TYPE_DARK_PURPLE
	runepath = /obj/effect/warped_rune/darkpurplespace
	effect_desc = "Draw a rune that can transmute plasma into any other material."

/obj/effect/warped_rune/darkpurplespace
	icon = 'icons/obj/science/slimecrossing.dmi'
	icon_state = "rune_dark_purple"
	desc = "To gain something you must sacrifice something else in return."
	var/static/list/materials = list(/obj/item/stack/sheet/iron, /obj/item/stack/sheet/glass, /obj/item/stack/sheet/mineral/silver,
									/obj/item/stack/sheet/mineral/gold, /obj/item/stack/sheet/mineral/diamond, /obj/item/stack/sheet/mineral/uranium,
									/obj/item/stack/sheet/mineral/titanium, /obj/item/stack/sheet/plasteel,
									/obj/item/stack/ore/bluespace_crystal/refined)

/obj/effect/warped_rune/darkpurplespace/do_effect(mob/user)
	if(locate(/obj/item/stack/sheet/mineral/plasma) in rune_turf)
		var/amt = 0
		for(var/obj/item/stack/sheet/mineral/plasma/P in rune_turf)
			amt += P.amount
			qdel(P)
		var/path_material = pick(materials)
		new path_material(rune_turf, amt)
		return ..()
	else
		to_chat(user, span_warning("Requires plasma!"))

/obj/item/slimecross/warping/silver
	colour = SLIME_TYPE_SILVER
	effect_desc = "Draw a rune that can feed whoever steps on it.."
	runepath = /obj/effect/warped_rune/silverspace

/obj/effect/warped_rune/silverspace
	desc = "This feeds whoever steps on it."
	icon_state = "rune_silver"
	remove_on_activation = FALSE

/obj/effect/warped_rune/silverspace/on_entered(datum/source, atom/movable/AM, oldloc)
	if(iscarbon(AM))
		var/mob/living/carbon/C = AM
		C.reagents.add_reagent(/datum/reagent/consumable/nutriment, 100)
		activated_on_step = TRUE
	. = ..()

GLOBAL_DATUM(blue_storage, /obj/item/storage/backpack/holding/bluespace)

/obj/item/storage/backpack/holding/bluespace
	name = "warped rune"
	anchored = TRUE
	armor_type = /datum/armor/holding_bluespace
	invisibility = INVISIBILITY_ABSTRACT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF


/datum/armor/holding_bluespace
	melee = 100
	bullet = 100
	laser = 100
	energy = 100
	bomb = 100
	bio = 100
	fire = 100
	acid = 100

/obj/item/slimecross/warping/bluespace
	colour = SLIME_TYPE_BLUESPACE
	runepath = /obj/effect/warped_rune/bluespace
	effect_desc = "Draw a rune that serves as a bluespace container."

/obj/effect/warped_rune/bluespace
	desc = "When activated, it gives access to a bluespace container."
	icon_state = "rune_bluespace"
	remove_on_activation = FALSE

/obj/effect/warped_rune/bluespace/do_effect(mob/user)
	if(!GLOB.blue_storage)
		GLOB.blue_storage = new(null)
	GLOB.blue_storage.forceMove(loc)
	if(GLOB.blue_storage.atom_storage)
		GLOB.blue_storage.atom_storage.refresh_views()
	playsound(rune_turf, dir_sound, 20, TRUE)
	. = ..()

/obj/item/slimecross/warping/sepia
	colour = SLIME_TYPE_SEPIA
	runepath = /obj/effect/warped_rune/sepiaspace
	effect_desc = "Rune activates automatically when stepped on, triggering a timestop around it."

/obj/effect/warped_rune/sepiaspace
	desc = "stepping on it stops time around it."
	icon_state = "rune_sepia"
	remove_on_activation = FALSE

/obj/effect/warped_rune/sepiaspace/on_entered(datum/source, atom/movable/AM, oldloc)
	new /obj/effect/timestop(rune_turf, null, null, null)
	activated_on_step = TRUE
	. = ..()

/obj/item/slimecross/warping/cerulean
	colour = SLIME_TYPE_CERULEAN
	runepath = /obj/effect/warped_rune/ceruleanspace
	effect_desc = "Draws a rune that creates a hologram of the first living thing that stepped on the tile."

/obj/effect/warped_rune/ceruleanspace
	desc = "A shadow of what once passed these halls, a memory perhaps?"
	icon_state = "rune_cerulean"
	remove_on_activation = FALSE
	///hologram that will be spawned by the rune
	var/obj/effect/overlay/holotile
	///mob the hologram will copy
	var/mob/living/holo_host
	///used to remember the recent speech of the holo_host
	var/list/recent_speech
	///used to remember the timer ID that activates holo_talk

/obj/effect/warped_rune/ceruleanspace/proc/holo_talk()
	if(holotile && LAZYLEN(recent_speech))
		holotile.say(pick(recent_speech))
		addtimer(CALLBACK(src, PROC_REF(holo_talk)), 10 SECONDS, TIMER_OVERRIDE|TIMER_UNIQUE)

/obj/effect/warped_rune/ceruleanspace/on_entered(datum/source, atom/movable/AM, oldloc)
	. = ..()
	if(isliving(AM) && !holo_host)
		holo_host = AM

/obj/effect/warped_rune/ceruleanspace/do_effect(mob/user)
	. = ..()
	if(holo_host && !holotile)
		holo_creation()
		remove_on_activation = TRUE
		playsound(rune_turf, dir_sound, 20, TRUE)

/obj/effect/warped_rune/ceruleanspace/proc/holo_creation()
	addtimer(CALLBACK(src, PROC_REF(holo_talk)), 10 SECONDS, TIMER_OVERRIDE|TIMER_UNIQUE)

	if(locate(holotile) in rune_turf)//here to delete the previous hologram,
		QDEL_NULL(holotile)

	holotile = new /obj/effect/overlay(rune_turf)
	holotile.icon = holo_host.icon
	holotile.icon_state = holo_host.icon_state
	holotile.alpha = 200
	holotile.name = "[holo_host.name] (Hologram)"
	holotile.add_atom_colour("#77abff", FIXED_COLOUR_PRIORITY)
	holotile.copy_overlays(holo_host, TRUE)
	holotile.set_anchored(TRUE)
	holotile.set_density(FALSE)

	//the code that follows is basically the code that changeling use to get people's last spoken sentences with a few tweaks.
	recent_speech = list() //resets the list from its previous sentences
	var/list/say_log = list()
	var/log_source = holo_host.logging
	for(var/log_type in log_source)
		var/nlog_type = text2num(log_type)
		if(nlog_type & LOG_SAY)
			var/list/reversed = log_source[log_type] //reverse the list so we get the last sentences instead of the first
			if(islist(reversed))
				say_log = reverse_range(reversed.Copy())
				break

	if(length(say_log) > 10)
		recent_speech = say_log.Copy(say_log.len - 9, 0)
	else
		recent_speech = say_log.Copy()

	if(!length(recent_speech))
		recent_speech = null

///destroys the hologram with the rune
/obj/effect/warped_rune/ceruleanspace/Destroy()
	QDEL_NULL(holotile)
	holo_host = null
	recent_speech = null
	return ..()

/obj/item/slimecross/warping/pyrite
	colour = SLIME_TYPE_PYRITE
	runepath = /obj/effect/warped_rune/pyritespace
	effect_desc = "draws a rune that will randomly color whatever steps on it."

/obj/effect/warped_rune/pyritespace
	desc = "Who shall we be today? they asked, but not even the canvas would answer."
	icon_state = "rune_pyrite"
	remove_on_activation = FALSE
	var/colour = COLOR_WHITE

/obj/effect/warped_rune/pyritespace/Initialize(mapload)
	. = ..()
	colour = pick(COLOR_WHITE, COLOR_RED, "#FFA500", COLOR_YELLOW, COLOR_VIBRANT_LIME, COLOR_BLUE, "#4B0082", COLOR_MAGENTA)

/obj/effect/warped_rune/pyritespace/on_entered(datum/source, atom/movable/AM, oldloc)
	if(isliving(AM))
		AM.add_atom_colour(colour, WASHABLE_COLOUR_PRIORITY)
		activated_on_step = TRUE
		playsound(src, 'sound/items/bikehorn.ogg', 50, TRUE)
	. = ..()

/obj/item/slimecross/warping/red
	colour = SLIME_TYPE_RED
	runepath = /obj/effect/warped_rune/redspace
	effect_desc = "Draw a rune that covers with blood whoever steps on it."

/obj/effect/warped_rune/redspace
	desc = "Watch out for blood!"
	icon_state = "rune_red"
	remove_on_activation = FALSE

/obj/effect/warped_rune/redspace/on_entered(datum/source, atom/movable/AM, oldloc)
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		H.add_blood_DNA(list("Unknown DNA" = random_human_blood_type()))
		for(var/obj/item/I in H.get_equipped_items(INCLUDE_POCKETS))
			I.add_blood_DNA(GET_ATOM_BLOOD_DNA(H))
			I.update_icon()
		for(var/obj/item/I in H.held_items)
			I.add_blood_DNA(GET_ATOM_BLOOD_DNA(H))
			I.update_icon()
		playsound(src, 'sound/effects/blob/blobattack.ogg', 50, TRUE)
		activated_on_step = TRUE
	. = ..()

/obj/item/slimecross/warping/green
	colour = SLIME_TYPE_GREEN
	effect_desc = "Draw a rune that alters the DNA of those who step on it."
	runepath = /obj/effect/warped_rune/greenspace

/obj/effect/warped_rune/greenspace
	desc = "Warning: don't step on this if you want to keep your genes."
	icon_state = "rune_green"
	remove_on_activation = FALSE

/obj/effect/warped_rune/greenspace/on_entered(datum/source, atom/movable/AM, oldloc)
	if(ishuman(AM))
		randomize_human(AM, TRUE)
		activated_on_step = TRUE
	. = ..()

/* pink rune, makes people slightly happier after walking on it*/
/obj/item/slimecross/warping/pink
	colour = SLIME_TYPE_PINK
	effect_desc = "Draws a rune that makes people happier!"
	runepath = /obj/effect/warped_rune/pinkspace

/obj/effect/warped_rune/pinkspace
	desc = "Love is the only reliable source of happiness we have left. But like everything, it comes with a price."
	icon_state = "rune_pink"
	remove_on_activation = FALSE

///adds the jolly mood effect along with hug sound effect.
/obj/effect/warped_rune/pinkspace/on_entered(datum/source, atom/movable/AM, oldloc)
	if(istype(AM, /mob/living/carbon/human))
		var/mob/living/carbon/human/cheerful_human = AM
		playsound(rune_turf, 'sound/items/weapons/thudswoosh.ogg', 50, TRUE)
		cheerful_human.add_mood_event("jolly", /datum/mood_event/jolly)
		to_chat(AM, span_notice("You feel happier."))
		activated_on_step = TRUE
	. = ..()

/obj/item/slimecross/warping/gold
	colour = SLIME_TYPE_GOLD
	runepath = /obj/effect/warped_rune/goldspace
	effect_desc = "Draw a rune that exchanges objects of this dimension for objects of a parallel dimension."

/obj/effect/warped_rune/goldspace
	icon_state = "rune_gold"
	desc = "This can be activated to transmute valuable items into a random item."
	remove_on_activation = FALSE
	var/target_value = 5000
	var/static/list/common_items = list(
		/obj/item/toy/plush/carpplushie,
		/obj/item/toy/plush/bubbleplush,
		/obj/item/toy/plush/ratplush,
		/obj/item/toy/plush/narplush,
		/obj/item/toy/plush/lizard_plushie,
		/obj/item/toy/plush/snakeplushie,
		/obj/item/toy/plush/nukeplushie,
		/obj/item/toy/plush/slimeplushie,
		/obj/item/toy/plush/awakenedplushie,
		/obj/item/toy/plush/beeplushie,
		/obj/item/toy/plush/moth,
		/obj/item/toy/plush/donkpocket,
		/obj/item/toy/plush/whiny_plushie = 2,
		/obj/item/toy/plush/plasmamanplushie,
		/obj/item/toy/plush/shark,
		/obj/item/toy/eightball/haunted,
		/obj/item/toy/foamblade,
		/obj/item/toy/katana,
		/obj/item/toy/snappop/phoenix,
		/obj/item/toy/cards/deck/kotahi,
		/obj/item/toy/redbutton,
		/obj/item/toy/toy_xeno,
		/obj/item/toy/reality_pierce,
		/obj/item/toy/xmas_cracker,
		/obj/item/gun/ballistic/automatic/c20r/toy/unrestricted,
		/obj/item/gun/ballistic/automatic/l6_saw/toy/unrestricted,
		/obj/item/gun/ballistic/automatic/pistol/toy,
		/obj/item/gun/ballistic/shotgun/toy/riot,
		/obj/item/gun/ballistic/shotgun/toy/crossbow,
		/obj/item/clothing/mask/facehugger/toy,
		/obj/item/dualsaber/toy,
		/obj/item/clothing/under/costume/roman,
		/obj/item/clothing/under/costume/pirate,
		/obj/item/clothing/under/costume/kilt/highlander,
		/obj/item/clothing/under/costume/gladiator/ash_walker,
		/obj/item/clothing/under/costume/geisha,
		/obj/item/clothing/under/costume/villain,
		/obj/item/clothing/under/costume/singer/yellow,
		/obj/item/clothing/under/costume/russian_officer
	)

	var/static/list/uncommon_items = list(
		/obj/item/clothing/head/costume/kabuto,
		/obj/item/mod/control/pre_equipped/prototype,
		/obj/item/gun/energy/laser/retro/old,
		/obj/item/storage/toolbox/mechanical/old,
		/obj/item/storage/toolbox/emergency/old,
		/obj/effect/spawner/random/food_or_drink/three_course_meal,
		/mob/living/basic/pet/dog/corgi/puppy/void,
		/obj/structure/closet/crate/necropolis/tendril,
		/obj/item/card/emagfake,
		/obj/item/flashlight/flashdark,
		/mob/living/basic/cat_butcherer
	)

	var/static/list/rare_items = list(
		/obj/effect/spawner/random/contraband/armory,
		/obj/effect/spawner/random/medical/medkit_rare
	)


/obj/effect/warped_rune/goldspace/do_effect(mob/user)
	var/price = 0
	var/list/valuable_items = list()
	for(var/obj/item/I in rune_turf)
		var/datum/export_report/ex = export_item_and_contents(I, dry_run=TRUE)
		for(var/x in ex.total_amount)
			if(ex.total_value[x])
				price += ex.total_value[x]
				valuable_items |= I

	if(price >= target_value)
		remove_on_activation = TRUE
		var/path
		switch(rand(1,100))
			if(1 to 80)
				path = pick(common_items)
			if(80 to 99)
				path = pick(uncommon_items)
			else
				path = pick(rare_items)

		var/atom/movable/A = new path(rune_turf)
		QDEL_LIST(valuable_items)
		to_chat(user, span_notice("[src] shines and [A] appears before you."))
	else
		to_chat(user, span_warning("The sacrifice is insufficient."))
	. = ..()

//oil
/obj/item/slimecross/warping/oil
	colour = SLIME_TYPE_OIL
	runepath = /obj/effect/warped_rune/oilspace
	effect_desc = "Draw a rune that can explode whoever steps on it."
	dangerous = TRUE

/obj/effect/warped_rune/oilspace
	icon_state = "rune_oil"
	desc = "This is basically a mine."
	remove_on_activation = FALSE

/obj/effect/warped_rune/oilspace/on_entered(datum/source, atom/movable/AM, oldloc)
	if(iscarbon(AM))
		var/mob/living/carbon/C = AM
		var/amt = rand(4,12)
		C.reagents.add_reagent(/datum/reagent/water, amt)
		C.reagents.add_reagent(/datum/reagent/potassium, amt)
		activated_on_step = TRUE
	. = ..()

/obj/item/slimecross/warping/black
	colour = SLIME_TYPE_BLACK
	runepath = /obj/effect/warped_rune/blackspace
	effect_desc = "Draw a rune that can transmute weapons with a starborne enchantment."

/obj/effect/warped_rune/blackspace
	icon_state = "rune_black"
	desc = "Every material comes with weakness. Improvement is a matter of finding the least weak."

/obj/effect/warped_rune/blackspace/attack_hand(mob/living/user)
	to_chat(user, span_notice("[src] demands a weapon to enhance."))
	return

/obj/effect/warped_rune/blackspace/attackby(obj/item/attacking_item, mob/living/user, list/modifiers, list/attack_modifiers)
	if(!isliving(user))
		return ..()
	var/obj/item/I = attacking_item
	to_chat(user, span_notice("You begin placing [I] onto [src]."))
	if(do_after(user, 6 SECONDS, target = I))
		if(istype(I, /obj/item) && !istype(I, /obj/item/clothing) && I.force)
			upgrade_weapon(I, user)
			do_effect(user)
			return
		to_chat(user, span_warning("You cannot upgrade [I]."))

/obj/effect/warped_rune/blackspace/proc/upgrade_weapon(obj/item/I, mob/living/user)
	I.add_atom_colour(rgb(243, 227, 183), ADMIN_COLOUR_PRIORITY)
	I.force = round(I.force * 1.15)
	to_chat(user, span_notice("[I] glows with a brilliant light!"))

/obj/item/slimecross/warping/lightpink
	colour = SLIME_TYPE_LIGHT_PINK
	runepath = /obj/effect/warped_rune/lightpinkspace
	effect_desc = "Draw a frog that makes whoever steps on it peaceful."

/obj/effect/warped_rune/lightpinkspace
	desc = "Peace and love."
	icon_state = "rune_light_pink"
	remove_on_activation = FALSE

/obj/effect/warped_rune/lightpinkspace/on_entered(datum/source, atom/movable/AM, oldloc)
	if(iscarbon(AM))
		var/mob/living/carbon/C = AM
		C.reagents.add_reagent(/datum/reagent/pax, 10)
		activated_on_step = TRUE
	. = ..()

/obj/item/slimecross/warping/adamantine
	colour = SLIME_TYPE_ADAMANTINE
	runepath = /obj/effect/warped_rune/adamantinespace
	effect_desc = "Draw a rune that can summon reflective fields."

/obj/effect/warped_rune/adamantinespace
	desc = "This can be activated to summon reflective fields."
	icon_state = "rune_adamantine"

/obj/structure/reflector/box/anchored/mob_pass
	name = "temporary reflector"

/obj/structure/reflector/box/anchored/mob_pass/CanPass(atom/movable/mover, turf/target)
	if(isliving(mover))
		return TRUE
	return ..()

/obj/effect/warped_rune/adamantinespace/do_effect(mob/user)
	for(var/turf/open/T in RANGE_TURFS(1, src) - rune_turf)
		var/obj/structure/reflector/box/anchored/mob_pass/reflector = new(T)
		reflector.set_angle(dir2angle(get_dir(src, reflector)))
		reflector.admin = TRUE
		QDEL_IN(reflector, 30 SECONDS)
	activated_on_step = TRUE
	. = ..()

/obj/item/slimecross/warping/rainbow
	colour = SLIME_TYPE_RAINBOW
	effect_desc = "Draws a rune that teleports whoever is standing on it to a random safe turf."
	runepath = /obj/effect/warped_rune/rainbowspace

/obj/effect/warped_rune/rainbowspace
	icon_state = "rune_rainbow"
	desc = "Step through, and hope the other side is kinder."
	remove_on_activation = FALSE

/obj/effect/warped_rune/rainbowspace/do_effect(mob/user)
	var/turf/destination = find_safe_turf()
	if(!destination)
		to_chat(user, span_warning("The rune flickers but finds nowhere safe to send you."))
		return ..()
	for(var/mob/living/carbon/human/customer in rune_turf)
		do_sparks(3, FALSE, rune_turf)
		customer.forceMove(destination)
	playsound(rune_turf, dir_sound, 20, TRUE)
	. = ..()
