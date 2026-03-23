/datum/gas_recipe/crystallizer/void_shard
	id = "void_shard"
	name = "Void Shard"
	min_temp = 20000
	max_temp = 30000
	energy_release = -6000000
	requirements = list(/datum/gas/delirium = 1000)
	products = list(/obj/item/voidshard = 1)

/datum/gas_recipe/crystallizer/healing_pendant
	id = "healing_pendant"
	name = "Life Pendant"
	min_temp = 2
	max_temp = 4
	energy_release = 800000
	requirements = list(/datum/gas/healium = 200, /datum/gas/delirium = 200)
	products = list(/obj/item/clothing/neck/life_pendant = 1)

