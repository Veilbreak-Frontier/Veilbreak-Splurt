/// Department guest access via PDA — sponsors share a subset of their ID access; guests accept on the same app.

#define GUEST_PASS_INVITE_LIFETIME (10 MINUTES)

GLOBAL_LIST_EMPTY_TYPED(pda_guest_pass_programs, /datum/computer_file/program/guest_access_pass)
GLOBAL_VAR_INIT(guest_pass_uid_counter, 0)

/proc/register_guest_pass_program(datum/computer_file/program/guest_access_pass/app)
	if(!istype(app) || !istype(app.computer))
		return
	var/obj/item/modular_computer/device = app.computer
	if(!device.saved_identification || !device.saved_job)
		return
	var/refkey = REF(app)
	if(refkey in GLOB.pda_guest_pass_programs)
		return
	GLOB.pda_guest_pass_programs[refkey] = app

/proc/unregister_guest_pass_program(datum/computer_file/program/guest_access_pass/app)
	if(!istype(app))
		return
	GLOB.pda_guest_pass_programs -= REF(app)

/datum/mind
	/// Active guest passes this mind has issued (`/datum/guest_pass_issued`).
	var/list/guest_pass_issued = list()

/datum/guest_pass_invite
	var/id
	var/sponsor_name
	var/sponsor_job
	var/datum/weakref/sponsor_mind_wr
	var/list/access_to_share = list()
	var/created_time
	var/expiry_time

/datum/guest_pass_invite/Destroy()
	sponsor_mind_wr = null
	access_to_share = null
	return ..()

/datum/guest_pass_issued
	var/id
	var/datum/weakref/guest_mob_wr
	var/list/access = list()
	var/guest_name

/datum/guest_pass_issued/Destroy()
	guest_mob_wr = null
	access = null
	return ..()

/// Adds delegated door access without editing the guest's ID. Only returns ACCESS_ALLOWED when it matches; never DISALLOWED (so normal ID checks still run).
/datum/component/guest_access_pass
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/list/access
	var/grant_id
	var/datum/weakref/sponsor_mind_wr

/datum/component/guest_access_pass/Initialize(list/new_access, grant_id, datum/mind/sponsor_mind)
	if(!ismob(parent) || !length(new_access) || !grant_id || !istype(sponsor_mind))
		return COMPONENT_INCOMPATIBLE
	access = new_access.Copy()
	src.grant_id = grant_id
	sponsor_mind_wr = WEAKREF(sponsor_mind)
	RegisterSignal(parent, COMSIG_MOB_TRIED_ACCESS, PROC_REF(try_door))
	RegisterSignal(parent, COMSIG_MOB_RETRIEVE_SIMPLE_ACCESS, PROC_REF(merge_access))
	return ..()

/datum/component/guest_access_pass/proc/try_door(datum/source, obj/locked_object)
	SIGNAL_HANDLER
	if(!istype(locked_object))
		return NONE
	if(locked_object.check_access_list(access))
		return ACCESS_ALLOWED
	return NONE

/datum/component/guest_access_pass/proc/merge_access(datum/source, list/access_list)
	SIGNAL_HANDLER
	access_list += access

/datum/computer_file/program/guest_access_pass
	filename = "deptguest"
	filedesc = "Department Guest Access"
	extended_desc = "Lets qualified crew sponsor temporary departmental access for another crewmember's ID profile, without using an ID console. Guests must accept the invite on their own device."
	downloader_category = PROGRAM_CATEGORY_DEVICE
	program_open_overlay = "id"
	program_flags = PROGRAM_ON_NTNET_STORE | PROGRAM_REQUIRES_NTNET
	size = 4
	tgui_id = "NtosGuestAccessPass"
	program_icon = "user-friends"
	can_run_on_flags = PROGRAM_PDA
	power_cell_use = PROGRAM_BASIC_CELL_USE
	/// Pending invitations received on this device.
	var/list/datum/guest_pass_invite/pending_invites = list()
	/// UI: selected target program ref (string).
	var/selected_target_ref
	/// UI: selected access keys (string form of access number).
	var/list/selected_access_keys = list()
	COOLDOWN_DECLARE(invite_cooldown)

/datum/computer_file/program/guest_access_pass/on_install(datum/computer_file/source, obj/item/modular_computer/computer_installing)
	. = ..()
	RegisterSignal(computer_installing, COMSIG_MODULAR_PDA_IMPRINT_UPDATED, PROC_REF(on_imprint))
	RegisterSignal(computer_installing, COMSIG_MODULAR_PDA_IMPRINT_RESET, PROC_REF(on_imprint_reset))
	if(computer_installing.saved_identification && computer_installing.saved_job)
		register_guest_pass_program(src)

/datum/computer_file/program/guest_access_pass/proc/on_imprint(datum/source)
	SIGNAL_HANDLER
	register_guest_pass_program(src)

/datum/computer_file/program/guest_access_pass/proc/on_imprint_reset(datum/source)
	SIGNAL_HANDLER
	unregister_guest_pass_program(src)

/datum/computer_file/program/guest_access_pass/Destroy()
	unregister_guest_pass_program(src)
	if(computer)
		UnregisterSignal(computer, COMSIG_MODULAR_PDA_IMPRINT_UPDATED)
		UnregisterSignal(computer, COMSIG_MODULAR_PDA_IMPRINT_RESET)
	for(var/datum/guest_pass_invite/invite as anything in pending_invites)
		qdel(invite)
	pending_invites.Cut()
	return ..()

/datum/computer_file/program/guest_access_pass/on_start(mob/living/user)
	. = ..()
	if(!.)
		return FALSE
	register_guest_pass_program(src)
	prune_expired_invites()
	return TRUE

/datum/computer_file/program/guest_access_pass/kill_program(mob/user)
	unregister_guest_pass_program(src)
	return ..()

/datum/computer_file/program/guest_access_pass/can_run(mob/user, loud = FALSE, access_to_check, downloading = FALSE, list/access)
	if(user && issilicon(user) && !ispAI(user))
		if(loud && computer)
			to_chat(user, span_danger("\The [computer] flashes \"Crew biometric interface required\"."))
		return FALSE
	return ..()

/datum/computer_file/program/guest_access_pass/proc/prune_expired_invites()
	var/cut = FALSE
	for(var/datum/guest_pass_invite/invite as anything in pending_invites)
		if(world.time >= invite.expiry_time)
			pending_invites -= invite
			qdel(invite)
			cut = TRUE
	if(cut)
		alert_pending = (length(pending_invites) > 0)

/datum/computer_file/program/guest_access_pass/ui_state(mob/user)
	return GLOB.default_state

/datum/computer_file/program/guest_access_pass/ui_static_data(mob/user)
	var/list/data = list()
	data["inviteLifetimeMs"] = GUEST_PASS_INVITE_LIFETIME
	return data

/datum/computer_file/program/guest_access_pass/ui_data(mob/user)
	prune_expired_invites()
	var/list/data = list()
	var/obj/item/card/id/id_card = computer?.stored_id?.GetID()
	var/mob/living/carbon/human/human_user = user
	data["hasId"] = !!id_card
	data["sponsorEligible"] = FALSE
	data["sponsorBlockReason"] = ""
	if(!ishuman(human_user))
		data["sponsorBlockReason"] = "Only organic crew can use sponsorship."
	else if(human_user.GetComponent(/datum/component/guest_access_pass))
		data["sponsorBlockReason"] = "Guests cannot sponsor other guests."
	else if(!id_card)
		data["sponsorBlockReason"] = "Insert an ID into this device."
	else if(!veilbreak_guest_pass_trim_allows_sponsor(id_card))
		data["sponsorBlockReason"] = "Your assignment cannot sponsor guest access."
	else
		data["sponsorEligible"] = TRUE

	var/list/access_options = list()
	if(id_card && data["sponsorEligible"])
		var/list/card_access = id_card.GetAccess()
		for(var/a in card_access)
			var/desc = SSid_access.get_access_desc(a) || "Access #[a]"
			access_options += list(list(
				"key" = "[a]",
				"label" = desc,
				"selected" = ("[a]" in selected_access_keys),
			))
	data["accessOptions"] = access_options

	var/list/targets = list()
	for(var/refkey in GLOB.pda_guest_pass_programs)
		var/datum/computer_file/program/guest_access_pass/other = GLOB.pda_guest_pass_programs[refkey]
		if(!istype(other) || other == src || !istype(other.computer))
			continue
		var/obj/item/modular_computer/oc = other.computer
		targets += list(list(
			"ref" = refkey,
			"name" = oc.saved_identification || "Unknown",
			"job" = oc.saved_job || "Unknown",
		))
	data["targets"] = targets
	data["selectedTargetRef"] = selected_target_ref

	var/list/incoming = list()
	for(var/datum/guest_pass_invite/invite as anything in pending_invites)
		var/list/access_names = list()
		for(var/a in invite.access_to_share)
			access_names += SSid_access.get_access_desc(a) || "Access #[a]"
		incoming += list(list(
			"id" = invite.id,
			"sponsorName" = invite.sponsor_name,
			"sponsorJob" = invite.sponsor_job,
			"accessSummary" = english_list(access_names),
			"expiresIn" = max(0, round((invite.expiry_time - world.time) / 10)),
		))
	data["incomingInvites"] = incoming

	var/list/outgoing = list()
	if(human_user?.mind?.guest_pass_issued)
		for(var/datum/guest_pass_issued/grant as anything in human_user.mind.guest_pass_issued)
			var/mob/living/guest = grant.guest_mob_wr?.resolve()
			outgoing += list(list(
				"id" = grant.id,
				"guestName" = grant.guest_name,
				"guestStatus" = guest ? "Active" : "Offline",
			))
	data["activeGuests"] = outgoing

	return data

/datum/computer_file/program/guest_access_pass/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch(action)
		if("PRG_selectTarget")
			selected_target_ref = params["ref"]
			return TRUE
		if("PRG_toggleAccess")
			var/key = params["key"]
			if(selected_access_keys.Find(key))
				selected_access_keys -= key
			else
				selected_access_keys |= key
			return TRUE
		if("PRG_clearAccess")
			selected_access_keys.Cut()
			return TRUE
		if("PRG_sendInvite")
			return send_guest_invite(usr)
		if("PRG_acceptInvite")
			return accept_guest_invite(usr, params["id"])
		if("PRG_denyInvite")
			return deny_guest_invite(usr, params["id"])
		if("PRG_revokeGuest")
			return revoke_guest_grant(usr, params["id"])
	return FALSE

/datum/computer_file/program/guest_access_pass/proc/send_guest_invite(mob/living/carbon/human/sponsor)
	if(!istype(sponsor) || !computer?.can_interact(sponsor))
		return FALSE
	if(!computer.get_ntnet_status())
		computer.balloon_alert(sponsor, "no NTNet!")
		return FALSE
	if(!COOLDOWN_FINISHED(src, invite_cooldown))
		computer.balloon_alert(sponsor, "wait!")
		return FALSE
	prune_expired_invites()
	var/obj/item/card/id/id_card = computer.stored_id?.GetID()
	if(!veilbreak_guest_pass_can_sponsor(sponsor, id_card))
		computer.balloon_alert(sponsor, "cannot sponsor!")
		return FALSE
	if(!selected_target_ref || !(selected_target_ref in GLOB.pda_guest_pass_programs))
		computer.balloon_alert(sponsor, "pick recipient!")
		return FALSE
	var/datum/computer_file/program/guest_access_pass/recipient_app = GLOB.pda_guest_pass_programs[selected_target_ref]
	if(!istype(recipient_app) || recipient_app == src)
		return FALSE
	if(!length(selected_access_keys))
		computer.balloon_alert(sponsor, "pick access!")
		return FALSE
	var/list/sponsor_access = id_card.GetAccess()
	var/list/chosen = list()
	for(var/k in selected_access_keys)
		var/num = text2num(k)
		if(isnull(num))
			num = k
		if(!(num in sponsor_access))
			computer.balloon_alert(sponsor, "invalid access!")
			return FALSE
		chosen |= num
	if(!length(chosen))
		return FALSE
	var/mob/living/carbon/human/recipient_mob = recipient_app.computer.loc
	if(!istype(recipient_mob) || recipient_mob.stat >= UNCONSCIOUS)
		computer.balloon_alert(sponsor, "they need their PDA!")
		return FALSE
	if(recipient_mob == sponsor)
		computer.balloon_alert(sponsor, "pick someone else!")
		return FALSE
	if(!sponsor.mind)
		computer.balloon_alert(sponsor, "no mind record!")
		return FALSE

	var/datum/guest_pass_invite/invite = new
	invite.id = "gpi-[world.time]-[rand(10000, 99999)]"
	invite.sponsor_name = computer.saved_identification || id_card.registered_name || "Unknown"
	invite.sponsor_job = computer.saved_job || id_card.assignment || "Unknown"
	invite.sponsor_mind_wr = WEAKREF(sponsor.mind)
	invite.access_to_share = chosen.Copy()
	invite.created_time = world.time
	invite.expiry_time = world.time + GUEST_PASS_INVITE_LIFETIME

	for(var/datum/guest_pass_invite/old as anything in recipient_app.pending_invites)
		var/datum/mind/old_mind = old.sponsor_mind_wr?.resolve()
		if(old_mind == sponsor.mind)
			recipient_app.pending_invites -= old
			qdel(old)

	recipient_app.pending_invites += invite
	recipient_app.alert_pending = TRUE
	COOLDOWN_START(src, invite_cooldown, 5 SECONDS)
	computer.balloon_alert(sponsor, "invite sent!")
	to_chat(recipient_mob, span_notice("[invite.sponsor_name] ([invite.sponsor_job]) sent you a departmental guest access invite. Check Department Guest Access on your PDA."))
	playsound(recipient_app.computer, 'sound/machines/ping.ogg', 30, FALSE)
	generate_network_log("Guest access invite sent to [recipient_mob.real_name] ([chosen.len] accesses)")
	return TRUE

/datum/computer_file/program/guest_access_pass/proc/accept_guest_invite(mob/living/carbon/human/guest, invite_id)
	if(!istype(guest) || !computer?.can_interact(guest))
		return FALSE
	prune_expired_invites()
	var/datum/guest_pass_invite/found = null
	for(var/datum/guest_pass_invite/invite as anything in pending_invites)
		if(invite.id == invite_id)
			found = invite
			break
	if(!found)
		computer.balloon_alert(guest, "expired!")
		return FALSE
	var/datum/mind/sponsor_mind = found.sponsor_mind_wr?.resolve()
	if(!istype(sponsor_mind) || !istype(sponsor_mind.current, /mob/living/carbon/human))
		computer.balloon_alert(guest, "sponsor unavailable!")
		pending_invites -= found
		qdel(found)
		return FALSE
	var/mob/living/carbon/human/sponsor = sponsor_mind.current
	var/obj/item/card/id/sponsor_id = sponsor.get_idcard()
	if(!sponsor_id)
		computer.balloon_alert(guest, "sponsor lost ID!")
		pending_invites -= found
		qdel(found)
		return FALSE
	var/list/current_sponsor_access = sponsor_id.GetAccess()
	for(var/a in found.access_to_share)
		if(!(a in current_sponsor_access))
			computer.balloon_alert(guest, "sponsor access changed!")
			pending_invites -= found
			qdel(found)
			return FALSE
	if(!veilbreak_guest_pass_can_sponsor(sponsor, sponsor_id))
		computer.balloon_alert(guest, "sponsor cannot vouch!")
		pending_invites -= found
		qdel(found)
		return FALSE

	pending_invites -= found
	var/grant_id = "gp-[++GLOB.guest_pass_uid_counter]"
	var/datum/guest_pass_issued/grant = new
	grant.id = grant_id
	grant.guest_mob_wr = WEAKREF(guest)
	grant.access = found.access_to_share.Copy()
	grant.guest_name = guest.real_name
	sponsor_mind.guest_pass_issued += grant
	guest.AddComponent(/datum/component/guest_access_pass, grant.access, grant_id, sponsor_mind)

	var/list/access_names = list()
	for(var/a in grant.access)
		access_names += SSid_access.get_access_desc(a) || "Access #[a]"
	log_game("GUEST PASS: [key_name(sponsor)] granted [key_name(guest)] guest access: [english_list(access_names)]")
	guest.investigate_log("accepted guest access from [key_name(sponsor)]: [english_list(access_names)]", INVESTIGATE_ACCESSCHANGES)
	sponsor.investigate_log("issued guest access to [key_name(guest)]: [english_list(access_names)]", INVESTIGATE_ACCESSCHANGES)

	qdel(found)
	alert_pending = (length(pending_invites) > 0)
	computer.balloon_alert(guest, "access granted!")
	playsound(computer, 'sound/machines/ping.ogg', 40, FALSE)
	return TRUE

/datum/computer_file/program/guest_access_pass/proc/deny_guest_invite(mob/guest, invite_id)
	if(!computer?.can_interact(guest))
		return FALSE
	for(var/datum/guest_pass_invite/invite as anything in pending_invites)
		if(invite.id == invite_id)
			pending_invites -= invite
			qdel(invite)
			alert_pending = (length(pending_invites) > 0)
			return TRUE
	return FALSE

/datum/computer_file/program/guest_access_pass/proc/revoke_guest_grant(mob/living/carbon/human/sponsor, grant_id)
	if(!istype(sponsor) || !istype(sponsor.mind) || !computer?.can_interact(sponsor))
		return FALSE
	for(var/datum/guest_pass_issued/grant as anything in sponsor.mind.guest_pass_issued)
		if(grant.id != grant_id)
			continue
		var/mob/living/guest = grant.guest_mob_wr?.resolve()
		if(guest)
			for(var/datum/component/guest_access_pass/comp in guest.GetComponents(/datum/component/guest_access_pass))
				if(comp.grant_id == grant_id)
					qdel(comp)
					break
		sponsor.mind.guest_pass_issued -= grant
		var/list/access_names = list()
		for(var/a in grant.access)
			access_names += SSid_access.get_access_desc(a) || "Access #[a]"
		log_game("GUEST PASS: [key_name(sponsor)] revoked guest access [grant_id] from [grant.guest_name] ([english_list(access_names)])")
		sponsor.investigate_log("revoked guest access [grant_id] from [grant.guest_name]", INVESTIGATE_ACCESSCHANGES)
		qdel(grant)
		computer.balloon_alert(sponsor, "revoked!")
		return TRUE
	return FALSE

/proc/veilbreak_guest_pass_trim_allows_sponsor(obj/item/card/id/id_card)
	var/datum/id_trim/trim = id_card?.trim
	if(!istype(trim, /datum/id_trim/job))
		return FALSE
	if(istype(trim, /datum/id_trim/job/assistant))
		return FALSE
	if(istype(trim, /datum/id_trim/job/prisoner))
		return FALSE
	return TRUE

/proc/veilbreak_guest_pass_can_sponsor(mob/living/carbon/human/human, obj/item/card/id/id_card)
	if(!ishuman(human) || !istype(id_card))
		return FALSE
	if(human.GetComponent(/datum/component/guest_access_pass))
		return FALSE
	return veilbreak_guest_pass_trim_allows_sponsor(id_card)

/obj/item/modular_computer/pda/install_default_programs()
	. = ..()
	if(!has_pda_programs)
		return
	if(!find_file_by_name("deptguest"))
		var/datum/computer_file/program/guest_access_pass/new_app = new
		store_file(new_app)
