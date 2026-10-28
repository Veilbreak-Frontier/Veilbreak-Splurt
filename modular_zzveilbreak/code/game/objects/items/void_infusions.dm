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
	target.void_infusion_antivoid_bonus = 30
	return TRUE

/obj/item/gun/energy/recharge/kinetic_accelerator
	icon = 'modular_zzveilbreak/icons/item_icons/void_gun_void_KPA.dmi'
	icon_state = "vkineticgun"
	base_icon_state = "vkineticgun"
	inhand_icon_state = "vkineticgun"
	lefthand_file = 'modular_zzveilbreak/icons/item_icons/lefthand.dmi'
	righthand_file = 'modular_zzveilbreak/icons/item_icons/righthand.dmi'
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

// --- Void-Infused Kinetic Crusher Integration ---

/datum/void_infusion_recipe/kinetic_crusher
	target_type = /obj/item/kinetic_crusher

/datum/void_infusion_recipe/kinetic_crusher/matches(obj/item/target)
	if(!istype(target, target_type))
		return FALSE
	if(findtext(target.name, name_prefix))
		return FALSE
	return TRUE

/datum/void_infusion_recipe/kinetic_crusher/apply(obj/item/kinetic_crusher/target)
	..()
	target.name = "[name_prefix] [initial(target.name)]"
	target.desc += " Dark void energy coils around its chassis. Striking a marked target unleashes a crushing void cleave that tears through space behind them."
	target.void_infused = TRUE
	return TRUE

/obj/item/kinetic_crusher
	/// Tracks whether this specific crusher has been void-infused
	var/void_infused = FALSE
	/// Tracks the void cleave's 7-second cooldown timestamp
	var/void_cleave_cooldown = 0

// MENZİLLİ ATIŞ: Atış rengini mor yapmak için mevcut kodun
/obj/item/kinetic_crusher/fire_kinetic_blast(atom/target, mob/living/user, list/modifiers)
	. = ..()
	if(!void_infused)
		return

	for(var/obj/projectile/destabilizer/D in range(1, user))
		if(D.fired_from == src)
			D.name = "void-infused destabilizing force"
			D.color = "#c8a4e9"
			break

// MENZİLLİ VURUŞ (MARK): Mermi hedefe deyince hem native mark'ı hem bizim custom mark'ı uygular
/obj/projectile/destabilizer/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	var/obj/item/kinetic_crusher/crusher = fired_from

	if(istype(crusher) && crusher.void_infused && isliving(target))
		var/mob/living/living_target = target

		if(istype(living_target, /mob/living/basic/void_creature) || (FACTION_VOID in living_target.faction))
			// Native status effect'i uygula (Biotype sayesinde native animasyon artık burada sorunsuz tetiklenecek)
			living_target.apply_status_effect(/datum/status_effect/crusher_mark, boosted, crusher)

			// Yedek ve garanti değişkenimiz
			living_target.void_crusher_marked = TRUE

			// Mermi çarpma efekti
			new /obj/effect/temp_visual/kinetic_blast(get_turf(living_target))

			if(isliving(firer))
				to_chat(firer, span_notice("You have marked [living_target] with void destabilization!"))

// YAKIN DÖVÜŞ VURUŞU (DETONATION): Esas patlama ve animasyonun döndüğü yer!
/obj/item/kinetic_crusher/attack(mob/living/target, mob/living/carbon/user)
	if(!void_infused || !isliving(target))
		return ..()

	// Eğer silah iki elle tutuluyorsa ve hedef bir şekilde işaretliyse (Custom veya Native Status Effect)
	var/has_mark = (target.void_crusher_marked || target.has_status_effect(/datum/status_effect/crusher_mark))
	var/is_wielded = HAS_TRAIT(src, TRAIT_WIELDED)

	// Void faction'ına hasar bağışıklığı/düzenlemesi yaptığın orijinal kodun bloğu
	var/old_force = force
	if(is_wielded && (FACTION_VOID in target.faction))
		force = force_wielded

	// --- KRİTİK ADIM ---
	// Parent call (..()) çağrısını yapıyoruz.
	// İçeride biotype = MOB_MINING aktif olduğu için TG native kodu mark'ı bulacak,
	// orijinal patlama animasyonunu/sesini (Crusher Deplete) OYNATACAK ve mark'ı temizleyecektir.
	. = ..()

	force = old_force // Force'u eski haline geri çek

	// Eğer vuruş yapıldığında mark var idiyse, silah wielded ise ve hedef ölmediyse Void Cleave'i patlat!
	if(is_wielded && has_mark && !QDELETED(target))
		target.void_crusher_marked = FALSE // Bizim markı sıfırla
		handle_void_cleave(target, user)   // Ekstra mor Void Cleave alan hasarını tetikle

	return .

// VOID CLEAVE ALAN HASARI VE GÖRSEL EFEKT YARDIMCI PROC'U
/obj/item/kinetic_crusher/proc/handle_void_cleave(mob/living/target, mob/living/user)
	if(world.time < void_cleave_cooldown)
		return

	void_cleave_cooldown = world.time + 7 SECONDS
	var/cleave_dir = user.dir
	var/turf/origin_turf = get_step(target, cleave_dir)

	if(!origin_turf)
		return

	var/list/target_turfs = list(origin_turf)
	var/turf/left_cleave = get_step(origin_turf, turn(cleave_dir, 90))
	if(left_cleave)
		target_turfs += left_cleave

	var/turf/right_cleave = get_step(origin_turf, turn(cleave_dir, -90))
	if(right_cleave)
		target_turfs += right_cleave

	// (Wielded + Detonation) Hasarı
	var/sweep_damage = force_wielded + detonation_damage

	for(var/turf/T in target_turfs)
		var/obj/effect/temp_visual/kinetic_blast/blast = new(T)
		if(blast)
			blast.color = "#c8a4e9" // Mor Void Efekti

		for(var/mob/living/victim in T)
			if(victim == user || victim == target)
				continue

			victim.apply_damage(sweep_damage, BRUTE)
			to_chat(victim, span_userdanger("A devastating purple void cleave from [user]'s crusher cuts through space and batters you!"))

	to_chat(user, span_notice("Void Cleave successful! Space ruptures behind your target."))

// Mob değişken tanımı
/mob/living
	var/void_crusher_marked = FALSE

