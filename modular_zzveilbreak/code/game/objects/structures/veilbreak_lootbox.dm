/// Dungeon loot crate: looks like a standard steel crate, drops one weighted Veilbreak item on first open.
/obj/structure/closet/crate/veilbreak_lootbox
	name = "weathered crate"
	desc = "An ordinary cargo crate, scuffed and stained. Whatever left it here did not bother with a manifest."
	/// Flag set when this crate is designated as a candidate to contain the Path Unseen void fragment
	var/has_unseen_void_shard = FALSE

/obj/structure/closet/crate/veilbreak_lootbox/PopulateContents()
	var/obj_type = pick_loot_from_table(veilbreak_lootbox_table)
	if(!obj_type)
		return
	new obj_type(src)

/obj/structure/closet/crate/veilbreak_lootbox/open(mob/living/user, special_effects = TRUE)
	. = ..()
	if(. && has_unseen_void_shard)
		claim_unseen_void_shard(src)
