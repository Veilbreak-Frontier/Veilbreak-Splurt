/obj/item/organ/genital/breasts
	internal_fluid_datum = /datum/reagent/consumable/breast_milk
	internal_fluid_maximum = 10000

/obj/item/organ/genital/breasts/build_from_dna(datum/dna/DNA, associated_key)
    . = ..()
    var/breasts_mult = 1
    var/size = DNA.features["breasts_size"] || 0.5

    switch(genital_type)
        if("pair")
            breasts_mult = 1
        if("quad")
            breasts_mult = 1.4
        if("sextuple")
            breasts_mult = 1.8

    internal_fluid_maximum = (size * 15 + 50) * breasts_mult

    internal_fluid_maximum = clamp(internal_fluid_maximum, 10, 1000)

    reagents.maximum_volume = internal_fluid_maximum
