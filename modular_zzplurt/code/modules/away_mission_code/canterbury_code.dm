/area/ruin/space/has_grav/abandonedcanterbury
	name = "\improper TGS Canterbury"

/area/ruin/space/has_grav/abandonedcanterbury/medbay
	name = "\improper TGS Canterbury Medbay"

/area/ruin/space/has_grav/abandonedcanterbury/cockpit
	name = "\improper TGS Canterbury Cockpit"

/obj/structure/showcase/machinery/tgmc
	name = "tgmc stuff"
	desc = "Me when beno major victory."
	icon = 'modular_zzplurt/icons/obj/tgmc_stuff.dmi'

/obj/structure/showcase/machinery/tgmc/closet
	name = "GHMME Automated Closet"
	desc = "An automated closet hooked up to a colossal storage unit of standard-issue uniform and armor, or it would have were it not broken beyond repair."
	icon_state = "marineuniform-broken"

/obj/structure/showcase/machinery/tgmc/loadout
	name = "Kwik-E-Quip vendor"
	desc = "An advanced vendor to instantly arm soldiers with specific sets of equipment, allowing for immediate combat deployment. Mutually exclusive with the GHMME, or it would have were it not broken beyond repair."
	icon_state = "loadoutvendor-broken"

/obj/structure/showcase/machinery/tgmc/equipment
	name = "automated loadout vendor"
	desc = "An advanced vendor used by the TGMC to rapidly equip their marines, or it would have were it not broken beyond repair."
	icon_state = "equipment-broken"

/obj/structure/showcase/machinery/tgmc/weapons
	name = "automated weapons rack"
	desc = "An automated weapon rack hooked up to a colossal storage of standard-issue weapons, or it would have were it not broken beyond repair."
	icon_state = "marinearmory-broken"

/obj/structure/showcase/machinery/tgmc/armor
	name = "Surplus Armor Equipment Vendor"
	desc = "An automated equipment rack hooked up to a colossal storage of armor and accessories. Nanotrasen designed a new vendor that utilizes bluespace technology to send surplus equipment from outer colonies' sweatshops to your hands! Be grateful, this one is broken beyond repair. So maybe don't be."
	icon_state = "surplus_armor-broken"

/obj/structure/showcase/machinery/tgmc/clothes
	name = "Surplus Clothing Vendor"
	desc = "An automated equipment rack hooked up to a colossal storage of clothing and accessories. Nanotrasen designed a new vendor that utilizes bluespace technology to send surplus equipment from outer colonies' sweatshops to your hands! Be grateful, this one is broken beyond repair. So maybe don't be."
	icon_state = "surplus_clothes-broken"

/obj/structure/showcase/machinery/tgmc/synth
	name = "M57 Synthetic Equipment Vendor"
	desc = "An automated synthetic equipment vendor hooked up to a modest storage unit, or it would have were it not broken beyond repair."
	icon_state = "synth-broken"

/obj/structure/showcase/machinery/tgmc/med
	name = "MarineMed"
	desc = "Marine Medical drug dispenser - Provided by Nanotrasen Pharmaceuticals Division(TM), well.. At least it's in as much disrepair as the division was."
	icon_state = "marinemed-broken"

/obj/structure/showcase/machinery/tgmc/blood
	name = "MM Blood Dispenser"
	desc = "Marine Med brand Blood Pack dispensery, well.. It's in severe disrepair. Who needs blood anyway?"
	icon_state = "bloodvendor-broken"

/obj/structure/showcase/machinery/tgmc/nuke
	name = "nuclear fission explosive"
	desc = "You probably shouldn't stick around to see if this is armed.. Or well, it can't be sadly. It's basically useless without the green, red, and blue disks. And it's missing all of them."
	icon_state = "nuclearbomb_base"
	anchored = 0

/obj/machinery/deployable_turret/hmg/canterbury
	desc = "A heavy caliber machine gun commonly used by Nanotrasen forces, famed for its ability to give people on the receiving end more holes than normal, this one seems to be stuck to the floor."
	can_be_undeployed = FALSE

/obj/machinery/computer/terminal/canterbury/overwatch
	name = "overwatch console"
	desc = "State of the art machinery for giving orders to a squad."
	upperinfo = "Alpha Overwatch Console"
	icon = 'modular_zzplurt/icons/obj/tgmc_stuff.dmi'
	icon_state = "overwatch"
	icon_screen = "overwatch_screen"
	icon_keyboard = null
	connectable = 0
	content = list("<B>Operator:</B> Mark Hans <BR> <BR> \
		<B><center>Squad Overwatch:</B> Mark Hans <BR> <BR> \
		<b>Squad Leader Deployed</b> <BR> \
		<b>Squad Smartgunners:</b> 2 Deployed <BR> \
		<b>Squad Corpsmen:</b> 2 Deployed <BR> \
		<b>Squad Engineers:</b> 2 Deployed <BR> \
		<b>Squad Marines:</b> 6 Deployed <BR> \
		<b>Total:</b> 13 Deployed <BR> \
		<b>Marines Alive:</b> 1 <BR> <BR> \
		<table>   \
		<tr>     <th>Name</th>     <th>Role</th>     <th>State</th>     <th>Location</th>     <th>SL Distance</th>   </tr>   \
		<tr>     <td>Greg Tulman</td>     <td>Squad Leader</td>     <td>Dead</td>     <td>Dormitories Recreation</td>     <td> N/A </td>   </tr>   \
		<tr>     <td>Kade Steel</td>     <td>Squad Smartgunner</td>     <td>Dead</td>     <td>Dormitories Recreation</td>     <td>5</td>   </tr>   \
		<tr>     <td>Jacob Capone</td>     <td>Squad Smartgunner</td>     <td>Dead</td>     <td>Unknown</td>     <td> N/A </td>   </tr>   \
		<tr>     <td>Heals-The-Wounds</td>     <td>Squad Corpsman</td>     <td>Dead</td>     <td>TGS Canterbury</td>     <td> N/A </td>   </tr>   \
		<tr>     <td>Felix Skewer</td>     <td>Squad Corpsman</td>     <td>Dead</td>     <td>Dormitories Recreation</td>     <td>9</td>   </tr>   \
		<tr>     <td>Romeo Jules</td>     <td>Squad Engineer</td>     <td>Dead</td>     <td>Southern Dormitories</td>     <td>26</td>   </tr>   \
		<tr>     <td>Hannah Brown</td>     <td>Squad Engineer</td>     <td>Dead</td>     <td>TGS Canterbury</td>     <td> N/A </td>   </tr>   \
		<tr>     <td>Khaled Reed</td>     <td>Squad Marine</td>     <td>Dead</td>     <td>Southeastern Colony</td>     <td>72</td>   </tr>   \
		<tr>     <td>Kills-The-Xenos</td>     <td>Squad Marine</td>     <td>Dead</td>     <td>TGS Canterbury</td>     <td> N/A </td>   </tr>   \
		<tr>     <td>Sam Henderson</td>     <td>Squad Marine</td>     <td>Dead</td>     <td>Southeastern Colony</td>     <td>68</td>   </tr> \
		<tr>     <td>Dan Smith</td>     <td>Squad Marine</td>     <td>Dead</td>     <td>TGS Canterbury Medical</td>     <td> N/A </td>   </tr> \
		<tr>     <td>Percy Gullin</td>     <td>Squad Marine</td>     <td>Dead</td>     <td>Unknown</td>     <td> N/A </td>   </tr> \
		<tr>     <td>Clancy Fox</td>     <td>Squad Marine</td>     <td>Alive</td>     <td>Operations Administration</td>     <td> 66 </td>   </tr> \
		</table> <BR> \
		<b>Primary Objective:</b> Make your way towards the Red Disk, do not separate or fall behind. <BR> <b>Secondary Objective:</b> N/A </center>")

/obj/structure/closet/secure_closet/canterbury
	name = "gun cabinet"
	icon = 'modular_skyrat/master_files/icons/obj/closet.dmi'
	icon_state = "riot"
	door_anim_time = 0

/obj/machinery/cryopod/canterbury
	name = "hypersleep chamber"
	desc = "A large automated capsule with LED displays intended to put anyone inside into 'hypersleep', a form of non-cryogenic statis used on most ships, linked to a long-term hypersleep bay on a lower level."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "partypod-open"
	base_icon_state = "partypod"
	open_icon_state = "partypod-open"

/obj/machinery/computer/cryopod/canterbury
	name = "hypersleep bay console"
	desc = "A large console controlling the ship's hypersleep bay. Mainly used for recovery of items from long-term hypersleeping crew."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "computer"
	icon_screen = "comm_logs"
	icon_keyboard = "generic_key"

/obj/machinery/computer/cryopod/canterbury/update_icon_state()
	. = ..()
	if(icon_keyboard)
		if(keyboard_change_icon && (machine_stat & NOPOWER))
			. += "[icon_keyboard]_off"
		else
			. += icon_keyboard

	if(machine_stat & BROKEN)
		. += mutable_appearance(icon, "[icon_state]_broken")
		return // If we don't do this broken computers glow in the dark.

	if(machine_stat & NOPOWER) // Your screen can't be on if you've got no damn charge
		return

	// This lets screens ignore lighting and be visible even in the darkest room
	if(icon_screen)
		. += mutable_appearance(icon, icon_screen)
		. += emissive_appearance(icon, icon_screen, src)

/obj/structure/closet/secure_closet/canterbury/PopulateContents()
	..()
	new /obj/item/gun/ballistic/shotgun/riot/sol(src)

/obj/effect/mob_spawn/corpse/xenomorph
	mob_type = /mob/living/carbon/alien/adult/skyrat/drone

/obj/effect/mob_spawn/corpse/xenomorph/runner
	mob_type = /mob/living/carbon/alien/adult/skyrat/runner

/obj/effect/mob_spawn/corpse/xenomorph/warrior
	mob_type = /mob/living/carbon/alien/adult/skyrat/warrior

/obj/effect/mob_spawn/corpse/human/canterbury
	name = "Squad Marine Corpse"
	hairstyle = "Bald"
	facial_hairstyle = "Shaved"
	outfit = /datum/outfit/centcom/canterbury

/obj/effect/mob_spawn/corpse/human/canterbury/engineer
	name = "Squad Engineer Corpse"
	outfit = /datum/outfit/centcom/canterbury/engineer

/obj/effect/mob_spawn/corpse/human/canterbury/corpsman
	name = "Squad Corpsman Corpse"
	outfit = /datum/outfit/centcom/canterbury/corpsman

/obj/effect/mob_spawn/corpse/human/canterbury/dan
	name = "Pvt. Dan Smith's Corpse"
	mob_name = "Pvt. Dan Smith"
	gender = MALE
	hairstyle = "Slightly Long Hair"

/obj/effect/mob_spawn/corpse/human/canterbury/kills
	name = "Pfc. Kills-The-Xenos's Corpse"
	mob_name = "Pfc. Kills-The-Xenos"
	gender = MALE
	mob_type = /mob/living/carbon/human/species/lizard

/obj/effect/mob_spawn/corpse/human/canterbury/engineer/hannah
	name = "LCpl. Hannah Brown's Corpse"
	mob_name = "LCpl. Hannah Brown"
	gender = FEMALE
	hairstyle = "Pigtails 2"

/obj/effect/mob_spawn/corpse/human/canterbury/corpsman/heals
	name = "Cpl. Heals-The-Wounds's Corpse"
	mob_name = "Cpl. Heals-The-Wounds"
	gender = FEMALE
	mob_type = /mob/living/carbon/human/species/lizard

/obj/item/clothing/suit/armor/vest/marine/sulaco/security
	name = "damaged large tactical armor vest"
	icon_state = "marine_security"

/obj/item/clothing/head/helmet/marine/sulaco/security
	name = "damaged marine heavy helmet"
	icon_state = "marine_security"
	base_icon_state = "marine_security"

/obj/item/clothing/suit/armor/vest/marine/sulaco/engineer
	name = "damaged tactical utility armor vest"
	icon_state = "marine_engineer"

/obj/item/clothing/head/helmet/marine/sulaco/engineer
	name = "damaged marine utility helmet"
	icon_state = "marine_engineer"
	base_icon_state = "marine_engineer"

/obj/item/clothing/suit/armor/vest/marine/sulaco/medic
	name = "damaged tactical medic's armor vest"
	desc = "An old, roughed-up set of the finest mass produced, stamped plasteel armor. This piece of equipment has lost most of its protective qualities to time, yet it is still more than serviceable for giving xenos the middle finger."
	icon_state = "marine_medic"
	body_parts_covered = CHEST|GROIN

/obj/item/clothing/head/helmet/marine/sulaco/medic
	name = "damaged marine medic helmet"
	desc = "A tactical black helmet, barely sealed from outside hazards with a plate of glass and not much else. Not as protective as it used to be, but it is still completely functional."
	icon_state = "marine_medic"
	base_icon_state = "marine_medic"

/obj/item/clothing/under/rank/centcom/military/tgmc
	name = "\improper TGMC uniform"
	desc = "A standard-issue, kevlar-weaved, hazmat-tested, EMF-augmented marine uniform. You suspect it's not as robust-proof as advertised."
	icon = 'modular_zzplurt/icons/obj/clothing/under/centcom.dmi'
	worn_icon = 'modular_zzplurt/icons/mob/clothing/under/centcom.dmi'
	icon_state = "marine_jumpsuit"
	can_adjust = TRUE
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/centcom/military/tgmc/engineer
	name = "\improper TGMC engineer fatigues"
	desc = "A standard-issue, kevlar-weaved, hazmat-tested, EMF-augmented combat engineer fatigues. You suspect it's not as robust-proof as advertised."
	icon_state = "marine_engineer"

/obj/item/clothing/under/rank/centcom/military/tgmc/medic
	name = "\improper TGMC corpsman fatigues"
	desc = "A standard-issue, kevlar-weaved, hazmat-tested, EMF-augmented combat corpsman fatigues. You suspect it's not as robust-proof as advertised."
	icon_state = "marine_medic"

/obj/item/card/id/advanced/platinum/canterbury
	registered_name = "Squad Marine"
	trim = /datum/id_trim/centcom/canterbury

/obj/item/card/id/advanced/platinum/canterbury/engineer
	registered_name = "Squad Engineer"
	trim = /datum/id_trim/centcom/canterbury/engineer

/obj/item/card/id/advanced/platinum/canterbury/medical
	registered_name = "Squad Corpsman"
	trim = /datum/id_trim/centcom/canterbury/medical

/datum/id_trim/centcom/canterbury
	assignment = "Squad Marine"
	trim_state = "trim_securityofficer"
	subdepartment_color = COLOR_SECURITY_RED
	sechud_icon_state = SECHUD_SECURITY_RESPONSE_OFFICER
	big_pointer = FALSE
	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING)

/datum/id_trim/centcom/canterbury/engineer
	assignment = "Squad Engineer"
	trim_state = "trim_stationengineer"
	subdepartment_color = COLOR_ENGINEERING_ORANGE
	sechud_icon_state = SECHUD_ENGINEERING_RESPONSE_OFFICER
	big_pointer = FALSE
	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_STORAGE, ACCESS_CENT_LIVING)

/datum/id_trim/centcom/canterbury/medical
	assignment = "Squad Corpsman"
	trim_state = "trim_medicaldoctor"
	subdepartment_color = COLOR_MEDICAL_BLUE
	sechud_icon_state = SECHUD_MEDICAL_RESPONSE_OFFICER
	big_pointer = FALSE
	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_MEDICAL, ACCESS_CENT_LIVING)

/datum/outfit/centcom/canterbury
	name = "Canterbury Squad Marine"

	id = /obj/item/card/id/advanced/platinum/canterbury
	suit = /obj/item/clothing/suit/armor/vest/marine/sulaco/security
	ears = /obj/item/radio/headset/headset_cent/empty
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	head = /obj/item/clothing/head/helmet/marine/sulaco/security
	back = /obj/item/storage/backpack/industrial/frontier_colonist/satchel
	uniform = /obj/item/clothing/under/rank/centcom/military/tgmc
	mask = /obj/item/clothing/mask/balaclava
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat

	implants = list(/obj/item/implant/mindshield)

/datum/outfit/centcom/canterbury/post_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	if(visuals_only)
		return

	var/obj/item/card/id/W = H.wear_id
	if(W)
		W.registered_name = H.real_name
		W.update_label()
		W.update_icon()
	return ..()

/datum/outfit/centcom/canterbury/corpsman
	name = "Canterbury Squad Corpsman"

	id = /obj/item/card/id/advanced/platinum/canterbury/medical
	suit = /obj/item/clothing/suit/armor/vest/marine/sulaco/medic
	l_pocket = /obj/item/healthanalyzer
	head = /obj/item/clothing/head/helmet/marine/sulaco/medic
	uniform = /obj/item/clothing/under/rank/centcom/military/tgmc/medic
	backpack_contents = list(
		/obj/item/storage/medkit/regular = 1,
		/obj/item/storage/medkit/advanced = 1,
	)
	belt = /obj/item/storage/belt/medical/paramedic
	ears = /obj/item/radio/headset/headset_cent/empty
	glasses = /obj/item/clothing/glasses/hud/health/sunglasses

	skillchips = list(/obj/item/skillchip/entrails_reader)

/datum/outfit/centcom/canterbury/engineer
	name = "Canterbury Squad Engineer"

	id = /obj/item/card/id/advanced/platinum/canterbury/engineer
	suit = /obj/item/clothing/suit/armor/vest/marine/sulaco/engineer
	head = /obj/item/clothing/head/helmet/marine/sulaco/engineer
	uniform = /obj/item/clothing/under/rank/centcom/military/tgmc/engineer
	belt = /obj/item/storage/belt/utility/full/powertools/rcd
	ears = /obj/item/radio/headset/headset_cent/empty
	glasses = /obj/item/clothing/glasses/hud/diagnostic/sunglasses

	skillchips = list(/obj/item/skillchip/job/engineer)
