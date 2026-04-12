/turf/open/floor/void_tile
	name = "Void Floor"
	desc = "A tile made from the very fabric of void itself. How are you even standing on this..."
	icon = 'modular_zzveilbreak/icons/tiles/void_tile.dmi'
	icon_state = "void_tile"
	baseturfs = /turf/open/floor/void_tile
	initial_gas_mix = VOID_ATMOS
	planetary_atmos = TRUE
	light_range = 2.0
	light_power = 0.9
	light_color = LIGHT_COLOR_DEFAULT
	thermal_conductivity = 0.1
	heat_capacity = INFINITY
	footstep = FOOTSTEP_PLATING
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_turf = FALSE
	turf_flags = IS_SOLID | NO_RUST
	rcd_proof = TRUE
	rust_resistance = RUST_RESISTANCE_ABSOLUTE
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | BOMB_PROOF

	// Glass floor properties for proper layering and transparency
	layer = GLASS_FLOOR_LAYER
	underfloor_accessibility = UNDERFLOOR_VISIBLE

/turf/open/floor/void_tile/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/turf/open/floor/void_tile/LateInitialize()
	ADD_TURF_TRANSPARENCY(src, INNATE_TRAIT)

/turf/open/floor/void_tile/break_tile()
	return //unbreakable

/turf/open/floor/void_tile/burn_tile()
	return //unbreakable

/turf/open/floor/void_tile/make_plating(force = FALSE)
	if(force)
		return ..()
	return //unplateable

/turf/open/floor/void_tile/ex_act(severity, target)
	if(fish_source)
		GLOB.preset_fish_sources[fish_source].spawn_reward_from_explosion(src, severity)
	return FALSE

/turf/open/floor/void_tile/narsie_act(force, ignore_mobs, probability = 20)
	. = (prob(probability) || force)
	for(var/I in src)
		var/atom/A = I
		if(ignore_mobs && ismob(A))
			continue
		if(ismob(A) || .)
			A.narsie_act()

/turf/open/floor/void_tile/acid_melt()
	return

/turf/open/floor/void_tile/Melt()
	to_be_destroyed = FALSE
	return src

/turf/open/floor/void_tile/singularity_act()
	return

/turf/open/floor/void_tile/TerraformTurf(path, new_baseturf, flags, defer_change = FALSE, ignore_air = FALSE)
	return
