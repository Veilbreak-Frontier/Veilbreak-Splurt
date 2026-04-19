#define VEILBREAK_LEADERSHIP_MAX_ALLIES 3
#define VEILBREAK_LEADERSHIP_RANGE 8
/// Negative = faster do_after via actionspeed sum (see /mob/proc/update_actionspeed).
#define VEILBREAK_LEADERSHIP_SPEED_MULT -0.28

/datum/actionspeed_modifier/veilbreak_leadership_proximity
	variable = TRUE
	id = "veilbreak_leadership_proximity"
	multiplicative_slowdown = VEILBREAK_LEADERSHIP_SPEED_MULT

/proc/veilbreak_leadership_party_bonus(mob/living/carbon/human/member)
	if(!member?.mind)
		return FALSE
	var/datum/mind/mind = member.mind
	if(LAZYLEN(mind.veilbreak_leadership_allies))
		for(var/datum/weakref/wr as anything in mind.veilbreak_leadership_allies)
			var/mob/living/carbon/human/mate = wr?.resolve()
			if(istype(mate) && get_dist(member, mate) <= VEILBREAK_LEADERSHIP_RANGE)
				return TRUE
	var/datum/weakref/leader_wr = member.veilbreak_leadership_leader_ref
	var/datum/mind/leader_mind = leader_wr?.resolve()
	if(!istype(leader_mind))
		return FALSE
	var/mob/living/carbon/human/leader = leader_mind.current
	if(istype(leader) && get_dist(member, leader) <= VEILBREAK_LEADERSHIP_RANGE)
		return TRUE
	for(var/datum/weakref/wr as anything in leader_mind.veilbreak_leadership_allies)
		var/mob/living/carbon/human/mate = wr?.resolve()
		if(!istype(mate) || mate == member)
			continue
		if(get_dist(member, mate) <= VEILBREAK_LEADERSHIP_RANGE)
			return TRUE
	return FALSE

/proc/veilbreak_leadership_refresh_speed(mob/living/carbon/human/member)
	if(!istype(member))
		return
	if(veilbreak_leadership_party_bonus(member))
		member.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/veilbreak_leadership_proximity, multiplicative_slowdown = VEILBREAK_LEADERSHIP_SPEED_MULT)
	else
		member.remove_actionspeed_modifier(/datum/actionspeed_modifier/veilbreak_leadership_proximity)

/proc/veilbreak_leadership_ensure_element(mob/living/carbon/human/member)
	if(!istype(member))
		return
	member.AddElement(/datum/element/veilbreak_leadership_party)

/datum/element/veilbreak_leadership_party

/datum/element/veilbreak_leadership_party/Attach(datum/target)
	. = ..()
	if(!ishuman(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))

/datum/element/veilbreak_leadership_party/Detach(datum/source, ...)
	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)
	return ..()

/datum/element/veilbreak_leadership_party/proc/on_moved(mob/living/carbon/human/member, atom/oldloc, direction, forced, list/old_locs)
	SIGNAL_HANDLER
	veilbreak_leadership_refresh_speed(member)

/datum/power/leadership/add(mob/living/carbon/human/target)
	veilbreak_leadership_ensure_element(target)
	veilbreak_leadership_refresh_speed(target)
	var/datum/action/cooldown/mob_cooldown/designate_ally/designate = new /datum/action/cooldown/mob_cooldown/designate_ally(target.mind || target)
	designate.Grant(target)

/datum/action/cooldown/mob_cooldown/designate_ally
	name = "Designate Ally"
	desc = "Designate or remove squadmates to gain action speed bonuses."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "rcl_gui"
	cooldown_time = 1 SECONDS
	ranged_mousepointer = 'icons/effects/mouse_pointers/cult_target.dmi'

/datum/action/cooldown/mob_cooldown/designate_ally/Activate(atom/target_atom)
	if(!ishuman(owner))
		return TRUE
	var/mob/living/carbon/human/leader = owner
	if(!leader.mind)
		to_chat(leader, span_warning("You need a mind to lead anyone."))
		return TRUE
	var/mob/living/carbon/human/marked = target_atom
	if(!istype(marked) || marked == leader)
		to_chat(leader, span_warning("You must designate another person."))
		return TRUE
	if(get_dist(leader, marked) > 7)
		to_chat(leader, span_warning("Too far."))
		return TRUE
	if(!marked.mind)
		to_chat(leader, span_warning("[marked] cannot be designated."))
		return TRUE

	var/datum/mind/lead_mind = leader.mind
	LAZYINITLIST(lead_mind.veilbreak_leadership_allies)

	var/datum/weakref/marked_wr = WEAKREF(marked)
	var/list/allies = lead_mind.veilbreak_leadership_allies

	var/found_index = allies.Find(marked_wr)
	if(found_index)
		allies.Cut(found_index, found_index + 1)
		REMOVE_TRAIT(marked, TRAIT_LEADERSHIP_ALLY, REF(lead_mind))
		marked.veilbreak_leadership_leader_ref = null

		to_chat(leader, span_notice("You remove [marked] from your squad."))
		to_chat(marked, span_notice("[leader] no longer counts you as a squadmate."))

		veilbreak_leadership_refresh_speed(leader)
		veilbreak_leadership_refresh_speed(marked)
		StartCooldown()
		return TRUE

	if(length(allies) >= VEILBREAK_LEADERSHIP_MAX_ALLIES)
		to_chat(leader, span_warning("You already have [VEILBREAK_LEADERSHIP_MAX_ALLIES] allies designated."))
		return TRUE

	allies += marked_wr
	marked.veilbreak_leadership_leader_ref = WEAKREF(lead_mind)
	ADD_TRAIT(marked, TRAIT_LEADERSHIP_ALLY, REF(lead_mind))
	veilbreak_leadership_ensure_element(marked)

	to_chat(leader, span_notice("[marked] is now in your squad."))
	to_chat(marked, span_notice("[leader] counts you as a trusted ally."))

	veilbreak_leadership_refresh_speed(leader)
	veilbreak_leadership_refresh_speed(marked)
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/designate_ally/New()
	..()
	desc = "Click then click a crewmember within 7 tiles to add or remove them from your squad (max [VEILBREAK_LEADERSHIP_MAX_ALLIES]). While an ally or your leader is within [VEILBREAK_LEADERSHIP_RANGE] tiles, you perform timed actions slightly faster."
