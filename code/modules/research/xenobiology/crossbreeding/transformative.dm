/*
Transformative extracts:
	Apply a permanent bitflag to a slime (see transformeffects).
	Full gameplay from upstream (extra babies, teleport, ghost polling, etc.) is only partially wired for /mob/living/basic/slime.
*/
/datum/movespeed_modifier/slime_transformative_sepia
	multiplicative_slowdown = -0.35

/obj/item/slimecross/transformative
	name = "transformative extract"
	desc = "It seems to stick to any slime it comes in contact with."
	icon_state = "transformative"
	effect = "transformative"
	var/effect_applied = SLIME_EFFECT_DEFAULT

/obj/item/slimecross/transformative/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!user.Adjacent(interacting_with) || !isslime(interacting_with))
		return NONE
	var/mob/living/basic/slime/slime_target = interacting_with
	if(slime_target.stat == DEAD)
		to_chat(user, span_warning("The slime is dead!"))
		return ITEM_INTERACT_BLOCKING
	if(slime_target.transformeffects & effect_applied)
		to_chat(user, span_warning("This slime already has the [colour] transformative effect applied!"))
		return ITEM_INTERACT_BLOCKING
	to_chat(user, span_notice("You apply [src] to [interacting_with]."))
	do_effect(slime_target, user)
	slime_target.transformeffects |= effect_applied
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/// Undo pieces of previously applied transformative effects before stacking (upstream parity).
/obj/item/slimecross/transformative/proc/do_effect(mob/living/basic/slime/slime_mob, mob/user)
	SHOULD_CALL_PARENT(TRUE)
	if(slime_mob.transformeffects & SLIME_EFFECT_PINK)
		var/datum/language_holder/holder = slime_mob.get_language_holder()
		holder.selected_language = /datum/language/slime

/obj/item/slimecross/transformative/grey
	colour = SLIME_TYPE_GREY
	effect_applied = SLIME_EFFECT_GREY
	effect_desc = "Slimes split into one additional slime. (Partially implemented: reproduces one extra baby.)"

/obj/item/slimecross/transformative/orange
	colour = SLIME_TYPE_ORANGE
	effect_applied = SLIME_EFFECT_ORANGE
	effect_desc = "Slimes will light people on fire when they shock them. (Not yet hooked into basic slime shocks.)"

/obj/item/slimecross/transformative/purple
	colour = SLIME_TYPE_PURPLE
	effect_applied = SLIME_EFFECT_PURPLE
	effect_desc = "Slimes will regenerate slowly. (Not yet implemented for basic slimes.)"

/obj/item/slimecross/transformative/blue
	colour = SLIME_TYPE_BLUE
	effect_applied = SLIME_EFFECT_BLUE
	effect_desc = "Slime will always retain slime of its original colour when splitting. (Not yet implemented.)"

/obj/item/slimecross/transformative/metal
	colour = SLIME_TYPE_METAL
	effect_applied = SLIME_EFFECT_METAL
	effect_desc = "Slimes will be able to sustain more damage before dying."

/obj/item/slimecross/transformative/metal/do_effect(mob/living/basic/slime/slime_mob, mob/user)
	. = ..()
	var/old_max = slime_mob.maxHealth
	slime_mob.maxHealth = round(old_max * 1.3)
	slime_mob.health = clamp(slime_mob.health * (slime_mob.maxHealth / old_max), 1, slime_mob.maxHealth)

/obj/item/slimecross/transformative/yellow
	colour = SLIME_TYPE_YELLOW
	effect_applied = SLIME_EFFECT_YELLOW
	effect_desc = "Slimes will gain electric charge faster. (Not yet implemented.)"

/obj/item/slimecross/transformative/darkpurple
	colour = SLIME_TYPE_DARK_PURPLE
	effect_applied = SLIME_EFFECT_DARK_PURPLE
	effect_desc = "Slime rapidly converts atmospheric plasma to oxygen, healing in the process. (Not yet implemented.)"

/obj/item/slimecross/transformative/darkblue
	colour = SLIME_TYPE_DARK_BLUE
	effect_applied = SLIME_EFFECT_DARK_BLUE
	effect_desc = "Slimes take reduced damage from water. (Not yet implemented.)"

/obj/item/slimecross/transformative/silver
	colour = SLIME_TYPE_SILVER
	effect_applied = SLIME_EFFECT_SILVER
	effect_desc = "Slimes will no longer lose nutrition over time. (Not yet implemented.)"

/obj/item/slimecross/transformative/bluespace
	colour = SLIME_TYPE_BLUESPACE
	effect_applied = SLIME_EFFECT_BLUESPACE
	effect_desc = "Slimes will teleport to targets when they are at full electric charge. (Not yet implemented.)"

/obj/item/slimecross/transformative/sepia
	colour = SLIME_TYPE_SEPIA
	effect_applied = SLIME_EFFECT_SEPIA
	effect_desc = "Slimes move faster."

/obj/item/slimecross/transformative/sepia/do_effect(mob/living/basic/slime/slime_mob, mob/user)
	. = ..()
	slime_mob.add_movespeed_modifier(/datum/movespeed_modifier/slime_transformative_sepia)

/obj/item/slimecross/transformative/cerulean
	colour = SLIME_TYPE_CERULEAN
	effect_applied = SLIME_EFFECT_CERULEAN
	effect_desc = "Slime makes another adult rather than splitting, with half the nutrition. (Not yet implemented.)"

/obj/item/slimecross/transformative/pyrite
	colour = SLIME_TYPE_PYRITE
	effect_applied = SLIME_EFFECT_PYRITE
	effect_desc = "Slime always splits into totally random colors, except rainbow. Can never yield a rainbow slime. (Not yet implemented.)"

/obj/item/slimecross/transformative/red
	colour = SLIME_TYPE_RED
	effect_applied = SLIME_EFFECT_RED
	effect_desc = "Slimes do 10% more damage when feeding and attacking. (Not yet implemented.)"

/obj/item/slimecross/transformative/green
	colour = SLIME_TYPE_GREEN
	effect_applied = SLIME_EFFECT_GREEN
	effect_desc = "Upstream granted an oozeling evolve spell; this fork has no oozeling spell type — flag only."

/obj/item/slimecross/transformative/pink
	colour = SLIME_TYPE_PINK
	effect_applied = SLIME_EFFECT_PINK
	effect_desc = "Slimes will speak in common rather than in slime."

/obj/item/slimecross/transformative/pink/do_effect(mob/living/basic/slime/slime_mob, mob/user)
	. = ..()
	slime_mob.grant_language(/datum/language/common, ALL, LANGUAGE_ATOM)
	var/datum/language_holder/holder = slime_mob.get_language_holder()
	holder.selected_language = /datum/language/common

/obj/item/slimecross/transformative/gold
	colour = SLIME_TYPE_GOLD
	effect_applied = SLIME_EFFECT_GOLD
	effect_desc = "Slime extracts from these will sell for double the price. (Not yet implemented.)"

/obj/item/slimecross/transformative/oil
	colour = SLIME_TYPE_OIL
	effect_applied = SLIME_EFFECT_OIL
	effect_desc = "Slime douses anything it feeds on in welding fuel. (Not yet implemented.)"

/obj/item/slimecross/transformative/black
	colour = SLIME_TYPE_BLACK
	effect_applied = SLIME_EFFECT_BLACK
	effect_desc = "Slime is nearly transparent. (Not yet implemented.)"

/obj/item/slimecross/transformative/lightpink
	colour = SLIME_TYPE_LIGHT_PINK
	effect_applied = SLIME_EFFECT_LIGHT_PINK
	effect_desc = "Upstream allowed ghost polling / playable slime; use a sentience potion on this fork."

/obj/item/slimecross/transformative/lightpink/do_effect(mob/living/basic/slime/slime_mob, mob/user)
	. = ..()
	to_chat(user, span_notice("[slime_mob] may still be offered a intelligence potion for sentience."))

/obj/item/slimecross/transformative/adamantine
	colour = SLIME_TYPE_ADAMANTINE
	effect_applied = SLIME_EFFECT_ADAMANTINE
	effect_desc = "Slimes take reduced damage from brute attacks. (Not yet implemented.)"

/obj/item/slimecross/transformative/rainbow
	colour = SLIME_TYPE_RAINBOW
	effect_applied = SLIME_EFFECT_RAINBOW
	effect_desc = "Slime randomly changes color periodically. (Not yet implemented.)"
