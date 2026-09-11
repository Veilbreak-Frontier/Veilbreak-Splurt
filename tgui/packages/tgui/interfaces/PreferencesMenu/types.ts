import type { BooleanLike } from 'tgui-core/react';

import type { sendAct } from '../../events/act';
import type {
  LoadoutCategory,
  LoadoutList,
  typePath,
} from './CharacterPreferences/loadout/base';
import type { Gender } from './preferences/gender';

export enum Food {
  Alcohol = 'ALCOHOL',
  Breakfast = 'BREAKFAST',
  Bugs = 'BUGS',
  Cloth = 'CLOTH',
  Dairy = 'DAIRY',
  Fried = 'FRIED',
  Fruit = 'FRUIT',
  Gore = 'GORE',
  Grain = 'GRAIN',
  Gross = 'GROSS',
  Junkfood = 'JUNKFOOD',
  Meat = 'MEAT',
  Nuts = 'NUTS',
  Oranges = 'ORANGES',
  Pineapple = 'PINEAPPLE',
  Raw = 'RAW',
  Seafood = 'SEAFOOD',
  Stone = 'STONE',
  Sugar = 'SUGAR',
  Toxic = 'TOXIC',
  Vegetables = 'VEGETABLES',
  Egg = 'EGG',
  Bloody = 'BLOODY', // SKYRAT EDIT ADDITION - Hemophage Food
}

export enum JobPriority {
  Low = 1,
  Medium = 2,
  High = 3,
}

type JobPreference = {
  job: string;
  priority: JobPriority | null;
  assigned_profile_slot: number | null;
};

export type Name = {
  can_randomize: BooleanLike;
  explanation: string;
  group: string;
};

export type Species = {
  name: string;
  desc: string[];
  lore: string[];
  icon: string;
  sort_bottom: BooleanLike;
  //BUBBER EDIT ADD: Sort_bottom, whether a species is sorted to the bottom of the list.

  use_skintones: BooleanLike;
  sexes: BooleanLike;

  enabled_features: string[];

  perks: {
    positive: Perk[];
    negative: Perk[];
    neutral: Perk[];
  };

  diet?: {
    liked_food: Food[];
    disliked_food: Food[];
    toxic_food: Food[];
  };
};

export type Perk = {
  ui_icon: string;
  name: string;
  description: string;
};

export type Department = {
  head?: string;
  color?: string;
};

export type Job = {
  description: string;
  department: string;
  // SKYRAT EDIT
  alt_titles?: string[];
  // SKYRAT EDIT END
};

export type Quirk = {
  description: string;
  icon: string;
  name: string;
  value: number;
  customizable: boolean;
  customization_options?: string[];
};

// SKYRAT EDIT START
export type Language = {
  description: string;
  name: string;
  icon: string;
  can_understand: boolean;
  can_speak: boolean;
};
/// ID of a given power path.
export type PowerPathId = string;
/// The data from a power path's datum, which is defined and communicated from DM.
export type PowerPathData = {
  displayName: string;
  archetypeId: string;
  iconAssetName?: string;
  isAvailable: boolean;
  mechanicsText: string;
  overviewText: string;
  pathLimitExempt?: boolean;
  themeColor: string;
};

export type Marking = {
  name: string;
  color: string;
  marking_id: string;
};
/// archetype data, which are groups of path IDs which are members of that archetype (e.g Sorcerer)
export type PowerArchetypeData = {
  id: string;
  pathIds: PowerPathId[];
  title: string;
};
export type MarkingData = {
  marking_choices: string[];
  markings_list: Marking[];
};
/// Location data for augment powers (where they exist on the body)
export type PowerAugmentStatic = {
  is_arm?: boolean;
  location?: string | null;
};

/// The state of an augment, which is used to check dynamically if a bodypart is already taken by another power.
export type PowerAugmentState = {
  assignment?: string | null;
  left_blocked?: boolean;
  right_blocked?: boolean;
};

/// Static power data that is sent from DM that is relevant.
export type PowerStatic = {
  description: string;
  cost: number;
  magic_flags?: string[];
  name: string;
  root_badge_icon: string | (string | null)[] | null;
  archetype_name: string | null;
  required_powers?: string[];
  required_allow_any?: boolean;
  required_allow_subtypes?: boolean;
  required_achievement_name?: string | null;
  required_achievement_desc?: string | null;
  action_icon?: string | null;
  action_icon_state?: string | null;
  customizable?: boolean;
  customization_options?: string[];
  augment?: PowerAugmentStatic | null;
};
export type Limb = {
  slot: string;
  name: string;
  can_augment: boolean;
  chosen_aug: string;
  chosen_style: string;
  aug_choices: Record<string, string>;
  costs: Record<string, number>;
  markings: MarkingData;
};
export type Power = PowerStatic &
  PowerState & {
    augment?: (PowerAugmentStatic & PowerAugmentState) | null;
  };

export type PowerByPathId = Record<PowerPathId, Power[]>;
export type PowerStaticByPathId = Record<PowerPathId, PowerStatic[]>;
export type PowerStateByPathId = Record<PowerPathId, PowerState[]>;
export type PowerPathDataById = Record<PowerPathId, PowerPathData>;

/* DOPPLER EDIT END */
export type Organ = {
  slot: string;
  name: string;
  chosen_organ: string;
  organ_choices: Record<string, string>;
  costs: Record<string, number>;
};

// SKYRAT EDIT END
export type QuirkInfo = {
  max_positive_quirks: number;
  quirk_info: Record<string, Quirk>;
  quirk_blacklist: string[][];
  points_enabled: boolean;
};

export type Personality = {
  name: string;
  description: string;
  pos_gameplay_description: string | null;
  neg_gameplay_description: string | null;
  neut_gameplay_description: string | null;
  path: typePath;
  groups: string[] | null;
};

export enum RandomSetting {
  AntagOnly = 1,
  Disabled = 2,
  Enabled = 3,
}

export enum JoblessRole {
  BeOverflow = 1,
  BeRandomJob = 2,
  ReturnToLobby = 3,
}

export enum GamePreferencesSelectedPage {
  Settings,
  Keybindings,
}

export const createSetPreference =
  (act: typeof sendAct, preference: string) => (value: unknown) => {
    act('set_preference', {
      preference,
      value,
    });
  };

export enum PrefsWindow {
  Character = 0,
  Game = 1,
  Keybindings = 2,
}

export type CharacterPreferencesData = {
  preview_options: string[]; // SKYRAT EDIT ADDITION
  preview_selection: string; // SKYRAT EDIT ADDITION

  clothing: Record<string, string>;
  features: Record<string, string>;
  game_preferences: Record<string, unknown>;
  non_contextual: {
    random_body: RandomSetting;
    [otherKey: string]: unknown;
  };
  doppler_lore: Record<string, unknown> 
  secondary_features: Record<string, unknown>;
  character_basics: Record<string, unknown>; // BUBBER EDIT ADDITION: more character setup tabs
  ooc_preferences: Record<string, unknown>; // BUBBER EDIT ADDITION: more character setup tabs
  silicon_preferences: Record<string, unknown>; // BUBBER EDIT ADDITION: more character setup tabs
  supplemental_features: Record<string, unknown>;
  markings: Record<string, unknown> 
  manually_rendered_features: Record<string, string>;

  names: Record<string, string>;

  misc: {
    gender: Gender;
    joblessrole: JoblessRole;
    species: string;
    loadout_lists: LoadoutList; // BUBBER EDIT: Multiple loadout presets: ORIGINAL: loadout_list: LoadoutList;
    job_clothes: BooleanLike;
    loadout_index: string; // BUBBER EDIT ADDITION: Multiple loadout presets
    background_state: string; // BUBBER EDIT ADDITION: Swappable character editor backgrounds
  };

  randomization: Record<string, RandomSetting>;
};

export type PreferencesMenuData = {
  character_preview_view: string;
  character_profiles: (string | null)[];

  character_preferences: CharacterPreferencesData;

  content_unlocked: BooleanLike;

  job_bans?: string[];
  job_days_left?: Record<string, number>;
  job_required_experience?: Record<
    string,
    {
      experience_type: string;
      required_playtime: number;
    }
  >;
  job_preferences: JobPreference[];

  // DOPPLER EDIT
  job_alt_titles: Record<string, string>;

  robotic_styles: string[];
  limbs_data: Limb[];
  organs_data: Organ[];
  marking_presets: string[];

  selected_languages: Language[];
  unselected_languages: Language[];
  total_language_points: number;
  quirks_balance: number;
  positive_quirk_count: number;
  species_restricted_jobs?: string[];
  ckey: string;
  // SKYRAT EDIT END
  // SPLURT EDIT START
  donator_tier: number;
  // SPLURT EDIT END

  power_points: number;
  power_state_paths: PowerStateByPathId;

  augment_location?: string | null;

  // DOPPLER EDIT END
  keybindings: Record<string, string[]>;
  overflow_role: string;
  default_quirk_balance: number;
  selected_quirks: string[];
  selected_personalities: typePath[] | null;
  max_personalities: number;
  mood_enabled: BooleanLike;
  species_disallowed_quirks: string[];

  antag_bans?: string[];
  antag_days_left?: Record<string, number>;
  selected_antags: string[];

  active_slot: number;
  name_to_use: string;

  window: PrefsWindow;
};

export type ServerData = {
  jobs: {
    departments: Record<string, Department>;
    jobs: Record<string, Job>;
  };
  names: {
    types: Record<string, Name>;
  };
  quirks: QuirkInfo;
  personality: {
    personalities: Personality[];
    personality_incompatibilities: Record<string, string[]>;
  };
  random: {
    randomizable: string[];
  };
  loadout: {
    loadout_tabs: LoadoutCategory[];
  };
  /* DOPPLER EDIT ADDITION START - Powers constant data */
  powers: {
    fallback_power_path_id: PowerPathId;
    power_path_data: PowerPathDataById;
    power_path_archetypes: PowerArchetypeData[];
    power_paths: PowerStaticByPathId;
    total_power_points: number;
  };
  /* DOPPLER EDIT ADDITION END */
  species: Record<string, Species>;
  background_state: { choices: string[] }; // BUBBER EDIT ADDITION
  [otheyKey: string]: unknown;
};
