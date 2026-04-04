// Upgrading gear with voidshards.
// Modifies the items directly to apply the void effect.

/datum/void_infusion_recipe
	var/target_type
	var/name_prefix = "Void-Infused"
	var/infusion_color = "#c8a4e9"

/datum/void_infusion_recipe/proc/matches(obj/item/target)
	if(!istype(target, target_type))
		return FALSE
	if(findtext(target.name, "[name_prefix]"))
		return FALSE
	return TRUE

/datum/void_infusion_recipe/proc/apply(obj/item/target)
	target.name = "[name_prefix] [initial(target.name)]"
	target.desc = "[initial(target.desc)] It pulses faintly with dark, purple energy."
	target.color = infusion_color // Voidshard purple glow
	target.light_range = 2
	target.light_power = 0.5
	target.light_color = infusion_color
	return TRUE

/datum/void_infusion_recipe/elder_atmosian_suit
	target_type = /obj/item/clothing/suit/armor/elder_atmosian

/datum/void_infusion_recipe/elder_atmosian_suit/apply(obj/item/clothing/suit/armor/elder_atmosian/target)
	..()
	target.set_armor(target.get_armor().generate_new_with_modifiers(list(ARMOR_ALL = 20)))
	target.attach_clothing_traits(TRAIT_RADIMMUNE)
	return TRUE

/datum/void_infusion_recipe/elder_atmosian_helmet
	target_type = /obj/item/clothing/head/helmet/elder_atmosian

/datum/void_infusion_recipe/elder_atmosian_helmet/apply(obj/item/clothing/head/helmet/elder_atmosian/target)
	..()
	target.set_armor(target.get_armor().generate_new_with_modifiers(list(ARMOR_ALL = 20)))
	target.attach_clothing_traits(TRAIT_RADIMMUNE)
	return TRUE

/datum/void_infusion_recipe/hydro_duffel
	target_type = /obj/item/storage/backpack/hydro_duffel

/datum/void_infusion_recipe/hydro_duffel/apply(obj/item/storage/backpack/hydro_duffel/target)
	target.name = "[name_prefix] [initial(target.name)]"
	target.desc = "[initial(target.desc)] It pulses faintly with dark, purple energy, seeming bigger on the inside."
	target.color = infusion_color
	target.light_range = 2
	target.light_power = 0.5
	target.light_color = infusion_color
	if(target.atom_storage)
		target.atom_storage.max_slots += 5
		target.atom_storage.max_total_storage += 25
		target.atom_storage.max_specific_storage = WEIGHT_CLASS_GIGANTIC
	return TRUE

/datum/void_infusion_recipe/metal_h2_axe
	target_type = /obj/item/fireaxe/metal_h2_axe

/datum/void_infusion_recipe/metal_h2_axe/apply(obj/item/fireaxe/metal_h2_axe/target)
	target.name = "[name_prefix] [initial(target.name)]"
	target.desc = "[initial(target.desc)] The blade hums with dark, purple energy, eager to strike down the void."
	target.color = infusion_color
	target.light_range = 2
	target.light_power = 0.5
	target.light_color = infusion_color
	return TRUE

/datum/void_infusion_recipe/kinetic_accelerator
	target_type = /obj/item/gun/energy/recharge/kinetic_accelerator

/datum/void_infusion_recipe/kinetic_accelerator/apply(obj/item/gun/energy/recharge/kinetic_accelerator/target)
	target.name = "[name_prefix] [initial(target.name)]"
	target.desc = "[initial(target.desc)] Dark energy coils through the core; bolts strike harder and tear deeper into creatures of the void."
	target.color = infusion_color
	target.light_range = 2
	target.light_power = 0.5
	target.light_color = infusion_color
	target.void_infusion_damage_bonus = 10
	target.void_infusion_antivoid_bonus = 20
	return TRUE

/obj/item/gun/energy/recharge/kinetic_accelerator
	/// Bonus projectile damage from void infusion (all targets).
	var/void_infusion_damage_bonus = 0
	/// Extra damage vs mobs in FACTION_VOID; applied when the bolt pre-hits a living target.
	var/void_infusion_antivoid_bonus = 0

/obj/item/gun/energy/recharge/kinetic_accelerator/modify_projectile(obj/projectile/kinetic/kinetic_projectile)
	kinetic_projectile.kinetic_gun = src
	for(var/obj/item/borg/upgrade/modkit/modkit_upgrade as anything in modkits)
		modkit_upgrade.modify_projectile(kinetic_projectile)
	kinetic_projectile.bonus_vs_void = void_infusion_antivoid_bonus
	if(void_infusion_damage_bonus)
		kinetic_projectile.damage += void_infusion_damage_bonus

/obj/projectile/kinetic
	var/bonus_vs_void = 0

/obj/projectile/kinetic/prehit_pierce(atom/target)
	if(is_type_in_typecache(target, kinetic_gun?.ignored_mob_types))
		return PROJECTILE_PIERCE_PHASE
	. = ..()
	if(. == PROJECTILE_PIERCE_PHASE)
		return
	for(var/obj/item/borg/upgrade/modkit/modkit_upgrade as anything in kinetic_gun?.modkits)
		modkit_upgrade.projectile_prehit(src, target, kinetic_gun)
	if(!pressure_decrease_active && !lavaland_equipment_pressure_check(get_turf(target)))
		name = "weakened [name]"
		damage = damage * pressure_decrease
		pressure_decrease_active = TRUE
	if(bonus_vs_void && isliving(target))
		var/mob/living/living_target = target
		if(FACTION_VOID in living_target.faction)
			damage += bonus_vs_void

/obj/item/fireaxe/metal_h2_axe/attack(mob/living/target, mob/living/user, def_zone)
	if(findtext(name, "Void-Infused") && isliving(target) && (FACTION_VOID in target.faction))
		target.apply_damage(12, BRUTE, def_zone)
		to_chat(user, "<span class='warning'>\\The [src] burns [target] with void energy!</span>")
	return ..()

// --- Void-infused heated rebar crossbow: mob-only heat bursts (no turf/obj ex_act). One burst per projectile hit (each pierce counts). ---

/datum/void_infusion_recipe/heated_rebar_crossbow
	target_type = /obj/item/gun/ballistic/rifle/rebarxbow

/datum/void_infusion_recipe/heated_rebar_crossbow/apply(obj/item/gun/ballistic/rifle/rebarxbow/target)
	..()
	target.desc += " Each shot detonates with a snap of contained heat."
	target.void_heat_infused = TRUE
	return TRUE

/obj/item/gun/ballistic/rifle/rebarxbow
	/// When TRUE (void infusion), rebar projectiles trigger a small mob-only burn burst on each impact.
	var/void_heat_infused = FALSE

/obj/item/ammo_casing/rebar/ready_proj(atom/target, mob/living/user, quiet, zone_override = "", atom/fired_from)
	. = ..()
	if(!loaded_projectile || !istype(loaded_projectile, /obj/projectile/bullet/rebar))
		return
	var/obj/item/gun/ballistic/rifle/rebarxbow/bow = fired_from
	if(!istype(bow) || !bow.void_heat_infused)
		return
	var/obj/projectile/bullet/rebar/bolt = loaded_projectile
	bolt.void_heat_burst = TRUE

/obj/projectile/bullet/rebar
	/// Set when fired from a void-infused rebar crossbow; triggers [/proc/void_crossbow_heat_burst] on each [/obj/projectile/bullet/rebar/proc/on_hit].
	var/void_heat_burst = FALSE

/obj/projectile/bullet/rebar/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(!void_heat_burst || . == BULLET_ACT_BLOCK || blocked >= 100)
		return
	var/turf/epicenter = get_turf(target)
	if(epicenter)
		void_crossbow_heat_burst(epicenter)

/// Applies a tight heat "explosion" to living mobs in range only — no station damage.
/proc/void_crossbow_heat_burst(turf/epicenter)
	if(!epicenter)
		return
	new /obj/effect/temp_visual/kinetic_blast(epicenter)
	playsound(epicenter, 'sound/effects/explosion/explosion1.ogg', 35, TRUE)

	for(var/mob/living/victim in orange(1, epicenter))
		if(victim.stat == DEAD)
			continue
		var/dist = get_dist(victim, epicenter)
		var/damage = dist ? 8 : 15
		victim.apply_damage(damage, BURN, spread_damage = TRUE, wound_bonus = CANT_WOUND)
