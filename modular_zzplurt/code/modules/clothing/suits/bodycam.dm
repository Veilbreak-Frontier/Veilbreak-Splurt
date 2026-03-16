// SPLURT bodycam implementation
// Adds a wearable body camera for security personnel

// Use the standard security network so it shows up on security camera consoles
#define BODYCAM_NETWORK CAMERANET_NETWORK_SS13

/obj/item/clothing/suit/bodycam
	name = "security bodycam"
	desc = "A wearable camera for security personnel. Toggle recording with double-click. View footage through security camera consoles."
	icon = 'icons/obj/clothing/suits/default.dmi'
	icon_state = "bodycam_off"
	worn_icon = 'icons/mob/clothing/suits/default.dmi'
	inhand_icon_state = "bodycam"
	slot_flags = ITEM_SLOT_OCLOTHING
	body_parts_covered = CHEST
	/// Whether the camera is currently recording
	var/recording = FALSE

/obj/item/clothing/suit/bodycam/examine(mob/user)
	. = ..()
	. += "It is currently [recording ? "recording" : "not recording"]."
	. += "Double-click to toggle recording."

/obj/item/clothing/suit/bodycam/double_click(mob/user)
	var/mob/wearer = loc
	
	if(!istype(wearer) || wearer != user)
		to_chat(user, span_warning("You need to be wearing the bodycam to use it."))
		return

	toggle_recording(user)

/obj/item/clothing/suit/bodycam/proc/toggle_recording(mob/user)
	recording = !recording
	
	if(recording)
		enable_camera(user)
	else
		disable_camera(user)

/obj/item/clothing/suit/bodycam/proc/enable_camera(mob/user)
	var/mob/wearer = loc
	if(!istype(wearer))
		return
	
	// Add the bodycam component to the wearer
	wearer.AddComponent( \
		/datum/component/simple_bodycam, \
		camera_name = "bodycam", \
		c_tag = "[wearer.real_name]'s bodycam", \
		network = BODYCAM_NETWORK, \
		emp_proof = TRUE, \
	)
	
	icon_state = "bodycam_on"
	update_icon()
	
	to_chat(user, span_notice("You turn on the bodycam. It is now recording."))
	playsound(src, 'sound/machines/click.ogg', 30, TRUE)

/obj/item/clothing/suit/bodycam/proc/disable_camera(mob/user)
	var/mob/wearer = loc
	if(!istype(wearer))
		return
	
	// Remove all simple_bodycam components from the wearer
	for(var/datum/component/simple_bodycam/cam in wearer.GetComponents(/datum/component/simple_bodycam))
		qdel(cam)
	
	icon_state = "bodycam_off"
	update_icon()
	
	to_chat(user, span_notice("You turn off the bodycam. Recording stopped."))
	playsound(src, 'sound/machines/click.ogg', 30, TRUE)

/obj/item/clothing/suit/bodycam/equipped(mob/user, slot)
	. = ..()
	if(slot == slot_wear_suit && recording)
		enable_camera(user)

/obj/item/clothing/suit/bodycam/dropped(mob/user)
	. = ..()
	if(recording)
		disable_camera(user)

/obj/item/clothing/suit/bodycam/update_icon()
	. = ..()
	if(recording)
		set_light(1, 1, LIGHT_COLOR_RED)
	else
		set_light(0)

#undef BODYCAM_NETWORK
