// This file overrides the shielded component's overlay proc so that MODsuit energy shields render above mutant bodyparts instead of being occluded by them.
// It exists because MOB_SHIELD_LAYER (4.01) sits below BODY_BEHIND_LAYER (35.2), causing tails, wings, horns, and other mutant features to draw over the shield's blue lattice.

/datum/component/shielded/on_update_overlays(atom/parent_atom, list/overlays)
	SIGNAL_HANDLER

	var/shield_layer = MOB_SHIELD_LAYER
	if(istype(parent, /obj/item/mod/control))
		shield_layer = BODY_BEHIND_LAYER + 0.1

	var/mutable_appearance/shield_appearance = mutable_appearance(shield_icon_file, (current_charges > 0 ? shield_icon : "broken"), shield_layer)
	if(show_charge_as_alpha)
		shield_appearance.alpha = (current_charges/max_charges)*255
	overlays += shield_appearance
