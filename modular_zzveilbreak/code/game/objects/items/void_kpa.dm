// Modular void laser rifle: low base heat damage with anti-void bonus and delayed rapid self recharge.

/obj/item/gun/energy/void_piercer
	name = "void piercer"
	desc = "A compact void-pattern heat projector. It hits lightly, but tears through creatures of the void."
	icon = 'modular_zzveilbreak/icons/item_icons/void_gun_void_KPA.dmi'
	icon_state = "abdication100"
	base_icon_state = "abdication"
	inhand_icon_state = "abdication100"
	lefthand_file = 'modular_zzveilbreak/icons/item_icons/void_gun_void_KPA.dmi'
	righthand_file = 'modular_zzveilbreak/icons/item_icons/void_gun_void_KPA.dmi'
	automatic_charge_overlays = FALSE
	ammo_type = list(/obj/item/ammo_casing/energy/void_piercer)
	fire_sound = 'sound/items/weapons/laser.ogg'
	w_class = WEIGHT_CLASS_NORMAL
	selfcharge = TRUE
	charge_delay = 1 SECONDS
	self_charge_amount = STANDARD_CELL_CHARGE
	/// How long we must avoid firing before recharge can begin.
	var/recharge_idle_delay = 7 SECONDS
	/// World time after which self recharge is allowed.
	var/next_recharge_window = 0

/obj/item/gun/energy/void_piercer/Initialize(mapload)
	. = ..()
	next_recharge_window = world.time + recharge_idle_delay
	update_icon_state()

/obj/item/gun/energy/void_piercer/shoot_live_shot(mob/living/user, pointblank = 0, atom/pbtarget = null, message = 1)
	. = ..()
	charge_timer = 0
	next_recharge_window = world.time + recharge_idle_delay

/obj/item/gun/energy/void_piercer/process(seconds_per_tick)
	if(world.time < next_recharge_window)
		return
	return ..()

/obj/item/gun/energy/void_piercer/update_icon_state()
	var/charge_percent = 0
	if(cell && cell.maxcharge > 0)
		charge_percent = round((cell.charge / cell.maxcharge) * 100)
	var/charge_step = 0
	if(charge_percent >= 100)
		charge_step = 100
	else if(charge_percent >= 75)
		charge_step = 75
	else if(charge_percent >= 50)
		charge_step = 50
	else if(charge_percent >= 25)
		charge_step = 25
	icon_state = "[base_icon_state][charge_step]"
	inhand_icon_state = icon_state
	return ..()

/obj/item/ammo_casing/energy/void_piercer
	projectile_type = /obj/projectile/beam/laser/void_piercer
	e_cost = LASER_SHOTS(8, STANDARD_CELL_CHARGE)
	select_name = "void pulse"
	fire_sound = 'sound/items/weapons/laser.ogg'

/obj/projectile/beam/laser/void_piercer
	name = "void pulse"
	icon_state = "laser"
	damage = 10
	damage_type = BURN
	light_color = COLOR_STRONG_VIOLET
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser
	projectile_piercing = ALL
	/// Number of additional targets this projectile may pierce.
	var/pierce_hits = 1
	/// Additional burn damage when striking mobs aligned with the void.
	var/void_bonus_damage = 30

/obj/projectile/beam/laser/void_piercer/on_hit(atom/target, blocked = 0, pierce_hit)
	if(pierce_hits <= 0)
		projectile_piercing = NONE
	pierce_hits -= 1
	. = ..()
	if(!isliving(target))
		return
	var/mob/living/living_target = target
	if(FACTION_VOID in living_target.faction)
		living_target.apply_damage(void_bonus_damage, BURN, spread_damage = TRUE, wound_bonus = CANT_WOUND)
