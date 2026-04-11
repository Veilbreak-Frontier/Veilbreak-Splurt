/// Dungeon loot crate: looks like a standard steel crate, drops one weighted Veilbreak item on first open.
/obj/structure/closet/crate/veilbreak_lootbox
	name = "weathered crate"
	desc = "An ordinary cargo crate, scuffed and stained. Whatever left it here did not bother with a manifest."
	// Uses parent /obj/structure/closet/crate icons (icons/obj/storage/crates.dmi, "crate").

/obj/structure/closet/crate/veilbreak_lootbox/PopulateContents()
	var/obj_type = pick_loot_from_table(veilbreak_lootbox_table)
	if(!obj_type)
		return
	new obj_type(src)
