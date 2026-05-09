/area/dungeon/inside
    area_flags=UNIQUE_AREA
    outdoors=FALSE
    mood_bonus=-3
    mood_message = "Something about this place unsettles your mind"
    requires_power=FALSE
    always_unpowered=FALSE
    default_gravity=STANDARD_GRAVITY

/area/dungeon/outside
    area_flags=UNIQUE_AREA
    outdoors=TRUE
    default_gravity=ZERO_GRAVITY

/area/dungeon/garden
	area_flags=UNIQUE_AREA
	outdoors=TRUE
	default_gravity = STANDARD_GRAVITY
	requires_power=FALSE

/area/ruin/powered/narsianthroneroom
	name = "Narsian Throne Room"
	icon = 'icons/area/areas_ruins.dmi'
	icon_state = "ruins"
	default_gravity = STANDARD_GRAVITY
	area_flags = HIDDEN_AREA
	ambience_index = AMBIENCE_RUINS
	flags_1 = CAN_BE_DIRTY_1

/area/ruin/powered/derelicthospital
	name = "BrokenHospital"
	icon = 'icons/area/areas_ruins.dmi'
	icon_state = "ruins"
	default_gravity = STANDARD_GRAVITY
	area_flags = HIDDEN_AREA
	ambience_index = AMBIENCE_RUINS
	flags_1 = CAN_BE_DIRTY_1

/area/ruin/powered/listeninglooter
	name = "Listening Outpost GAIA-14"
	icon = 'icons/area/areas_ruins.dmi'
	icon_state = "ruins"
	default_gravity = STANDARD_GRAVITY
	area_flags = HIDDEN_AREA
	ambience_index = AMBIENCE_RUINS
	flags_1 = CAN_BE_DIRTY_1

/area/ruin/powered/demonoutbreak
	name = "Estação de Pesquisa de Campo ROMEU-34"
	icon = 'icons/area/areas_ruins.dmi'
	icon_state = "ruins"
	default_gravity = STANDARD_GRAVITY
	area_flags = HIDDEN_AREA
	ambience_index = AMBIENCE_RUINS
	flags_1 = CAN_BE_DIRTY_1

/area/ruin/powered/lavapool
	name = "Lavapool"
	icon = 'icons/area/areas_ruins.dmi'
	icon_state = "ruins"
	default_gravity = STANDARD_GRAVITY
	area_flags = HIDDEN_AREA
	ambience_index = AMBIENCE_RUINS
	flags_1 = CAN_BE_DIRTY_1
