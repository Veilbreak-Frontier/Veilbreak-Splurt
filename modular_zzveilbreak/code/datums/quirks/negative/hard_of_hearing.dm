#define TRAIT_HARD_OF_HEARING "hard_of_hearing"

#define SCRAMBLE_CHANCE_GLOBAL 30
#define SCRAMBLE_PROB_WHISPER 40
#define SCRAMBLE_PROB_DEFAULT 10
#define SCRAMBLE_PROB_RADIO_ADD 5
#define SCRAMBLE_PROB_SHOUT 2
#define SCRAMBLE_PROB_ALERT_ADD 10

/datum/quirk/hard_of_hearing
	name = "Hard of Hearing"
	desc = "Years of high-decibel machinery or atmospheric trauma have left your ears ringing. You frequently struggle to decipher speech, especially when it's quiet or the station is in chaos."
	value = -6
	mob_trait = TRAIT_HARD_OF_HEARING
	gain_text = span_notice("The world sounds muffled and distant, as if your ears are filled with cotton.")
	lose_text = span_danger("A sharp pop rings in your ears, and suddenly the world sounds crisp and clear again!")
	medical_record_text = "Patient presents with chronic sensorineural hearing loss. Condition is unresponsive to standard surgical intervention or regenerative chemicals."
	icon = "ear-deaf"

/datum/quirk/hard_of_hearing/add(client/client_source)
	. = ..()
	var/mob/living/carbon/human/H = quirk_holder
	if(istype(H))
		RegisterSignal(H, COMSIG_MOVABLE_HEAR, PROC_REF(on_hear))

/datum/quirk/hard_of_hearing/remove()
	var/mob/living/carbon/human/H = quirk_holder
	if(istype(H))
		UnregisterSignal(H, COMSIG_MOVABLE_HEAR)
	return ..()

/datum/quirk/hard_of_hearing/proc/on_hear(datum/source, list/hearing_args)
	SIGNAL_HANDLER

	var/mob/living/carbon/human/H = quirk_holder
	if(!H || H.stat == DEAD || HAS_TRAIT(H, TRAIT_DEAF))
		return

	if(hearing_args[HEARING_SPEAKER] == H)
		return

	if(!prob(SCRAMBLE_CHANCE_GLOBAL))
		return

	var/raw_message = hearing_args[HEARING_RAW_MESSAGE]
	if(!raw_message)
		return

	var/scramble_prob = SCRAMBLE_PROB_DEFAULT
	var/mode = hearing_args[HEARING_MESSAGE_MODE]

	switch(mode)
		if("whisper")
			scramble_prob = SCRAMBLE_PROB_WHISPER
		if("shout")
			scramble_prob = SCRAMBLE_PROB_SHOUT

	if(hearing_args[HEARING_RADIO_FREQ])
		scramble_prob += SCRAMBLE_PROB_RADIO_ADD

	if(SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED)
		scramble_prob += SCRAMBLE_PROB_ALERT_ADD

	var/scrambled = scramble_alphabet(raw_message, scramble_prob)

	if(scrambled != raw_message)
		var/static/list/strain_messages = list(
			"You strain to hear...",
			"The words sound muffled...",
			"You catch some of what was said...",
			"The audio cuts in and out...",
			"It sounds like they said...",
			"You struggle to make out the words...",
			"Through the ringing in your ears, you hear..."
		)
		hearing_args[HEARING_RAW_MESSAGE] = span_hypnophrase("<i>[pick(strain_messages)]</i> [scrambled]")
	else
		hearing_args[HEARING_RAW_MESSAGE] = scrambled

/proc/scramble_alphabet(phrase, probability = 25)
	if(probability <= 0 || !phrase)
		return phrase

	phrase = html_decode(phrase)
	var/list/out = list()
	var/phrase_len = length(phrase)

	var/i = 1
	while(i <= phrase_len)
		var/char = phrase[i]
		var/char_len = length(char)
		var/ascii_val = text2ascii(char)

		if(prob(probability) && ((ascii_val >= 65 && ascii_val <= 90) || (ascii_val >= 97 && ascii_val <= 122)))
			var/is_upper = (ascii_val >= 65 && ascii_val <= 90)
			out += ascii2text(is_upper ? rand(65, 90) : rand(97, 122))
		else
			out += char

		i += char_len

	return sanitize(jointext(out, ""))
