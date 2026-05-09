/// Succubus antagonist - hunts for 'fluids', can mark and corrupt victims
#define ROLE_SUCCUBUS "Succubus"

/// Maximum mark level (1-5); each level adds cumulative effects
#define SUCCUBUS_MARK_MAX_LEVEL 5

/// Fluid production multiplier at mark level 1+
#define SUCCUBUS_MARK_FLUID_MULTIPLIER 1.35

/// Lust tolerance reduction per level (multiplier applied to max arousal threshold)
#define SUCCUBUS_MARK_LUST_TOLERANCE_REDUCTION_PER_LEVEL 0.08

/// Subversion progress added per tick when victim has level 3+ mark
#define SUCCUBUS_SUBVERSION_RATE 0.5

/// Default choker text - customize in-game or in code; %VICTIM% and %ANTAG% are replaced with names
#define SUCCUBUS_CHOKER_DEFAULT_TEXT "A choker thats a little too tight, constantly reminding %VICTIM% they are %ANTAG%'s slave."

/// Trait applied when subversion reaches 100% (serving the succubus)
#define TRAIT_SUCCUBUS_SERVANT "succubus_servant"
