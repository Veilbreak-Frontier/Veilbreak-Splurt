/// Removes all the loot and achievements from megafauna for bitrunning related
/mob/living/simple_animal/hostile/megafauna/proc/make_virtual_megafauna()
	var/new_max = clamp(maxHealth * 0.5, 600, 1300)
	maxHealth = new_max
	health = new_max

	true_spawn = FALSE

//// -----------SPLURT EDIT BELOW FULL REMAKE-----------


	// Creates an instance-local shallow copy of `loot`
	if(loot)
		var/list/new_loot = list()
		for(var/key in loot)
			new_loot[key] = loot[key]
		loot = new_loot
	loot.Cut()
	loot += /obj/structure/closet/crate/secure/bitrunning/encrypted

	// Creates an instance-local shallow copy of `crusher_loot`
	if(crusher_loot)
		var/list/new_crusher = list()
		for(var/key in crusher_loot)
			new_crusher[key] = crusher_loot[key]
		crusher_loot = new_crusher
	crusher_loot.Cut()
	crusher_loot += /obj/structure/closet/crate/secure/bitrunning/encrypted
