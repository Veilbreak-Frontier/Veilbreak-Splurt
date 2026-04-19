/mob/living
	var/list/all_powers = list()
	/// world.time when TRAIT_USER_SCOPED was first gained; used by Precision Killer.
	var/veilbreak_sniper_scope_start

/mob/living/carbon/human
	/// Weakref to /datum/mind of the leader who designated this mob (Leadership power).
	var/datum/weakref/veilbreak_leadership_leader_ref

/datum/mind
	/// Weakrefs to /mob/living/carbon/human allies (max 3) for Leadership.
	var/list/veilbreak_leadership_allies

GLOBAL_DATUM_INIT(power_handler, /datum/power_handler, new)

/obj/item/organ/resonant
	slot = ORGAN_SLOT_RESONANT

/datum/power_handler/New()
	RegisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED, PROC_REF(handle_new_player))

/datum/power_handler/proc/handle_new_player(datum/source, mob/living/carbon/human/new_crewmember, rank)
	SIGNAL_HANDLER
	if(!istype(new_crewmember))
		return
	if(isnull(new_crewmember.mind))
		return
	var/datum/preferences/prefs = new_crewmember.client?.prefs
	if(isnull(prefs))
		return
	apply_powers(new_crewmember, prefs)

/datum/power_handler/proc/apply_powers(mob/living/carbon/human/target, datum/preferences/preferences, visuals_only = FALSE)
	var/list/power_types = list()
	for(var/power_name in preferences.powers)
		var/datum/power/power_to_add = preferences.powers[power_name]
		power_to_add = new power_to_add()
		power_to_add.apply_to_human(target)
		var/core_power_type = get_path_type(power_to_add.power_type)
		if(core_power_type && !(core_power_type in power_types))
			power_types += core_power_type
		qdel(power_to_add)
	for(var/core_power in power_types)
		var/datum/power/powah_to_add = GLOB.path_core_powers[core_power]
		powah_to_add = new powah_to_add()
		powah_to_add.apply_to_human(target)
		qdel(powah_to_add)

/datum/power_handler/Destroy()
	UnregisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED)
	return ..()

/datum/power
	var/name
	var/desc
	var/cost
	var/power_type
	var/advanced = FALSE
	var/list/power_traits = list()
	var/datum/power/root_power
	var/list/blacklist = list()
	var/is_accessible = TRUE
	var/gain_text
	var/list/required_powers = list()

/datum/power/proc/apply_to_human(mob/living/carbon/human/target)
	if(!target)
		CRASH("Power attempted to be added to null mob.")
	if(target.has_powerz(type))
		CRASH("Power attempted to be added to mob which already has this power.")
	target.all_powers += src
	if(power_traits)
		for(var/add_trait in power_traits)
			ADD_TRAIT(target, add_trait, TRAIT_POWER)
	if(gain_text)
		to_chat(target, gain_text)
	ADD_TRAIT(target, power_type, TRAIT_POWER)
	ADD_TRAIT(target, get_path_type(power_type), TRAIT_POWER)
	add(target)

/mob/living/proc/has_powerz(power_type)
	for(var/datum/power/power in all_powers)
		if(power.type == power_type)
			return TRUE
	return FALSE

/datum/power/proc/add(mob/living/carbon/human/target)
	return

/datum/power/item
	var/list/where_items_spawned
	var/open_backpack

/datum/power/item/proc/give_item_to_holder(mob/living/carbon/human/target, obj/item/power_item, list/valid_slots, flavour_text = null, default_location = "at your feet", notify_player = TRUE)
	if(ispath(power_item))
		power_item = new power_item(get_turf(target))
	var/where = target.equip_in_one_of_slots(power_item, valid_slots, qdel_on_fail = FALSE, indirect_action = TRUE) || default_location
	if(where == LOCATION_BACKPACK)
		open_backpack = TRUE
	if(notify_player)
		LAZYADD(where_items_spawned, span_boldnotice("You have \a [power_item] [where]. [flavour_text]"))
	if(open_backpack && target.back)
		target.back.atom_storage.show_contents(target)
	for(var/chat_string in where_items_spawned)
		to_chat(target, chat_string)
	where_items_spawned = null
