/obj/item/clothing/accessory/bodycam
	name = "security bodycam"
	desc = "A small, rugged camera designed to be worn on the chest. Streams video to the station's camera network."
	icon_state = "press_badge"
	var/camera_network = "SS13"
	var/c_tag_prefix = "Bodycam"
	var/datum/component/simple_bodycam/cam_component

/obj/item/clothing/accessory/bodycam/accessory_equipped(obj/item/clothing/under/clothes, mob/living/user)
	if(user)
		cam_component = user.AddComponent(/datum/component/simple_bodycam, \
			camera_name = "[c_tag_prefix] ([user.real_name])", \
			c_tag = "[c_tag_prefix] ([user.real_name])", \
			network = camera_network, \
			emp_proof = FALSE)

/obj/item/clothing/accessory/bodycam/accessory_dropped(obj/item/clothing/under/clothes, mob/living/user)
	if(cam_component)
		qdel(cam_component)
		cam_component = null

/obj/item/clothing/accessory/bodycam/head
	name = "command bodycam"
	desc = "A small, rugged camera designed to be worn on the chest. Streams video to the station's camera network."
	camera_network = "COMMAND"
	c_tag_prefix = "Command Bodycam"