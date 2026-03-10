/datum/loadout_item/toys/nobl_plush
	ckeywhitelist = null //request of the donator

/datum/loadout_item/toys/nobl_plush/New(category)
	ckeywhitelist = null //idk why the above override doesn't work
	. = ..()

/datum/loadout_item/toys/plushie_panic
	name = "Tired Raccoon Plushie"
	item_path = /obj/item/toy/plush/panic
	ckeywhitelist = null

/datum/loadout_item/toys/plushie_mossy
	name = "Ethereal Skulldog Plushie"
	item_path = /obj/item/toy/plush/mossy
	ckeywhitelist = null

/datum/loadout_item/toys/plushie_tree_ferret
	name = "Tree Ferret Plushie"
	item_path = /obj/item/toy/plush/tree_ferret
	ckeywhitelist = null

/datum/loadout_item/toys/plush_bro
	name = "Homeboy Plush"
	item_path = /obj/item/toy/plush/plush_bro
	ckeywhitelist = null

/datum/loadout_item/toys/toaste_plushy
	name = "Marketable Toaste Plushie"
	item_path = /obj/item/toy/plush/toaste_plushy
	ckeywhitelist = null

/datum/loadout_item/toys/sindri_plush
	name = "Incuboi Plushie"
	item_path = /obj/item/toy/plush/incuboi
	ckeywhitelist = null

/datum/loadout_item/toys/red_mut
	name = "Marketable Mutt Plushie"
	item_path = /obj/item/toy/plush/red_mut
	ckeywhitelist = null

/datum/loadout_item/toys/mori
	name = "SOB Kit"
	item_path = /obj/item/storage/medkit/kit
	ckeywhitelist = list("Mottedesstriets")

/obj/item/storage/medkit/kit
	icon_state = "oldfirstaid"
	desc = "An old first aid kit used for storage now."

/obj/item/storage/medkit/kit/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/skillchip/self_surgery = 1,
		/obj/item/modular_computer/pda/pip = 1)
	generate_items_inside(items_inside,src)

/obj/item/modular_computer/pda/pip
	name = "Custom Yip-Boi 6000"
	icon = 'modular_zzplurt/icons/obj/yipbuddy.dmi'
	icon_state = "yipboy"
	post_init_icon_state = null
	greyscale_config = null
	greyscale_colors = null
	long_ranged = TRUE
