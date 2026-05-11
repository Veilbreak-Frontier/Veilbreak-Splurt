/obj/item/gun/syringe/crossbow
	name = "crusader crossbow"
	desc = "A powerful, single-shot medical crossbow. High-pressure delivery ensures the payload reaches the patient."
	icon = 'modular_zzveilbreak/icons/item_icons/crusader_crossbow_icons.dmi'
	lefthand_file = 'modular_zzveilbreak/icons/item_icons/crusader_crossbow_inhands.dmi'
	righthand_file = 'modular_zzveilbreak/icons/item_icons/crusader_crossbow_inhands.dmi'
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	pixel_w = -8
	base_pixel_x = -8
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	max_syringes = 1
	force = 4
	throw_speed = 3
	throw_range = 7
	has_syringe_overlay = FALSE
	layer = OBJ_LAYER
	plane = GAME_PLANE
	appearance_flags = KEEP_TOGETHER | LONG_GLIDE | TILE_BOUND

/obj/item/gun/syringe/crossbow/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/gun/syringe/crossbow/update_appearance(updates)
	. = ..()
	var/base = initial(icon_state)
	var/loaded_check = (syringes.len || chambered) ? "_l" : "_u"
	icon_state = "[base][loaded_check]"

	if(ismob(loc))
		var/matrix/M = matrix()
		M.Scale(0.66)
		transform = M
	else
		transform = null

/obj/item/gun/syringe/crossbow/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_HANDS)
		pixel_w = 0
		pixel_x = 0
		overlays.Cut()
		transform = null
	else
		pixel_w = -8
		pixel_x = base_pixel_x
		update_appearance()

/obj/item/gun/syringe/crossbow/dropped(mob/user)
	. = ..()
	pixel_w = -8
	pixel_x = base_pixel_x
	update_appearance()

/obj/item/gun/syringe/crossbow/wood/red
	name = "royal wooden crossbow (red)"
	icon_state = "wood_red"
	inhand_icon_state = "wood_red"

/obj/item/gun/syringe/crossbow/wood/blue
	name = "royal wooden crossbow (blue)"
	icon_state = "wood_blue"
	inhand_icon_state = "wood_blue"

/obj/item/gun/syringe/crossbow/matte/red
	name = "tactical matte crossbow (red)"
	icon_state = "matte_red"
	inhand_icon_state = "matte_red"

/obj/item/gun/syringe/crossbow/matte/blue
	name = "Cerulean Surgeon"
	desc = "A matte-black medical crossbow with chilling azure accents. Designed for the steady, cold-blooded precision of a serpentine prince, it delivers treatment with the swiftness of a striking viper."
	icon_state = "matte_blue"
	inhand_icon_state = "matte_blue"

/datum/design/crusader_crossbow
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 3, /datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT)
	category = list(RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_CHEMISTRY)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/crusader_crossbow/wood_red
	name = "Royal Crossbow (Red-Trimmed Wood)"
	desc = "A single-shot medical crossbow with a polished wooden stock and crimson accents."
	id = "crusader_crossbow_wood_red"
	build_path = /obj/item/gun/syringe/crossbow/wood/red

/datum/design/crusader_crossbow/wood_blue
	name = "Royal Crossbow (Blue-Trimmed Wood)"
	desc = "A single-shot medical crossbow with a polished wooden stock and azure accents."
	id = "crusader_crossbow_wood_blue"
	build_path = /obj/item/gun/syringe/crossbow/wood/blue

/datum/design/crusader_crossbow/matte_red
	name = "Tactical Crossbow (Red-Trimmed Matte)"
	desc = "A single-shot medical crossbow with a matte black finish and crimson accents."
	id = "crusader_crossbow_matte_red"
	build_path = /obj/item/gun/syringe/crossbow/matte/red

/datum/loadout_item/inhand/cerulean_surgeon
	name = "Cerulean Surgeon"
	item_path = /obj/item/gun/syringe/crossbow/matte/blue
	ckeywhitelist = list("nuetterden")
