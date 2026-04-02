// Upgrading Elder Atmosian gear with voidshards.
// Modifies the items directly to apply the void effect.

/obj/item/clothing/suit/armor/elder_atmosian/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/voidshard))
		if(name == "Void-Infused [initial(name)]")
			to_chat(user, "<span class='warning'>\The [src] is already infused with the void!</span>")
			return TRUE

		to_chat(user, "<span class='notice'>You crush \the [W] against \the [src], infusing it with void energy!</span>")
		playsound(loc, 'modular_zzveilbreak/sound/effects/shard-infusion.mp3', 50, 1)

		name = "Void-Infused [initial(name)]"
		desc = "[initial(desc)] It pulses faintly with dark, purple energy."
		color = "#8a2be2" // Voidshard purple glow
		light_range = 2
		light_power = 0.5
		light_color = "#8a2be2"

		// Create a stronger armor datum for the void version based on the original
		var/datum/armor/void_armor = new
		void_armor.melee = armor.melee + 20
		void_armor.bullet = armor.bullet + 20
		void_armor.laser = armor.laser + 20
		void_armor.energy = armor.energy + 20
		void_armor.bomb = armor.bomb + 20
		void_armor.bio = armor.bio + 20
		void_armor.fire = armor.fire + 20
		void_armor.acid = armor.acid + 20
		void_armor.wound = armor.wound + 20
		armor = void_armor

		qdel(W)
		return TRUE
	return ..()

/obj/item/clothing/head/helmet/elder_atmosian/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/voidshard))
		if(name == "Void-Infused [initial(name)]")
			to_chat(user, "<span class='warning'>\The [src] is already infused with the void!</span>")
			return TRUE

		to_chat(user, "<span class='notice'>You crush \the [W] against \the [src], infusing it with void energy!</span>")
		playsound(loc, 'modular_zzveilbreak/sound/effects/shard-infusion.mp3', 50, 1)

		name = "Void-Infused [initial(name)]"
		desc = "[initial(desc)] It pulses faintly with dark, purple energy."
		color = "#8a2be2"
		light_range = 2
		light_power = 0.5
		light_color = "#8a2be2"

		var/datum/armor/void_armor = new
		void_armor.melee = armor.melee + 20
		void_armor.bullet = armor.bullet + 20
		void_armor.laser = armor.laser + 20
		void_armor.energy = armor.energy + 20
		void_armor.bomb = armor.bomb + 20
		void_armor.bio = armor.bio + 20
		void_armor.fire = armor.fire + 20
		void_armor.acid = armor.acid + 20
		void_armor.wound = armor.wound + 20
		armor = void_armor

		qdel(W)
		return TRUE
	return ..()

/obj/item/storage/backpack/hydro_duffel/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/voidshard))
		if(name == "Void-Infused [initial(name)]")
			to_chat(user, "<span class='warning'>\The [src] is already infused with the void!</span>")
			return TRUE

		to_chat(user, "<span class='notice'>You crush \the [W] against \the [src], infusing it with void energy!</span>")
		playsound(loc, 'modular_zzveilbreak/sound/effects/shard-infusion.mp3', 50, 1)

		name = "Void-Infused [initial(name)]"
		desc = "[initial(desc)] It pulses faintly with dark, purple energy, seeming bigger on the inside."
		color = "#8a2be2"
		light_range = 2
		light_power = 0.5
		light_color = "#8a2be2"

		if(atom_storage)
			atom_storage.max_slots += 10
			atom_storage.max_total_storage += 50
			atom_storage.max_specific_storage = WEIGHT_CLASS_GIGANTIC

		qdel(W)
		return TRUE
	return ..()
