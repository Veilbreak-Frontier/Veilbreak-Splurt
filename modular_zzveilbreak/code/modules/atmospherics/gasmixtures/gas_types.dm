/datum/gas/veilbreak
	//This is a base type for all veilbreak gases

/// Icon used for veilbreak gas overlays (avoids touching parent gas overlay icon)
#define VEILBREAK_GAS_ICON 'modular_zzveilbreak/icons/effects/gasses.dmi'

/// Gases that use our custom icon (paths)
#define VEILBREAK_OVERLAY_GASES list(/datum/gas/delirium)

generate_gas_overlays(old_offset, new_offset, datum/gas/gas_type)
	if(istype(gas_type, /datum/gas/veilbreak) || istype(gas_type, /datum/gas/delirium))
		var/list/to_return = list()
		for(var/i in old_offset to new_offset)
			var/fill = list()
			to_return += list(fill)
			for(var/j in 1 to TOTAL_VISIBLE_STATES)
				// Use base overlay type so parent New/Initialize run; then force our icon
				var/obj/effect/overlay/gas/gas = new (initial(gas_type.gas_overlay), log(4, (j+0.4*TOTAL_VISIBLE_STATES) / (0.35*TOTAL_VISIBLE_STATES)) * 255, i)
				gas.icon = VEILBREAK_GAS_ICON
				fill += gas
		return to_return
	return ..()

/// Run after init: force our icon onto any gas overlays that might have been created by base proc (load order).
/proc/veilbreak_patch_gas_overlay_icons()
	for(var/gas_path in VEILBREAK_OVERLAY_GASES)
		if(!(gas_path in GLOB.meta_gas_info))
			continue
		var/list/gas_info = GLOB.meta_gas_info[gas_path]
		if(!length(gas_info[META_GAS_OVERLAY]))
			continue
		for(var/fill in gas_info[META_GAS_OVERLAY])
			for(var/obj/effect/overlay/gas/gas in fill)
				gas.icon = VEILBREAK_GAS_ICON

SUBSYSTEM_DEF(veilbreak_atmos)
	name = "Veilbreak Atmos"
	init_stage = INITSTAGE_LAST
	flags = SS_NO_FIRE | SS_NO_INIT

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

