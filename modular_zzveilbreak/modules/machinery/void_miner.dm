/// Void Miner
/// A miner that produces random ores from the void, requires only power and silo link
/obj/machinery/void_miner
	name = "void miner"
	desc = "A mysterious machine that draws materials from the void itself. Requires power and a connection to the ore silo to function."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "stacker"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/void_miner
	idle_power_usage = 200
	active_power_usage = 50000
	processing_flags = START_PROCESSING_ON_INIT

	/// Processing speed in seconds
	var/processing_speed = 6 SECONDS
	/// Remote materials component for silo linking
	var/datum/component/remote_materials/materials
	/// List of all available ores that can be produced
	var/static/list/available_ores = list(
    /obj/item/stack/sheet/iron = 80,
    /obj/item/stack/sheet/glass = 80,
    /obj/item/stack/sheet/plastic = 12,
    /obj/item/stack/sheet/mineral/plasma = 30,
    /obj/item/stack/sheet/mineral/silver = 25,
    /obj/item/stack/sheet/mineral/titanium = 20,
    /obj/item/stack/sheet/mineral/uranium = 15,
    /obj/item/stack/sheet/mineral/gold = 10,
    /obj/item/stack/sheet/mineral/diamond = 5,
    /obj/item/stack/sheet/mineral/plastitanium = 5,
    /obj/item/stack/sheet/bluespace_crystal = 2
)
	COOLDOWN_DECLARE(process_cooldown)

/obj/machinery/void_miner/Initialize(mapload)
	. = ..()
	materials = AddComponent(/datum/component/remote_materials, allow_standalone = FALSE, force_connect = TRUE)
	update_appearance()

/obj/machinery/void_miner/Destroy()
	materials = null
	return ..()

/obj/machinery/void_miner/RefreshParts()
	. = ..()

	processing_speed = 6 SECONDS
	for(var/datum/stock_part/servo/servo_part in component_parts)
		processing_speed -= (servo_part.tier * (0.5 SECONDS))
	processing_speed = CEILING(processing_speed, 1)

/obj/machinery/void_miner/update_overlays()
	. = ..()
	cut_overlays()
	if(panel_open)
		add_overlay("stacker-off")
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if(!materials?.mat_container)
		add_overlay("stacker-off")
		return
	add_overlay("stacker")

/obj/machinery/void_miner/examine(mob/user)
	. = ..()
	if(!materials?.mat_container)
		. += span_warning("[src] requires a connection to the ore silo to function. Use a multitool to link it.")
	if(machine_stat & NOPOWER)
		. += span_warning("[src] requires power to function.")

/obj/machinery/void_miner/proc/check_factors()
	if(!COOLDOWN_FINISHED(src, process_cooldown))
		return FALSE
	COOLDOWN_START(src, process_cooldown, processing_speed)

	// Must be powered
	if(machine_stat & (NOPOWER|BROKEN))
		return FALSE

	// Must be anchored and panel closed
	if(!anchored || panel_open)
		return FALSE

	// Must have silo connection
	if(!materials?.mat_container)
		return FALSE

	return TRUE

/obj/machinery/void_miner/proc/spawn_mats()
	if(!materials?.mat_container)
		return

	var/chosen_ore = pick_weight(available_ores)
	var/obj/item/stack/sheet/chosen_stack = new chosen_ore(null, 1)

	// Insert the stack into the silo
	var/alist/user_data = ID_DATA(null)
	user_data[SILICON_OVERRIDE] = TRUE
	var/insert_result = materials.insert_item(chosen_stack, 1, user_data)

	if(insert_result == MATERIAL_INSERT_ITEM_FAILURE)
		// If insertion failed, drop it on the ground as fallback
		new chosen_ore(get_turf(src))
		visible_message(span_warning("[src] beeps: Silo connection lost, material ejected."))

	qdel(chosen_stack)

/obj/machinery/void_miner/process()
	if(!check_factors())
		return

	spawn_mats()
	playsound(src, 'sound/machines/ping.ogg', 50, FALSE, SILENCED_SOUND_EXTRARANGE, ignore_walls = FALSE)
	update_appearance()

/obj/machinery/void_miner/crowbar_act(mob/living/user, obj/item/tool)
	if(default_deconstruction_crowbar(tool))
		return TRUE

/obj/machinery/void_miner/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/void_miner/screwdriver_act(mob/living/user, obj/item/tool)
	. = TRUE
	if(..())
		return
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, tool))
		update_appearance()
		return
	return FALSE

/obj/item/circuitboard/machine/void_miner
	name = "Void Miner"
	desc = "The circuit board for a void miner."
	greyscale_colors = CIRCUIT_COLOR_GENERIC
	build_path = /obj/machinery/void_miner
	req_components = list(
		/obj/item/stack/sheet/glass = 2,
		/datum/stock_part/matter_bin = 2,
		/datum/stock_part/micro_laser = 1,
		/datum/stock_part/servo = 2,
	)
	needs_anchored = TRUE

/datum/design/board/void_miner
	name = "Machine Design (Void Miner)"
	desc = "Allows for the construction of circuit boards used to build a void miner."
	id = "void_miner"
	build_path = /obj/item/circuitboard/machine/void_miner
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_ENGINEERING
