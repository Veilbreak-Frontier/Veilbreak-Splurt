import { useBackend } from '../backend';
import { Box, Button, ColorBox, Dropdown, Input, LabeledList, ProgressBar, Section, Stack, TextArea } from 'tgui-core/components';
import { Window } from '../layouts';
import type { ComponentProps, CSSProperties } from 'react';

// --- Type Definitions ---

type BodyPart = {
  zone: string;
  name: string;
  covered: number; // 1 if covered, 0 otherwise
  current_tattoos: number;
  max_tattoos: number;
};

type Tattoo = {
  artist: string;
  design: string;
  color: string;
  layer: number;
  font: string;
  flair: string | null;
  date: string;
  index?: number;
  zone: string;
  zone_name?: string;
};

type Option = {
  name: string;
  value: string | number | null;
};

type DropdownOptions = ComponentProps<typeof Dropdown>['options'];

type Data = {
  target_name: string;
  ink_uses: number;
  max_ink_uses: number;
  applying: boolean;
  default_ink_color: string;

  artist_name: string;
  tattoo_design: string;
  selected_zone: string;
  selected_layer: number;
  selected_font: string;
  selected_flair: string | null;
  ink_color: string;

  font_options: Option[];
  flair_options: Option[];
  layer_options: Option[];
  body_parts: BodyPart[];
  existing_tattoos: Tattoo[];
};

// --- Internal Utility Components ---

const error_colors = {
  error: 'red',
  warning: 'average',
  success: 'good',
  info: 'blue',
  label: 'label',
};

const Notice = ({ type, children, mt }: { type: 'error' | 'warning' | 'info', children: React.ReactNode, mt?: number }) => {
  const colors = {
    error: { bg: '#5b1111', border: '#c53030', text: '#fbd5d5' },
    warning: { bg: '#5a4303', border: '#d69e2e', text: '#fef3c7' },
    info: { bg: '#0f3057', border: '#4299e1', text: '#bee3f8' },
  }[type];

  return (
    <Box
      mt={mt || 0}
      p={1}
      style={{
        borderLeft: `4px solid ${colors.border}`,
        backgroundColor: colors.bg,
        color: colors.text,
        borderRadius: '6px',
        fontSize: '0.9rem',
      }}
    >
      {children}
    </Box>
  );
};

const Grid = ({ children }: { children: React.ReactNode }) => (
  <div
    style={{
      display: 'grid',
      gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))',
      gap: '0.75rem',
    }}
  >
    {children}
  </div>
);
Grid.Column = ({ children, onClick }: { children: React.ReactNode, onClick?: () => void }) => (
  <div onClick={onClick}>{children}</div>
);

const TEXT_EMOJI_MAP: Record<string, string> = {
  ':sad:': '☹',
  ':heart:': '♥',
  ':star:': '★',
  ':spade:': '♠',
  ':club:': '♣',
  ':diamond:': '♦',
  ':music:': '♪',
  ':sun:': '☀',
  ':cloud:': '☁',
  ':rain:': '☔',
  ':snow:': '❄',
  ':phone:': '☎',
  ':mail:': '✉',
  ':pencil:': '✏',
  ':scissors:': '✂',
  ':check:': '✓',
  ':x:': '✗',
  ':warning:': '⚠',
  ':radioactive:': '☢',
  ':biohazard:': '☣',
  ':peace:': '☮',
  ':yin_yang:': '☯',
  ':wheelchair:': '♿',
  ':recycle:': '♻',
  ':tm:': '™',
  ':copyright:': '©',
  ':registered:': '®',
  ':anchor:': '⚓',
  ':umbrella:': '☂',
  ':snowman:': '☃',
  ':coffee:': '☕',
  ':fire:': '🔥',
  ':thumbsup:': '👍',
  ':thumbsdown:': '👎',
  ':ok_hand:': '👌',
  ':v:': '✌',
  ':clap:': '👏',
  ':pray:': '🙏',
  ':eyes:': '👀',
  ':eye:': '👁',
  ':ear:': '👂',
  ':nose:': '👃',
  ':lips:': '👄',
  ':tongue:': '👅',
  ':wave:': '👋',
  ':raised_hand:': '✋',
  ':open_hands:': '👐',
  ':point_up:': '☝',
  ':point_down:': '👇',
  ':point_left:': '👈',
  ':point_right:': '👉',
  ':middle_finger:': '🖕',
  ':fist:': '✊',
  ':raised_fist:': '✊',
  ':vulcan:': '🖖',
  ':writing_hand:': '✍',
  ':pencil2:': '✏',
  ':black_heart:': '🖤',
  ':blue_heart:': '💙',
  ':green_heart:': '💚',
  ':yellow_heart:': '💛',
  ':purple_heart:': '💜',
  ':broken_heart:': '💔',
  ':heartbeat:': '💓',
  ':sparkling_heart:': '💖',
  ':star2:': '⭐',
  ':boom:': '💥',
  ':zzz:': '💤',
  ':sweat_drops:': '💦',
  ':droplet:': '💧',
  ':muscle:': '💪',
  ':footprints:': '👣',
  ':brain:': '🧠',
  ':bone:': '🦴',
  ':tooth:': '🦷',
  ':alien:': '👽',
  ':poop:': '💩',
  ':ghost:': '👻',
  ':japanese_goblin:': '👺',
  ':japanese_ogre:': '👹',
  ':angel:': '👼',
  ':skull_crossbones:': '☠',
  ':snake:': '🐍',
  ':spider:': '🕷',
  ':bat:': '🦇',
  ':bear:': '🐻',
  ':bird:': '🐦',
  ':cat:': '🐱',
  ':dog:': '🐶',
  ':fox:': '🦊',
  ':lion:': '🦁',
  ':tiger:': '🐯',
  ':wolf:': '🐺',
  ':horse:': '🐴',
  ':unicorn:': '🦄',
  ':cow:': '🐮',
  ':pig:': '🐷',
  ':frog:': '🐸',
  ':monkey:': '🐵',
  ':chicken:': '🐔',
  ':penguin:': '🐧',
  ':fish:': '🐟',
  ':whale:': '🐳',
  ':dolphin:': '🐬',
  ':octopus:': '🐙',
  ':butterfly:': '🦋',
  ':bee:': '🐝',
  ':ant:': '🐜',
  ':ladybug:': '🐞',
  ':turtle:': '🐢',
  ':snail:': '🐌',
  ':dragon:': '🐉',
  ':dragon_face:': '🐲',
  ':cactus:': '🌵',
  ':tree:': '🌳',
  ':four_leaf_clover:': '🍀',
  ':herb:': '🌿',
  ':maple_leaf:': '🍁',
  ':fallen_leaf:': '🍂',
  ':leaves:': '🍃',
  ':mushroom:': '🍄',
  ':ear_of_rice:': '🌾',
  ':bouquet:': '💐',
  ':tulip:': '🌷',
  ':rose:': '🌹',
  ':sunflower:': '🌻',
  ':blossom:': '🌼',
  ':cherry_blossom:': '🌸',
  ':hibiscus:': '🌺',
  ':earth_americas:': '🌎',
  ':earth_africa:': '🌍',
  ':earth_asia:': '🌏',
  ':full_moon:': '🌕',
  ':sun_with_face:': '🌞',
  ':globe:': '🌐',
  ':volcano:': '🌋',
  ':mount_fuji:': '🗻',
  ':house:': '🏠',
  ':church:': '⛪',
  ':office:': '🏢',
  ':hospital:': '🏥',
  ':bank:': '🏦',
  ':hotel:': '🏨',
  ':love_hotel:': '🏩',
  ':convenience_store:': '🏪',
  ':school:': '🏫',
  ':department_store:': '🏬',
  ':factory:': '🏭',
  ':japanese_castle:': '🏯',
  ':european_castle:': '🏰',
  ':rainbow:': '🌈',
  ':fireworks:': '🎆',
  ':sparkler:': '🎇',
  ':rice_scene:': '🎑',
  ':jack_o_lantern:': '🎃',
  ':christmas_tree:': '🎄',
  ':santa:': '🎅',
  ':sparkles:': '✨',
  ':balloon:': '🎈',
  ':tada:': '🎉',
  ':confetti_ball:': '🎊',
  ':tanabata_tree:': '🎋',
  ':crossed_flags:': '🎌',
  ':bamboo:': '🎍',
  ':dolls:': '🎎',
  ':flags:': '🎏',
  ':wind_chime:': '🎐',
  ':ribbon:': '🎀',
  ':gift:': '🎁',
  ':reminder_ribbon:': '🎗',
  ':tickets:': '🎟',
  ':ticket:': '🎫',
  ':medal:': '🎖',
  ':trophy:': '🏆',
  ':sports_medal:': '🏅',
  ':first_place:': '🥇',
  ':second_place:': '🥈',
  ':third_place:': '🥉',
  ':soccer:': '⚽',
  ':baseball:': '⚾',
  ':basketball:': '🏀',
  ':volleyball:': '🏐',
  ':football:': '🏈',
  ':rugby_football:': '🏉',
  ':tennis:': '🎾',
  ':8ball:': '🎱',
  ':bowling:': '🎳',
  ':cricket:': '🏏',
  ':field_hockey:': '🏑',
  ':ice_hockey:': '🏒',
  ':ping_pong:': '🏓',
  ':badminton:': '🏸',
  ':boxing_glove:': '🥊',
  ':martial_arts_uniform:': '🥋',
  ':goal:': '🥅',
  ':dart:': '🎯',
  ':golf:': '⛳',
  ':ice_skate:': '⛸',
  ':fishing_pole:': '🎣',
  ':running_shirt:': '🎽',
  ':ski:': '🎿',
  ':sled:': '🛷',
  ':curling_stone:': '🥌',
  ':video_game:': '🎮',
  ':joystick:': '🕹',
  ':game_die:': '🎲',
  ':chess_pawn:': '♟',
  ':bow_and_arrow:': '🏹',
  ':water_pistol:': '🔫',
  ':bomb:': '💣',
  ':knife:': '🔪',
  ':dagger:': '🗡',
  ':crossed_swords:': '⚔',
  ':shield:': '🛡',
  ':smoking:': '🚬',
  ':coffin:': '⚰',
  ':funeral_urn:': '⚱',
  ':amphora:': '🏺',
  ':crystal_ball:': '🔮',
  ':prayer_beads:': '📿',
  ':nazar_amulet:': '🧿',
  ':barber:': '💈',
  ':alembic:': '⚗',
  ':telescope:': '🔭',
  ':microscope:': '🔬',
  ':hole:': '🕳',
  ':pill:': '💊',
  ':syringe:': '💉',
  ':dna:': '🧬',
  ':microbe:': '🦠',
  ':test_tube:': '🧪',
  ':petri_dish:': '🧫',
  ':thermometer:': '🌡',
  ':broom:': '🧹',
  ':basket:': '🧺',
  ':roll_of_paper:': '🧻',
  ':soap:': '🧼',
  ':sponge:': '🧽',
  ':fire_extinguisher:': '🧯',
  ':shopping_cart:': '🛒',
  ':smiley:': '😃',
  ':smile:': '😄',
  ':grin:': '😁',
  ':laughing:': '😆',
  ':sweat_smile:': '😅',
  ':rofl:': '🤣',
  ':joy:': '😂',
  ':slightly_smiling:': '🙂',
  ':upside_down:': '🙃',
  ':wink:': '😉',
  ':blush:': '😊',
  ':innocent:': '😇',
  ':heart_eyes:': '😍',
  ':kissing_heart:': '😘',
  ':kissing:': '😗',
  ':relaxed:': '☺',
  ':kissing_closed_eyes:': '😚',
  ':kissing_smiling_eyes:': '😙',
  ':yum:': '😋',
  ':stuck_out_tongue:': '😛',
  ':stuck_out_tongue_winking_eye:': '😜',
  ':stuck_out_tongue_closed_eyes:': '😝',
  ':money_mouth:': '🤑',
  ':hugs:': '🤗',
  ':thinking:': '🤔',
  ':zipper_mouth:': '🤐',
  ':raised_eyebrow:': '🤨',
  ':neutral:': '😐',
  ':expressionless:': '😑',
  ':no_mouth:': '😶',
  ':smirk:': '😏',
  ':unamused:': '😒',
  ':roll_eyes:': '🙄',
  ':grimacing:': '😬',
  ':lying:': '🤥',
  ':relieved:': '😌',
  ':pensive:': '😔',
  ':sleepy:': '😪',
  ':drooling:': '🤤',
  ':sleeping:': '😴',
  ':mask:': '😷',
  ':face_with_thermometer:': '🤒',
  ':face_with_head_bandage:': '🤕',
  ':nauseated:': '🤢',
  ':vomiting:': '🤮',
  ':sneezing:': '🤧',
  ':hot:': '🥵',
  ':cold:': '🥶',
  ':woozy:': '🥴',
  ':dizzy:': '😵',
  ':exploding_head:': '🤯',
  ':cowboy:': '🤠',
  ':partying:': '🥳',
  ':disguised:': '🥸',
  ':sunglasses:': '😎',
  ':nerd:': '🤓',
  ':monocle:': '🧐',
  ':confused:': '😕',
  ':worried:': '😟',
  ':slightly_frowning:': '🙁',
  ':frowning:': '☹',
  ':open_mouth:': '😮',
  ':hushed:': '😯',
  ':astonished:': '😲',
  ':flushed:': '😳',
  ':pleading:': '🥺',
  ':frowning2:': '😦',
  ':anguished:': '😧',
  ':fearful:': '😨',
  ':cold_sweat:': '😰',
  ':disappointed_relieved:': '😥',
  ':cry:': '😢',
  ':sob:': '😭',
  ':scream:': '😱',
  ':confounded:': '😖',
  ':persevere:': '😣',
  ':disappointed:': '😞',
  ':sweat:': '😓',
  ':weary:': '😩',
  ':tired:': '😫',
  ':yawning:': '🥱',
  ':triumph:': '😤',
  ':rage:': '😡',
  ':pout:': '😡',
  ':angry:': '😠',
  ':cursing:': '🤬',
  ':smiling_imp:': '😈',
  ':imp:': '👿',
  ':skull:': '💀',
  ':hankey:': '💩',
  ':clown:': '🤡',
  ':robot:': '🤖',
  ':smiley_cat:': '😺',
  ':smile_cat:': '😸',
  ':joy_cat:': '😹',
  ':heart_eyes_cat:': '😻',
  ':smirk_cat:': '😼',
  ':kissing_cat:': '😽',
  ':scream_cat:': '🙀',
  ':crying_cat_face:': '😿',
  ':pouting_cat:': '😾',
};

const FLAIR_CLASS_MAP: Record<string, string> = {
  // Keys are now the flair identifiers that match server-side flair IDs
  pink: 'pink',
  userlove: 'userlove',
  brown: 'brown',
  cyan: 'cyan',
  orange: 'orange',
  yellow: 'yellow',
  subtle: 'subtle',
  velvet: 'velvet',
  velvet_notice: 'velvet_notice',
  glossy: 'glossy',
};

const FLAIR_CLASS_STYLES: Record<string, CSSProperties> = {
  pink: { color: '#ff8fc7' },
  userlove: { color: '#ff70a6' },
  brown: { color: '#b87333' },
  cyan: { color: '#00bcd4' },
  orange: { color: '#ff9f1c' },
  yellow: { color: '#facc15' },
  subtle: { color: '#bdbdbd' },
  velvet: { color: '#a855f7' },
  velvet_notice: { color: '#805ad5' },
  glossy: { color: '#9cc3f2' },
};

const getFontPreviewStyle = (font: string) => {
  switch (font) {
    case 'PEN_FONT':
      return { fontFamily: '"Courier New", monospace', fontSize: '1rem' };
    case 'FOUNTAIN_PEN_FONT':
      return { fontFamily: '"Times New Roman", serif', fontSize: '1.1rem' };
    case 'CRAYON_FONT':
      return { fontFamily: '"Comic Sans MS", cursive', fontSize: '1.1rem', fontStyle: 'italic' };
    case 'PRINTER_FONT':
      return { fontFamily: '"Roboto Mono", monospace', fontSize: '0.9rem', letterSpacing: '0.12rem' };
    case 'CHARCOAL_FONT':
      return { fontFamily: '"Georgia", serif', fontSize: '1.2rem', fontStyle: 'italic' };
    default:
      return { fontFamily: '"Segoe UI", sans-serif', fontSize: '1rem' };
  }
};


// --- Tattoo Preview Component (Styled for Examine Text) ---

const sanitizeDisplayText = (text: string) => {
  if (!text) {
    return '';
  }
  return text.replace(/</g, '').replace(/>/g, '');
};

const parseTextEmojis = (text: string) => {
  if (!text) {
    return '';
  }
  let processed = text;
  for (const [shortcode, emoji] of Object.entries(TEXT_EMOJI_MAP)) {
    if (processed.includes(shortcode)) {
      processed = processed.split(shortcode).join(emoji);
    }
  }
  return processed;
};

const formatTattooDesign = (design: string, flairId: string | null) => {
  const sanitized = sanitizeDisplayText(design);
  const emojiConverted = parseTextEmojis(sanitized);
  const flairClass = flairId ? FLAIR_CLASS_MAP[flairId] : undefined;
  const flairStyle = flairClass ? FLAIR_CLASS_STYLES[flairClass] : undefined;
  return {
    text: emojiConverted,
    flairStyle,
  };
};

const TattooPreview = ({ artist, design, color, font, flairId, flairLabel, fontName, targetName }: { artist: string, design: string, color: string, font: string, flairId: string | null, flairLabel?: string, fontName: string, targetName: string }) => {
  const finalArtist = artist.replace('%s', targetName);
  const { text: formattedDesign, flairStyle } = formatTattooDesign(design, flairId);
  const tattooText = formattedDesign.trim() ? `${formattedDesign} - ${finalArtist}` : '';
  const previewColor = flairStyle?.color || color;
  const fontStyle = {
    ...getFontPreviewStyle(font),
    ...flairStyle,
    color: previewColor,
    minHeight: '3rem',
    whiteSpace: 'pre-wrap' as const,
    lineHeight: '1.2',
  };

  return (
    <Box
      mt={3}
      p={1.5}
      style={{
        border: '2px dashed #4b5563',
        borderRadius: '8px',
        backgroundColor: '#1f2937',
      }}
    >
      <Box color={error_colors.label} bold mb={1}>
        Preview (Font: {fontName}{flairLabel ? ` • ${flairLabel}` : ''})
      </Box>
      <div style={fontStyle}>
        {tattooText || (
          <span style={{ color: '#9ca3af', fontStyle: 'italic' }}>
            Enter Artist Name and Design to see a preview.
          </span>
        )}
      </div>
      {flairLabel && (
        <Box mt={1} style={{ color: '#cbd5f5', fontSize: '0.8rem' }}>
          Flair tint applied: <span style={{ color: previewColor }}>{flairLabel}</span>
        </Box>
      )}
    </Box>
  );
};

const NO_FLAIR_SENTINEL = '__no_flair__';


// --- Main App Component ---

export const TattooKit = () => {
  const { data, act } = useBackend<Data>();
  const {
    target_name,
    ink_uses,
    max_ink_uses,
    applying,
    artist_name,
    tattoo_design,
    selected_zone,
    selected_layer,
    selected_font,
    selected_flair,
    ink_color,
    font_options,
    flair_options,
    layer_options,
    body_parts,
    existing_tattoos,
  } = data;

  // Enhance existing_tattoos with index for easy removal and filter by selected zone
  const tattoosWithIndex: Tattoo[] = existing_tattoos
    .map((t, index) => ({
      ...t,
      // Prefer backend-provided metadata, but fall back to local computation.
      index: t.index ?? index + 1,
      zone: t.zone || selected_zone || '',
      zone_name: t.zone_name || t.zone,
    }));

  // Find the selected body part
  const selectedBodyPart = body_parts.find((p) => p.zone === selected_zone);
  const selectedPartCovered = selectedBodyPart ? selectedBodyPart.covered > 0 : false;

  // Determine readiness for application
  const isSelectedPartUsable = selectedBodyPart ? !selectedPartCovered && selectedBodyPart.current_tattoos < selectedBodyPart.max_tattoos : false;
  const isReady = artist_name.trim() && tattoo_design.trim() && isSelectedPartUsable && ink_uses > 0;

  // Get the display name of the selected font for the preview
  const selectedFontName = font_options.find((opt) => opt.value === selected_font)?.name || 'Unknown Font';
  const selectedFlairOption = flair_options.find((opt) => opt.value === selected_flair);
  const selectedFlairLabel = selected_flair ? selectedFlairOption?.name : undefined;

  const layerDropdownOptions: DropdownOptions = layer_options.map((opt) => ({
    displayText: opt.name,
    value: String(opt.value),
  }));
  const fontDropdownOptions: DropdownOptions = font_options.map((opt) => ({
    displayText: opt.name,
    value: String(opt.value),
  }));
  const flairDropdownOptions: DropdownOptions = flair_options.map((opt) => ({
    displayText: opt.name,
    value: opt.value ? String(opt.value) : NO_FLAIR_SENTINEL,
  }));
  const selectedFlairValue = selected_flair ? String(selected_flair) : NO_FLAIR_SENTINEL;

  return (
    <Window title={`Tattoo Kit: ${target_name}`} width={800} height={700}>
      <Window.Content scrollable={true}>
        {/* Main Vertical Stack */}
        <Stack vertical fill>

          {/* TOP AREA (Body Part Selection + Design/Apply) */}
          <Stack.Item basis="60%">
            <Stack fill>
              {/* LEFT COLUMN (Body Part Selection) - 50% Width */}
              <Stack.Item grow={1} basis="50%">
                <Section title="Body Part Selection" fill scrollable>
                  {/* Ink Uses Progress Bar */}
                  <Box mb={1}>
                    <ProgressBar
                      value={ink_uses}
                      maxValue={max_ink_uses}
                      ranges={{
                        bad: [0, max_ink_uses * 0.25],
                        average: [max_ink_uses * 0.25, max_ink_uses * 0.65],
                        good: [max_ink_uses * 0.65, max_ink_uses],
                      }}
                    >
                      <Box textAlign="center" fontSize={0.9}>
                        Ink Reservoir {ink_uses}/{max_ink_uses}
                      </Box>
                    </ProgressBar>
                  </Box>
                  {ink_uses === 0 && (
                      <Notice type="error" mt={1}>Out of Ink! Refill the kit to continue.</Notice>
                  )}

                  {/* Body Part List */}
                  <Box mt={2}>
                    {body_parts.map((part) => {
                      const isSelected = part.zone === selected_zone;
                      const isCovered = part.covered > 0;
                      const isFull = part.current_tattoos >= part.max_tattoos;
                      const backgroundColor = isSelected ? '#103f6f' : isCovered ? '#5c1717' : '#050505';
                      const borderColor = isSelected ? '#63b3ed' : isCovered ? '#e53e3e' : '#2d3748';
                      const textColor = isSelected ? '#f8fafc' : isCovered ? '#fed7d7' : '#e5e7eb';
                      const badgeBg = isSelected ? '#bfdbfe' : '#374151';
                      const badgeColor = isSelected ? '#1a202c' : '#f8fafc';

                      return (
                        <Box
                          key={part.zone}
                          mb={1}
                          p={1.2}
                          style={{
                            backgroundColor,
                            border: `1px solid ${borderColor}`,
                            borderRadius: '8px',
                            cursor: 'pointer',
                          }}
                          onClick={() => act('select_zone', { zone: part.zone })}
                        >
                          <Stack align="center">
                            <Stack.Item grow>
                              <Box bold style={{ color: textColor, fontSize: '1rem' }}>
                                {part.name}
                              </Box>
                            </Stack.Item>
                            <Stack.Item>
                              <Box
                                px={1}
                                py={0.2}
                                style={{
                                  backgroundColor: badgeBg,
                                  color: badgeColor,
                                  borderRadius: '999px',
                                  fontSize: '0.75rem',
                                }}
                              >
                                {part.current_tattoos}/{part.max_tattoos} Tattoos
                              </Box>
                            </Stack.Item>
                          </Stack>
                          {isSelected && (
                            <Box mt={0.5} style={{ color: '#cfe0ff', fontSize: '0.75rem', fontWeight: 600 }}>
                              SELECTED
                            </Box>
                          )}
                          {isCovered && (
                            <Box mt={0.5} style={{ color: '#fed7d7', fontSize: '0.8rem' }} bold>
                              Blocked: Clothing/Armor Covered
                            </Box>
                          )}
                          {isFull && !isCovered && (
                            <Box mt={0.5} style={{ color: '#fbd38d', fontSize: '0.8rem' }}>
                              Blocked: Max Tattoos reached
                            </Box>
                          )}
                        </Box>
                      );
                    })}
                  </Box>
                </Section>
              </Stack.Item>

              {/* RIGHT COLUMN (Design / Apply) - 50% Width */}
              <Stack.Item grow={1} basis="50%">
                <Section
                  title={`Tattoo Design: ${selectedBodyPart?.name || 'Select a Body Part'}`}
                  fill>
                  <LabeledList>
                    <LabeledList.Item label="Ink Color">
                      <Stack>
                        <ColorBox
                          color={ink_color}
                          mr={1}
                        />
                        <Button
                          icon="palette"
                          onClick={() => act('pick_color')}>
                          Change Color
                        </Button>
                      </Stack>
                    </LabeledList.Item>

                    {/* Dropdown Fix: Ensure value and options map values to strings for Dropdown stability */}
                    <LabeledList.Item label="Layer">
                      <Dropdown
                        selected={String(selected_layer)}
                        options={layerDropdownOptions}
                        onSelected={(value: string) =>
                          act('set_layer', { value: value }) // DM code expects text2num on value
                        }
                      />
                    </LabeledList.Item>

                    <LabeledList.Item label="Font">
                      <Dropdown
                        selected={selected_font}
                        options={fontDropdownOptions}
                        onSelected={(value: string) =>
                          act('set_font', { value: value })
                        }
                      />
                    </LabeledList.Item>

                    <LabeledList.Item label="Flair">
                      <Dropdown
                        selected={selectedFlairValue}
                        options={flairDropdownOptions}
                        onSelected={(value: string) =>
                          act('set_flair', { value: value === NO_FLAIR_SENTINEL ? null : value })
                        }
                      />
                    </LabeledList.Item>

                    <LabeledList.Item label="Artist Name">
                      {/* Real-time preview update via onInput */}
                      <Input
                        value={artist_name}
                        onChange={(value: string) =>
                          act('set_artist', { value: value })
                        }
                        maxLength={50}
                        placeholder="e.g. The Drifter or Signed by %s (for name)"
                        disabled={!selected_zone || applying}
                      />
                    </LabeledList.Item>

                    <LabeledList.Item label="Tattoo Design">
                      {/* Real-time preview update via onInput */}
                      <TextArea
                        value={tattoo_design}
                        onChange={(value: string) =>
                          act('set_design', { value: value })
                        }
                        maxLength={256}
                        placeholder="A fearsome skull, etc."
                        height="80px"
                        disabled={!selected_zone || applying}
                      />
                    </LabeledList.Item>

                  </LabeledList>

                  {/* BUTTONS STACK */}
                    <Stack mt={3}>
                    <Stack.Item grow>
                      <Button
                        icon="magic"
                        onClick={() => act('apply')}
                        color="blue"
                        disabled={!isReady || applying}
                        fluid
                      >
                        {applying ? 'Applying...' : 'Apply Tattoo'}
                      </Button>
                    </Stack.Item>
                  </Stack>

                  {/* TATTOO PREVIEW - Pass target_name for signature preview */}
                  {selected_zone && (
                      <TattooPreview
                          artist={artist_name}
                          design={tattoo_design}
                          color={ink_color}
                          font={selected_font}
                          flairId={selected_flair}
                          flairLabel={selectedFlairLabel}
                          fontName={selectedFontName}
                          targetName={target_name}
                      />
                  )}

                  {/* NOTICES */}
                  {!selected_zone && (
                    <Notice type="info" mt={1}>Select a body part to begin designing a tattoo.</Notice>
                  )}
                  {selected_zone && !isSelectedPartUsable && (
                    <Notice type="warning" mt={1}>
                        {selectedPartCovered ? "Blocked: Remove clothing/armor before application." : "Blocked: Max Tattoos reached on this part."}
                    </Notice>
                  )}
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>

          {/* BOTTOM AREA (Existing Tattoos) */}
          <Stack.Item grow basis={0}>
            <Section title="Existing Custom Tattoos" fill scrollable>
              {tattoosWithIndex.length === 0 && (
                <Box color={error_colors.label}>The target has no custom tattoos.</Box>
              )}
              {tattoosWithIndex.length > 0 && (
                <Grid>
                  {tattoosWithIndex.map((tattoo) => {
                    return (
                      <Grid.Column key={`${tattoo.zone}-${tattoo.index}`}>
                        <Box
                          p={1}
                          style={{
                            backgroundColor: '#374151',
                            border: `1px solid #4b5563`,
                            borderRadius: '8px',
                          }}
                        >
                          <LabeledList>
                            <LabeledList.Item label="Part">
                              <Box bold>
                                {tattoo.zone_name || body_parts.find(p => p.zone === tattoo.zone)?.name || tattoo.zone || 'Unknown Zone'}
                              </Box>
                            </LabeledList.Item>
                            <LabeledList.Item label="Design">
                              {(() => {
                                const { text, flairStyle } = formatTattooDesign(tattoo.design, tattoo.flair);
                                const designStyle = { color: flairStyle?.color || tattoo.color, ...flairStyle };
                                return (
                                  <Box style={designStyle}>
                                    "{text}"
                                  </Box>
                                );
                              })()}
                            </LabeledList.Item>
                            <LabeledList.Item label="Artist">
                              {tattoo.artist}
                            </LabeledList.Item>
                            <LabeledList.Item label="Applied">
                              {tattoo.date}
                            </LabeledList.Item>
                            <LabeledList.Item label="Layer">
                              <Box
                                color={
                                  tattoo.layer === 1 ? error_colors.label :
                                  tattoo.layer === 2 ? error_colors.warning : error_colors.success
                                }>
                                {tattoo.layer === 1 ? 'Under' :
                                  tattoo.layer === 2 ? 'Normal' : 'Over'}
                              </Box>
                            </LabeledList.Item>
                          </LabeledList>

                        </Box>
                      </Grid.Column>
                    );
                  })}
                </Grid>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

export default TattooKit;
