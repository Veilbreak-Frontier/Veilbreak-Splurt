/// VOREStation-inspired NIFSofts adapted to Veilbreak's existing organ-based NIF framework.

#define VEILBREAK_NIFSOFT_PROCESS_COST 1
#define VEILBREAK_RESPIROCYTE_MAX_RESERVE 100

/datum/nifsoft/proc/nifsoft_process(seconds_per_tick)
	return TRUE

/datum/nifsoft/proc/get_parent_nif()
	RETURN_TYPE(/obj/item/organ/cyberimp/brain/nif)
	return parent_nif?.resolve()

/datum/nifsoft/proc/use_nif_power(amount)
	var/obj/item/organ/cyberimp/brain/nif/installed_nif = get_parent_nif()
	return installed_nif?.change_power_level(amount)

/obj/item/organ/cyberimp/brain/nif/process(seconds_per_tick)
	. = ..()
	if(!. || !linked_mob || broken || calibrating)
		return

	for(var/datum/nifsoft/installed_nifsoft as anything in loaded_nifsofts)
		installed_nifsoft.nifsoft_process(seconds_per_tick)

/obj/item/organ/cyberimp/brain/nif/remove_nifsoft(datum/nifsoft/removed_nifsoft, silent = FALSE)
	if(istype(removed_nifsoft, /datum/nifsoft/vore/compliance))
		send_message("Compliance Module removal refused.", TRUE)
		return FALSE

	return ..()

/datum/nifsoft/vore
	purchase_price = 300
	buying_category = NIFSOFT_CATEGORY_UTILITY
	able_to_keep = TRUE

/datum/nifsoft/vore/medichines
	name = "Medichines"
	program_desc = "An internal swarm of medical nanites that automatically spends NIF charge to stabilize and slowly repair an injured host."
	purchase_price = 1250
	buying_category = NIFSOFT_CATEGORY_UTILITY
	ui_icon = "staff-snake"
	rewards_points_rate = 0.25
	/// The health ratio below which the soft begins drawing charge.
	var/activation_threshold = 0.9
	/// The health ratio below which the soft gives emergency warnings.
	var/critical_threshold = 0.2
	var/last_warned_state = 0

/datum/nifsoft/vore/medichines/nifsoft_process(seconds_per_tick)
	if(!linked_mob || linked_mob.stat == DEAD)
		return FALSE

	var/health_ratio = linked_mob.health / linked_mob.maxHealth
	if(health_ratio >= activation_threshold)
		if(last_warned_state)
			var/obj/item/organ/cyberimp/brain/nif/installed_nif = get_parent_nif()
			installed_nif?.send_message("User status normal. Medichines standing by.")
		last_warned_state = 0
		return TRUE

	if(!use_nif_power(VEILBREAK_NIFSOFT_PROCESS_COST))
		return FALSE

	if(!last_warned_state)
		var/obj/item/organ/cyberimp/brain/nif/installed_nif = get_parent_nif()
		installed_nif?.send_message("User injury detected. Commencing medichine routines.", TRUE)
		last_warned_state = 1

	if(health_ratio <= critical_threshold && last_warned_state < 2)
		var/obj/item/organ/cyberimp/brain/nif/installed_nif = get_parent_nif()
		installed_nif?.send_message("User status critical. Seek medical attention immediately.", TRUE)
		last_warned_state = 2

	linked_mob.adjust_brute_loss(-0.35 * seconds_per_tick)
	linked_mob.adjust_fire_loss(-0.35 * seconds_per_tick)
	linked_mob.adjust_tox_loss(-0.2 * seconds_per_tick)
	linked_mob.adjust_oxy_loss(-0.2 * seconds_per_tick)
	return TRUE

/obj/item/disk/nifsoft_uploader/vore_medichines
	name = "Medichines NIFSoft datadisk"
	loaded_nifsoft = /datum/nifsoft/vore/medichines

/datum/nifsoft/vore/respirocytes
	name = "Respirocytes"
	program_desc = "Nanites simulating red blood cells recycle enough oxygen to protect the user from short periods without breathable air."
	purchase_price = 325
	active_mode = TRUE
	active_cost = 0.2
	activation_cost = 5
	ui_icon = "wind"
	var/filled = VEILBREAK_RESPIROCYTE_MAX_RESERVE

/datum/nifsoft/vore/respirocytes/activate()
	if(!active && filled < (VEILBREAK_RESPIROCYTE_MAX_RESERVE * 0.5))
		var/obj/item/organ/cyberimp/brain/nif/installed_nif = get_parent_nif()
		installed_nif?.send_message("Respirocytes are not sufficiently saturated.", TRUE)
		return FALSE

	return ..()

/datum/nifsoft/vore/respirocytes/nifsoft_process(seconds_per_tick)
	if(!linked_mob)
		return FALSE

	var/obj/item/organ/cyberimp/brain/nif/installed_nif = get_parent_nif()
	if(active)
		if(filled <= 0)
			installed_nif?.send_message("Respirocyte reserve depleted.", TRUE)
			activate()
			return FALSE

		filled = max(0, filled - seconds_per_tick)
		linked_mob.losebreath = 0
		linked_mob.adjust_oxy_loss(-2 * seconds_per_tick)
		return TRUE

	if(filled >= VEILBREAK_RESPIROCYTE_MAX_RESERVE)
		return TRUE

	if(use_nif_power(VEILBREAK_NIFSOFT_PROCESS_COST))
		filled = min(VEILBREAK_RESPIROCYTE_MAX_RESERVE, filled + (2 * seconds_per_tick))
		if(filled >= VEILBREAK_RESPIROCYTE_MAX_RESERVE)
			installed_nif?.send_message("Respirocytes are fully saturated.")

	return TRUE

/obj/item/disk/nifsoft_uploader/vore_respirocytes
	name = "Respirocytes NIFSoft datadisk"
	loaded_nifsoft = /datum/nifsoft/vore/respirocytes

/datum/nifsoft/vore/pressure_seals
	name = "Pressure Seals"
	program_desc = "Forms nanite pressure seals around vulnerable components, protecting the user while the soft remains active."
	purchase_price = 875
	active_mode = TRUE
	active_cost = 0.5
	activation_cost = 10
	ui_icon = "gauge-high"

/datum/nifsoft/vore/pressure_seals/activate()
	. = ..()
	if(. == FALSE)
		return FALSE

	if(active)
		linked_mob.add_traits(list(TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTHIGHPRESSURE), TRAIT_NIFSOFT)
		return TRUE

	linked_mob.remove_traits(list(TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTHIGHPRESSURE), TRAIT_NIFSOFT)
	return TRUE

/datum/nifsoft/vore/pressure_seals/Destroy()
	if(linked_mob)
		linked_mob.remove_traits(list(TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTHIGHPRESSURE), TRAIT_NIFSOFT)
	return ..()

/obj/item/disk/nifsoft_uploader/vore_pressure_seals
	name = "Pressure Seals NIFSoft datadisk"
	loaded_nifsoft = /datum/nifsoft/vore/pressure_seals

/datum/nifsoft/vore/heat_sinks
	name = "Heat Sinks"
	program_desc = "Nanite heat sinks buffer thermal extremes and fire exposure while the soft remains active."
	purchase_price = 725
	active_mode = TRUE
	active_cost = 0.35
	activation_cost = 10
	ui_icon = "temperature-high"

/datum/nifsoft/vore/heat_sinks/activate()
	. = ..()
	if(. == FALSE)
		return FALSE

	if(active)
		linked_mob.add_traits(list(TRAIT_RESISTHEAT, TRAIT_NOFIRE), TRAIT_NIFSOFT)
		return TRUE

	linked_mob.remove_traits(list(TRAIT_RESISTHEAT, TRAIT_NOFIRE), TRAIT_NIFSOFT)
	return TRUE

/datum/nifsoft/vore/heat_sinks/Destroy()
	if(linked_mob)
		linked_mob.remove_traits(list(TRAIT_RESISTHEAT, TRAIT_NOFIRE), TRAIT_NIFSOFT)
	return ..()

/obj/item/disk/nifsoft_uploader/vore_heat_sinks
	name = "Heat Sinks NIFSoft datadisk"
	loaded_nifsoft = /datum/nifsoft/vore/heat_sinks

/datum/nifsoft/vore/apc_connector
	name = "APC Connector"
	program_desc = "Deploys a short-range nanite tether that converts APC charge into nutrition while the user remains adjacent."
	purchase_price = 625
	active_mode = TRUE
	active_cost = 0
	activation_cost = 0
	ui_icon = "plug"
	var/obj/machinery/power/apc/connected_apc

/datum/nifsoft/vore/apc_connector/activate()
	if(!active)
		connected_apc = locate(/obj/machinery/power/apc) in get_step(linked_mob, linked_mob.dir)
		if(!connected_apc)
			connected_apc = locate(/obj/machinery/power/apc) in get_turf(linked_mob)
		if(!connected_apc)
			var/obj/item/organ/cyberimp/brain/nif/installed_nif = get_parent_nif()
			installed_nif?.send_message("Face or stand beside an APC to connect.", TRUE)
			return FALSE

	. = ..()
	if(. == FALSE)
		connected_apc = null
		return FALSE

	if(!active)
		connected_apc = null

	return TRUE

/datum/nifsoft/vore/apc_connector/nifsoft_process(seconds_per_tick)
	if(!active || !connected_apc || !linked_mob)
		return TRUE

	if(get_dist(linked_mob, connected_apc) > 1)
		var/obj/item/organ/cyberimp/brain/nif/installed_nif = get_parent_nif()
		installed_nif?.send_message("APC connector tether severed.")
		activate()
		return FALSE

	if(!connected_apc.avail(150 * seconds_per_tick))
		var/obj/item/organ/cyberimp/brain/nif/installed_nif = get_parent_nif()
		installed_nif?.send_message("APC connector lost access to station power.")
		activate()
		return FALSE

	linked_mob.nutrition = min(linked_mob.nutrition + (10 * seconds_per_tick), NUTRITION_LEVEL_FED)
	connected_apc.add_load(150 * seconds_per_tick)
	return TRUE

/datum/nifsoft/vore/apc_connector/Destroy()
	connected_apc = null
	return ..()

/obj/item/disk/nifsoft_uploader/vore_apc_connector
	name = "APC Connector NIFSoft datadisk"
	loaded_nifsoft = /datum/nifsoft/vore/apc_connector

/datum/nifsoft/vore/compliance
	name = "Compliance Module"
	program_desc = "An illegal coercive module that presents a persistent set of directives to the user and refuses normal removal."
	purchase_price = 8200
	buying_category = NIFSOFT_CATEGORY_GENERAL
	ui_icon = "scale-balanced"
	rewards_points_eligible = FALSE
	var/laws = "Be nice to people!"

/datum/nifsoft/vore/compliance/activate()
	. = ..()
	if(. == FALSE)
		return FALSE

	to_chat(linked_mob, span_danger("You are compelled to follow these rules:"))
	to_chat(linked_mob, span_notice(laws))
	return TRUE

/datum/nifsoft/vore/compliance/New(obj/item/organ/cyberimp/brain/nif/recipient_nif, no_rewards_points = FALSE, new_laws)
	if(new_laws)
		laws = new_laws
	return ..()

/obj/item/disk/nifsoft_uploader/vore_compliance
	name = "Compliance Module NIFSoft datadisk"
	loaded_nifsoft = /datum/nifsoft/vore/compliance
	var/laws

/obj/item/disk/nifsoft_uploader/vore_compliance/attack_self(mob/user, modifiers)
	var/new_laws = tgui_input_text(user, "Please input compliance laws.", "Compliance Laws", laws, 2048, TRUE, prevent_enter = TRUE)
	if(new_laws)
		laws = new_laws
		balloon_alert(user, "laws set")
		return TRUE

	return ..()

/obj/item/disk/nifsoft_uploader/vore_compliance/attempt_software_install(mob/living/carbon/human/target)
	var/obj/item/organ/cyberimp/brain/nif/installed_nif = target.get_organ_by_type(/obj/item/organ/cyberimp/brain/nif)
	if(!ishuman(target) || !installed_nif || !laws)
		balloon_alert(target, "installation failed")
		return FALSE

	var/datum/nifsoft/installed_nifsoft = new loaded_nifsoft(installed_nif, TRUE, laws)
	if(!installed_nifsoft.parent_nif)
		balloon_alert(target, "installation failed")
		return FALSE

	if(!reusable)
		qdel(src)

/datum/nifsoft/vore/mass_alteration
	name = "Mass Alteration"
	program_desc = "Rearranges the user's mass to set a new body scale within the server's normal body-size limits."
	purchase_price = 300
	active_mode = TRUE
	activation_cost = 10
	buying_category = NIFSOFT_CATEGORY_FUN
	ui_icon = "up-right-and-down-left-from-center"

/datum/nifsoft/vore/mass_alteration/activate()
	. = ..()
	if(. == FALSE)
		return FALSE

	if(!linked_mob?.dna || linked_mob.dna.species.body_size_restricted)
		var/obj/item/organ/cyberimp/brain/nif/installed_nif = get_parent_nif()
		installed_nif?.send_message("Mass alteration is incompatible with this body.", TRUE)
		refund_activation_cost()
		return FALSE

	var/new_size_percent = tgui_input_number(linked_mob, "Choose desired size ([BODY_SIZE_MIN * 100]-[BODY_SIZE_MAX * 100]%).", "Set Size", linked_mob.dna.features["body_size"] * 100, BODY_SIZE_MAX * 100, BODY_SIZE_MIN * 100)
	if(!new_size_percent)
		refund_activation_cost()
		return FALSE

	var/new_size = clamp(new_size_percent * 0.01, BODY_SIZE_MIN, BODY_SIZE_MAX)
	if(linked_mob.update_size(new_size))
		linked_mob.visible_message(span_warning("Swirling streams of nanites envelop [linked_mob] as [linked_mob.p_they()] change size!"), span_notice("Swirling streams of nanites wrap around you as your size changes."))

	if(active)
		activate()
	return TRUE

/obj/item/disk/nifsoft_uploader/vore_mass_alteration
	name = "Mass Alteration NIFSoft datadisk"
	loaded_nifsoft = /datum/nifsoft/vore/mass_alteration

/datum/nifsoft/vore/painkillers
	name = "Nova Shock"
	program_desc = "An illegal painkiller routine that doses the user with morphine while active."
	purchase_price = 2600
	active_mode = TRUE
	active_cost = 1
	activation_cost = 15
	ui_icon = "pills"
	rewards_points_eligible = FALSE

/datum/nifsoft/vore/painkillers/nifsoft_process(seconds_per_tick)
	if(!active || !linked_mob?.reagents)
		return TRUE

	if(linked_mob.reagents.get_reagent_amount(/datum/reagent/medicine/morphine) < 8)
		linked_mob.reagents.add_reagent(/datum/reagent/medicine/morphine, 0.4 * seconds_per_tick)

	return TRUE

/obj/item/disk/nifsoft_uploader/vore_painkillers
	name = "Nova Shock NIFSoft datadisk"
	loaded_nifsoft = /datum/nifsoft/vore/painkillers

/datum/nifsoft/vore/armor
	name = "Bullhide Mod"
	program_desc = "A combat-grade dermal reinforcement routine that reduces incoming brute trauma while active."
	purchase_price = 3200
	active_mode = TRUE
	active_cost = 0.5
	activation_cost = 20
	buying_category = NIFSOFT_CATEGORY_GENERAL
	ui_icon = "shield-halved"
	rewards_points_eligible = FALSE

/datum/nifsoft/vore/armor/activate()
	. = ..()
	if(. == FALSE)
		return FALSE

	if(active)
		RegisterSignal(linked_mob, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS, PROC_REF(modify_damage))
		return TRUE

	UnregisterSignal(linked_mob, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS)
	return TRUE

/datum/nifsoft/vore/armor/Destroy()
	if(linked_mob)
		UnregisterSignal(linked_mob, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS)
	return ..()

/datum/nifsoft/vore/armor/proc/modify_damage(mob/living/carbon/human/source, list/damage_mods, damage_amount, damagetype, def_zone, sharpness, attack_direction, obj/item/attacking_item)
	SIGNAL_HANDLER

	if(damagetype != BRUTE)
		return

	damage_mods += 0.85

/obj/item/disk/nifsoft_uploader/vore_armor
	name = "Bullhide Mod NIFSoft datadisk"
	loaded_nifsoft = /datum/nifsoft/vore/armor

/datum/nifsoft/vore/burn_armor
	name = "Dragon's Skin"
	program_desc = "A combat-grade heat dissipation routine that reduces incoming burn trauma while active."
	purchase_price = 3200
	active_mode = TRUE
	active_cost = 0.5
	activation_cost = 20
	buying_category = NIFSOFT_CATEGORY_GENERAL
	ui_icon = "fire-flame-simple"
	rewards_points_eligible = FALSE

/datum/nifsoft/vore/burn_armor/activate()
	. = ..()
	if(. == FALSE)
		return FALSE

	if(active)
		RegisterSignal(linked_mob, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS, PROC_REF(modify_damage))
		return TRUE

	UnregisterSignal(linked_mob, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS)
	return TRUE

/datum/nifsoft/vore/burn_armor/Destroy()
	if(linked_mob)
		UnregisterSignal(linked_mob, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS)
	return ..()

/datum/nifsoft/vore/burn_armor/proc/modify_damage(mob/living/carbon/human/source, list/damage_mods, damage_amount, damagetype, def_zone, sharpness, attack_direction, obj/item/attacking_item)
	SIGNAL_HANDLER

	if(damagetype != BURN)
		return

	damage_mods += 0.85

/obj/item/disk/nifsoft_uploader/vore_burn_armor
	name = "Dragon's Skin NIFSoft datadisk"
	loaded_nifsoft = /datum/nifsoft/vore/burn_armor

/datum/nifsoft/vore/malware
	name = "Cool Kidz Toolbar"
	program_desc = "A junk toolbar of uncertain origin. It mostly wastes processor time and refuses to justify its existence."
	purchase_price = 1987
	buying_category = NIFSOFT_CATEGORY_FUN
	ui_icon = "bug"
	rewards_points_eligible = FALSE
	able_to_keep = FALSE
	var/last_ad

/datum/nifsoft/vore/malware/New(obj/item/organ/cyberimp/brain/nif/recipient_nif, no_rewards_points = FALSE)
	. = ..()
	last_ad = world.time

/datum/nifsoft/vore/malware/nifsoft_process(seconds_per_tick)
	if(!linked_mob?.client || (world.time - last_ad) < 10 MINUTES || !prob(1))
		return TRUE

	last_ad = world.time
	to_chat(linked_mob, span_warning("NIF popup: CONGRATULATIONS! You are the 1,987th user to install Cool Kidz Toolbar!"))
	return TRUE

/obj/item/disk/nifsoft_uploader/vore_malware
	name = "Cool Kidz Toolbar NIFSoft datadisk"
	loaded_nifsoft = /datum/nifsoft/vore/malware

SUBSYSTEM_DEF(veilbreak_nifsofts)
	name = "Veilbreak NIFSoft Catalog"
	flags = SS_NO_FIRE

/datum/controller/subsystem/veilbreak_nifsofts/Initialize()
	. = ..()
	GLOB.purchasable_nifsofts |= list(
		/datum/nifsoft/vore/medichines,
		/datum/nifsoft/vore/respirocytes,
		/datum/nifsoft/vore/pressure_seals,
		/datum/nifsoft/vore/heat_sinks,
		/datum/nifsoft/vore/apc_connector,
		/datum/nifsoft/vore/mass_alteration,
		/datum/nifsoft/vore/painkillers,
		/datum/nifsoft/vore/armor,
		/datum/nifsoft/vore/burn_armor,
	)
	return SS_INIT_SUCCESS

#undef VEILBREAK_NIFSOFT_PROCESS_COST
#undef VEILBREAK_RESPIROCYTE_MAX_RESERVE
