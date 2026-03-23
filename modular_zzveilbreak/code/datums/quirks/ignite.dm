/datum/quirk/ignite
	name = "Pyromaniac"
	desc = "You have a knack for starting fires. You can cast Ignite."
	value = 4
	icon = FA_ICON_FIRE

/datum/quirk/ignite/add(client/client_source)
    var/datum/action/cooldown/spell/pointed/ignite/spell = new(quirk_holder)
    spell.Grant(quirk_holder)

    if(client_source?.prefs)
        var/custom_incantation = client_source.prefs.read_preference(/datum/preference/text/ignite_incantation)
        if(custom_incantation)
            spell.invocation = custom_incantation

/datum/quirk/ignite/remove()
	var/datum/action/cooldown/spell/pointed/ignite/spell = locate() in quirk_holder.actions
	if(spell)
		spell.Remove(quirk_holder)

/datum/quirk_constant_data/ignite
	associated_typepath = /datum/quirk/ignite
	customization_options = list(/datum/preference/text/ignite_incantation)
