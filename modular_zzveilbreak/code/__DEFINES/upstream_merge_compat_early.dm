// Included after splurt trait defines; supplies macros for Splurt + Veilbreak content compiled before the main modular_zzveilbreak block.

/// Hides splurt underwear / undershirt overlays when covered
#define HIDEUNDERWEAR (1<<22)
/// Hides wrist accessories when covered
#define HIDEWRISTS (1<<23)

// Roundstart "backpack" preference strings (Splurt)
#define SNAIL_SHELL "Snail Shell"
#define SLOOG_SHELL "Segmented Shell"

// Splurt underwear / extra wear layers — map to base mob layers until a full mobs.dm renumber
#define UNDERWEAR_LAYER BODY_LAYER
#define SOCKS_LAYER BODY_LAYER
#define BRA_LAYER BODY_LAYER
#define SHIRT_LAYER BODY_LAYER
#define EARS_EXTRA_LAYER EARS_LAYER
#define WRISTS_LAYER GLOVES_LAYER

// Resonant / Veilbreak psyker organ slot
#define ORGAN_SLOT_PSYKER "psyker"
