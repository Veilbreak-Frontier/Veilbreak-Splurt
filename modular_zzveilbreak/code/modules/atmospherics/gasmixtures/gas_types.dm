#define VEILBREAK_GAS_ICON 'modular_zzveilbreak/icons/effects/gasses.dmi'
#define VEILBREAK_OVERLAY_GASES list(/datum/gas/delirium)

/datum/gas/proc/fusion_heat(datum/gas_mixture/mix, factor)
	return mix.temperature

/proc/veilbreak_patch_gas_overlay_icons()
	var/list/overlay_map = GLOB.meta_gas_info[META_GAS_OVERLAY]
	if(!islist(overlay_map))
		return
	for(var/gas_path in VEILBREAK_OVERLAY_GASES)
		var/list/fills = overlay_map[gas_path]
		if(!length(fills))
			continue
		for(var/list/fill as anything in fills)
			for(var/obj/effect/overlay/gas/gas as anything in fill)
				gas.icon = VEILBREAK_GAS_ICON

SUBSYSTEM_DEF(veilbreak_atmos)
	name = "Veilbreak Atmos"
	init_stage = INITSTAGE_LAST
	ss_flags = SS_NO_FIRE | SS_NO_INIT

/datum/controller/subsystem/veilbreak_atmos/Initialize()
	. = ..()
	veilbreak_patch_gas_overlay_icons()

/datum/gas/delirium
	id = GAS_DELIRIUM
	specific_heat = 3000
	dangerous = TRUE
	name = "Delirium"
	gas_overlay = "delirium"
	moles_visible = 5
	rarity = 1
	fusion_power = 15
	base_value = 5
	desc = "A gas that induces hallucinations and madness. Said to be the breath of the void itself."
	primary_color = "#7b0f9c"
