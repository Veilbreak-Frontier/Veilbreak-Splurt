/datum/quirk/will_to_live
	name = "Will to Live"
	desc = "You heal slowly over time, as long as you are alive."
	value = 8
	var/healing_process_running = FALSE

/datum/quirk/will_to_live/add()
	if(!quirk_holder)
		return
	healing_process_running = TRUE
	process_healing()

/datum/quirk/will_to_live/proc/process_healing()
	if(!healing_process_running || !quirk_holder || QDELETED(quirk_holder))
		return

	if(quirk_holder.stat == CONSCIOUS)
		var/list/damage_types = list("brute", "fire", "tox", "oxy")
		damage_types = shuffle(damage_types)

		for(var/damage_type in damage_types)
			var/has_damage = FALSE
			switch(damage_type)
				if("brute")
					if(quirk_holder.get_brute_loss() > 0)
						has_damage = TRUE
						quirk_holder.adjust_brute_loss(-1)
				if("fire")
					if(quirk_holder.get_fire_loss() > 0)
						has_damage = TRUE
						quirk_holder.adjust_fire_loss(-1)
				if("tox")
					if(quirk_holder.get_tox_loss() > 0)
						has_damage = TRUE
						quirk_holder.adjust_tox_loss(-1)
				if("oxy")
					if(quirk_holder.get_oxy_loss() > 0)
						has_damage = TRUE
						quirk_holder.adjust_oxy_loss(-1)
			if(has_damage)
				break

	addtimer(CALLBACK(src, .proc/process_healing), 10 SECONDS)

/datum/quirk/will_to_live/remove()
	healing_process_running = FALSE
	..()

/datum/quirk_constant_data/will_to_live
	associated_typepath = /datum/quirk/will_to_live
