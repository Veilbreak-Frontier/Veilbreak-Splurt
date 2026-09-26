//Lightning and thunder storm culling
/datum/weather/particle/ash_storm/New(list/z_levels, list/weather_data)
	if(isnull(weather_data?[WEATHER_FORCED_FLAGS]))
		weather_flags &= ~WEATHER_THUNDER

	return ..()
