//Exile implants will allow you to use the station gate, but not return home.
//This will allow security to exile badguys/for badguys to exile their kill targets

/obj/item/implant/exile
	name = "exile implant"
	desc = "Prevents you from returning from away missions."
	actions_types = null
	implant_flags = IMPLANT_TYPE_SECURITY
	hud_icon_state = "hud_imp_exile"

	implant_info = "Automatically activates upon implantation. \
		Prevents returning through Nanotrasen gateway systems, and prevents usage of Nanotrasen mining shuttle controls."

	implant_lore = "The Nanotrasen Employee Exile Implant is an RFID transponder \
		designed to facilitate one-way traversal through Nanotrasen Gateway Project gateways. \
		It allows implantees to enter, but not exit, gateway locales, automatically rejecting traversal attempts if an attempt is made, \
		effectively exiling them to the gateway's locale. \
		Alongside this, the exile implant interfaces with Nanotrasen mining shuttle control systems, automatically locking \
		themselves down if implantees attempt to use them."

///Used to help the staff of the space hotel resist the urge to use the space hotel's incredibly alluring roundstart teleporter to ignore their flavor/greeting text and come to the station.
/obj/item/implant/exile/noteleport
	name = "anti-teleportation implant"
	desc = "Uses impressive bluespace grounding techniques to deny the person implanted by this implant the ability to teleport or be teleported. \
		Used by certain slavers, or particularly strict employers, to keep their slaves or employees from using teleporters to escape their grasp."

	implant_info = "Automatically activates upon implantation. \
		Mimics an exile implant, preventing returning from a gateway locale and locking down Nanotrasen mining shuttles, \
		while also preventing teleportation."

	implant_lore = "The Sunken Anchor anti-teleportation implant is a subdermal anti-teleportation device that prevents usage of \
		conventional and unconventional methods of teleporting, in order to prevent employees \
		or slaves from using unauthorized means of teleportation to abandon their posts. \
		In addition, the Sunken Anchor mimics the signature of Nanotrasen's exile implant, \
		preventing returning through Nanotrasen Gateway Project gateways and locking implantees out of using Nanotrasen's mining shuttles. \
		The ethics behind having this implant are questionable. The efficacy of the implant itself is not."

/obj/item/implant/exile/noteleport/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(!. || !isliving(target))
		return FALSE
	var/mob/living/living_target = target
	ADD_TRAIT(living_target, TRAIT_NO_TELEPORT, IMPLANT_TRAIT)
	return TRUE

/obj/item/implant/exile/noteleport/removed(mob/target, silent = FALSE, special = FALSE)
	. = ..()
	if(!. || !isliving(target))
		return FALSE
	var/mob/living/living_target = target
	REMOVE_TRAIT(living_target, TRAIT_NO_TELEPORT, IMPLANT_TRAIT)
	return TRUE

/obj/item/implanter/exile
	name = "implanter (exile)"
	imp_type = /obj/item/implant/exile

/obj/item/implanter/exile/noteleport
	name = "implanter (anti-teleportation)"
	imp_type = /obj/item/implant/exile/noteleport

/obj/item/implantcase/exile
	name = "implant case - 'Exile'"
	desc = "A glass case containing an exile implant."
	imp_type = /obj/item/implant/exile

/obj/item/implantcase/exile/noteleport
	name = "implant case - 'Anti-Teleportation'"
	desc = "A glass case containing an anti-teleportation implant."
	imp_type = /obj/item/implant/exile/noteleport

// VEILBREAK/SPLURT fork sync: procs present in fork but missing from upstream (auto-restored)
/obj/item/implant/exile/get_data()
	return "<b>Implant Specifications:</b><BR> \
		<b>Name:</b> Nanotrasen Employee Exile Implant<BR> \
		<b>Implant Details:</b> The onboard gateway system has been modified to reject entry by individuals containing this implant. \
		Additionally, station mining shuttles will lock their controls if handled by someone with this implant.<BR>"


///Used to help the staff of the space hotel resist the urge to use the space hotel's incredibly alluring roundstart teleporter to ignore their flavor/greeting text and come to the station.

/obj/item/implant/exile/noteleport/get_data()
	return "<b>Implant Specifications:</b><BR> \
		<b>Name:</b> Anti-Teleportation Implant<BR> \
		<b>Implant Details:</b> Keeps the implantee from using most teleportation devices. In addition, it spoofs the implant signature of an exile implant to keep the implantee from using certain gateway systems.<BR>"
