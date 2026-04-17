///This slime is a baby
#define SLIME_LIFE_STAGE_BABY "baby"
///This slime is an adult
#define SLIME_LIFE_STAGE_ADULT "adult"

///This lowest charge a slime can have
#define SLIME_MIN_POWER 0
///Dangerous levels of charge
#define SLIME_MEDIUM_POWER 5
///The highest level of charge a slime can have
#define SLIME_MAX_POWER 10

///The maximum amount of nutrition a slime can contain
#define SLIME_MAX_NUTRITION 200
///The starting nutrition of a slime
#define SLIME_STARTING_NUTRITION 100
/// Above it we grow our amount_grown and our power_level, below it we can eat
#define SLIME_GROW_NUTRITION 150
/// Below this, we feel hungry
#define SLIME_HUNGER_NUTRITION 50
/// Below this, we feel starving
#define SLIME_STARVE_NUTRITION 10

///The slime is not hungry. It might try to feed anyways.
#define SLIME_HUNGER_NONE 0
///The slime is more likely to feed on people
#define SLIME_HUNGER_HUNGRY 1
///The slime is very likely to feed on anything
#define SLIME_HUNGER_STARVING 2

#define SLIME_MOOD_NONE "none"
#define SLIME_MOOD_ANGRY "angry"
#define SLIME_MOOD_MISCHIEVOUS "mischievous"
#define SLIME_MOOD_POUT "pout"
#define SLIME_MOOD_SAD "sad"
#define SLIME_MOOD_SMILE ":3"

// Just slimin' here.
// Warning: These defines are used for slime icon states, so if you
// touch these names, remember to update icons/mob/simple/slimes.dmi!

#define SLIME_TYPE_ADAMANTINE "adamantine"
#define SLIME_TYPE_BLACK "black"
#define SLIME_TYPE_BLUE "blue"
#define SLIME_TYPE_BLUESPACE "bluespace"
#define SLIME_TYPE_CERULEAN "cerulean"
#define SLIME_TYPE_DARK_BLUE "dark-blue"
#define SLIME_TYPE_DARK_PURPLE "dark-purple"
#define SLIME_TYPE_GOLD "gold"
#define SLIME_TYPE_GREEN "green"
#define SLIME_TYPE_GREY "grey"
#define SLIME_TYPE_LIGHT_PINK "light-pink"
#define SLIME_TYPE_METAL "metal"
#define SLIME_TYPE_OIL "oil"
#define SLIME_TYPE_ORANGE "orange"
#define SLIME_TYPE_PINK "pink"
#define SLIME_TYPE_PURPLE "purple"
#define SLIME_TYPE_PYRITE "pyrite"
#define SLIME_TYPE_RAINBOW "rainbow"
#define SLIME_TYPE_RED "red"
#define SLIME_TYPE_SEPIA "sepia"
#define SLIME_TYPE_SILVER "silver"
#define SLIME_TYPE_YELLOW "yellow"

/// Bitflags for /mob/living/basic/slime/var/transformeffects (transformative crossbreeds)
#define SLIME_EFFECT_DEFAULT NONE
#define SLIME_EFFECT_GREY (1<<0)
#define SLIME_EFFECT_ORANGE (1<<1)
#define SLIME_EFFECT_PURPLE (1<<2)
#define SLIME_EFFECT_BLUE (1<<3)
#define SLIME_EFFECT_METAL (1<<4)
#define SLIME_EFFECT_YELLOW (1<<5)
#define SLIME_EFFECT_DARK_PURPLE (1<<6)
#define SLIME_EFFECT_DARK_BLUE (1<<7)
#define SLIME_EFFECT_SILVER (1<<8)
#define SLIME_EFFECT_BLUESPACE (1<<9)
#define SLIME_EFFECT_SEPIA (1<<10)
#define SLIME_EFFECT_CERULEAN (1<<11)
#define SLIME_EFFECT_PYRITE (1<<12)
#define SLIME_EFFECT_RED (1<<13)
#define SLIME_EFFECT_GREEN (1<<14)
#define SLIME_EFFECT_PINK (1<<15)
#define SLIME_EFFECT_GOLD (1<<16)
#define SLIME_EFFECT_OIL (1<<17)
#define SLIME_EFFECT_BLACK (1<<18)
#define SLIME_EFFECT_LIGHT_PINK (1<<19)
#define SLIME_EFFECT_ADAMANTINE (1<<20)
#define SLIME_EFFECT_RAINBOW (1<<21)

// The alpha value of transperent slime types
#define SLIME_TRANSPARENCY_ALPHA 180
