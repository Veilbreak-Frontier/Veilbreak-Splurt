/*
 * Veilbreak edit - fixes cursed ash carver trophy attachment.
 *
 * The zzplurt override on /obj/item/kinetic_crusher/cursed/Initialize
 * qdels the reskinable_item component AFTER the base crusher Initialize
 * Deleting a component mid-Initialize is the only difference between the
 * cursed carver and a stock crusher, and it's what breaks trophy attachment.
 *
 * Fix: override update_reskin() to be a no-op on this subtype so the
 * component is never installed. The zzplurt qdel loop then iterates an
 * empty list and becomes harmless.
 */
/obj/item/kinetic_crusher/cursed/update_reskin(datum/atom_skin/crusher_skin/default_skin_typepath)
	return

/*
 * Optional belt-and-braces: neutralise the zzplurt Initialize override
 * so its GetComponents/qdel loop doesn't run at all. Since this file
 * loads after modular_zzplurt, this definition wins.
 */
/obj/item/kinetic_crusher/cursed/Initialize(mapload)
	. = ..()
	// deliberately does NOT run the zzplurt reskin-component qdel loop
