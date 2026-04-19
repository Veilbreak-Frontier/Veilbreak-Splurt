/// Time scoped (zoom) before Precision Killer adds damage to shots.
#define VEILBREAK_PRECISION_KILLER_AIM_TIME (4 SECONDS)
/// Extra damage on qualifying projectiles.
#define VEILBREAK_PRECISION_KILLER_BONUS 10

/// Snipers with TRAIT_POWER_SNIPER deal extra damage after holding scope ~4s.
/datum/element/veilbreak_precision_killer

/datum/element/veilbreak_precision_killer/Attach(datum/target)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, SIGNAL_ADDTRAIT(TRAIT_USER_SCOPED), PROC_REF(on_scoped_trait_gain))
	RegisterSignal(target, SIGNAL_REMOVETRAIT(TRAIT_USER_SCOPED), PROC_REF(on_scoped_trait_loss))
	RegisterSignal(target, COMSIG_PROJECTILE_FIRER_BEFORE_FIRE, PROC_REF(on_projectile_before_fire))

/datum/element/veilbreak_precision_killer/Detach(datum/source, ...)
	if(isliving(source))
		var/mob/living/living_source = source
		living_source.veilbreak_sniper_scope_start = null
	UnregisterSignal(source, list(
		SIGNAL_ADDTRAIT(TRAIT_USER_SCOPED),
		SIGNAL_REMOVETRAIT(TRAIT_USER_SCOPED),
		COMSIG_PROJECTILE_FIRER_BEFORE_FIRE,
	))
	return ..()

/datum/element/veilbreak_precision_killer/proc/on_scoped_trait_gain(mob/living/user, trait)
	SIGNAL_HANDLER
	if(trait != TRAIT_USER_SCOPED)
		return
	user.veilbreak_sniper_scope_start = world.time

/datum/element/veilbreak_precision_killer/proc/on_scoped_trait_loss(mob/living/user, trait)
	SIGNAL_HANDLER
	if(trait != TRAIT_USER_SCOPED)
		return
	user.veilbreak_sniper_scope_start = null

/datum/element/veilbreak_precision_killer/proc/on_projectile_before_fire(mob/living/firer, obj/projectile/bullet, atom/fired_from, atom/original_target)
	SIGNAL_HANDLER
	if(!HAS_TRAIT(firer, TRAIT_POWER_SNIPER))
		return
	if(!isgun(fired_from))
		return
	if(!HAS_TRAIT(firer, TRAIT_USER_SCOPED))
		return
	if(!firer.veilbreak_sniper_scope_start)
		return
	if(world.time < firer.veilbreak_sniper_scope_start + VEILBREAK_PRECISION_KILLER_AIM_TIME)
		return
	if(!bullet.damage || bullet.damage_type == STAMINA)
		return
	bullet.damage += VEILBREAK_PRECISION_KILLER_BONUS

/datum/power/precision_killer/add(mob/living/carbon/human/target)
	target.AddElement(/datum/element/veilbreak_precision_killer)
