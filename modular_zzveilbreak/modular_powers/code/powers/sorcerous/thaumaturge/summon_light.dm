// A simple utility spell to illuminate yourself with affinity scaling.
/datum/power/thaumaturge/summon_light
	name = "Summon Light"
	desc = "Conjure a magical light anchored to you. Activate again to dismiss it.\
	\nRequires Affinity 1. Higher affinity increases the light range."
	security_record_text = "Subject can conjure a floating magical light around themselves."
	value = 1

	action_path = /datum/action/cooldown/power/thaumaturge/summon_light
	required_powers = list(/datum/power/thaumaturge_root)

/datum/action/cooldown/power/thaumaturge/summon_light
	name = "Summon Light"
	desc = "Conjure a magical light on yourself. Toggle to dismiss."
	button_icon = 'icons/obj/lighting.dmi'
	button_icon_state = "lighttube"

	required_affinity = 1
	max_charges = 0 // utility cantrip, does not consume preparation charges
	cooldown_time = 1 SECONDS

	/// The active personal light object while toggled on.
	var/obj/effect/dummy/lighting_obj/moblight/summoned_light
	/// Base light range with minimum required affinity.
	var/base_light_range = 2
	/// How much range each affinity above required_affinity grants.
	var/affinity_range_bonus = 1
	/// Hard cap to keep this in utility territory.
	var/max_light_range = 7
	/// Light power for mob_light().
	var/light_power = 1
	/// Light color for the summoned light.
	var/light_color = "#d3bcff"

/datum/action/cooldown/power/thaumaturge/summon_light/Grant(mob/granted_to)
	. = ..()
	if(resonant)
		RegisterSignal(granted_to, COMSIG_ATOM_DISPEL, PROC_REF(on_dispel))

/datum/action/cooldown/power/thaumaturge/summon_light/Remove(mob/removed_from)
	. = ..()
	if(resonant)
		UnregisterSignal(removed_from, COMSIG_ATOM_DISPEL)
	disable_summoned_light()

/datum/action/cooldown/power/thaumaturge/summon_light/use_action(mob/living/user, atom/target)
	active = !active
	if(active)
		enable_summoned_light(user)
		owner.balloon_alert(user, "light on")
	else
		disable_summoned_light()
		owner.balloon_alert(user, "light off")
	build_all_button_icons(UPDATE_BUTTON_STATUS)
	return TRUE

/// Enables the personal light, scaling range from snapshotted cast affinity.
/datum/action/cooldown/power/thaumaturge/summon_light/proc/enable_summoned_light(mob/living/user)
	if(!user)
		return
	var/bonus_affinity = max(0, affinity - required_affinity)
	var/total_range = clamp(base_light_range + (bonus_affinity * affinity_range_bonus), base_light_range, max_light_range)
	QDEL_NULL(summoned_light)
	summoned_light = user.mob_light(
		range = total_range,
		power = light_power,
		color = light_color
	)

/// Removes the personal light.
/datum/action/cooldown/power/thaumaturge/summon_light/proc/disable_summoned_light()
	QDEL_NULL(summoned_light)

/// Dispel handling; toggles light off if active.
/datum/action/cooldown/power/thaumaturge/summon_light/proc/on_dispel(mob/owner, atom/dispeller)
	SIGNAL_HANDLER
	if(!active)
		return NONE
	active = FALSE
	disable_summoned_light()
	build_all_button_icons(UPDATE_BUTTON_STATUS)
	return DISPEL_RESULT_DISPELLED
