import {
  Box,
  Button,
  Divider,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

interface PortalControlData {
  portal_present: boolean;
  portal_status: boolean;
  portal_active: boolean;
  current_target?: {
    name: string;
  };
  generation_status: string;
  generation_progress: number;
  can_generate: boolean;
  generation_in_progress: boolean;
  cleanup_in_progress: boolean;
  portal_name?: string;
  void_boss_kills: number;
  void_creature_health_scale: number;
  void_creature_damage_scale: number;
}

type NoticeKind = 'info' | 'success' | 'danger' | 'warn';

type DerivedState = {
  title: string;
  subtitle: string;
  notice: NoticeKind;
  showProgress: boolean;
  progress: number;
  canOpen: boolean;
  canClose: boolean;
};

function deriveState(d: PortalControlData): DerivedState {
  const {
    cleanup_in_progress,
    portal_present,
    portal_status,
    generation_in_progress,
    portal_active,
    can_generate,
    generation_status,
    portal_name,
    generation_progress,
  } = d;

  if (cleanup_in_progress) {
    return {
      title: 'Closing pocket',
      subtitle:
        'The dungeon is being torn down and the portal link is clearing.',
      notice: 'warn',
      showProgress: false,
      progress: 0,
      canOpen: false,
      canClose: false,
    };
  }
  if (!portal_present) {
    return {
      title: 'No portal in range',
      subtitle:
        'Keep a powered station portal within 3 tiles, then press Rescan Matrix.',
      notice: 'danger',
      showProgress: false,
      progress: 0,
      canOpen: false,
      canClose: false,
    };
  }
  if (!portal_status) {
    return {
      title: 'Portal not usable',
      subtitle: 'Needs power, must be anchored, and must not be broken.',
      notice: 'warn',
      showProgress: false,
      progress: 0,
      canOpen: false,
      canClose: false,
    };
  }
  if (generation_in_progress) {
    return {
      title: 'Opening dungeon',
      subtitle: 'Generating pocket space and loading the map.',
      notice: 'info',
      showProgress: true,
      progress: Math.min(100, Math.max(0, generation_progress)),
      canOpen: false,
      canClose: false,
    };
  }
  if (generation_status === 'generating' && !portal_active) {
    return {
      title: 'Finishing link',
      subtitle: 'Waiting for the portal to finish coming online.',
      notice: 'info',
      showProgress: false,
      progress: 0,
      canOpen: false,
      canClose: false,
    };
  }
  if (portal_active) {
    return {
      title: 'Dungeon open',
      subtitle: portal_name
        ? `Active pocket: ${portal_name}`
        : 'The portal is on and the wormhole is stable.',
      notice: 'success',
      showProgress: false,
      progress: 0,
      canOpen: false,
      canClose: true,
    };
  }
  if (can_generate) {
    return {
      title: 'Idle',
      subtitle: 'Portal is ready. Open a dungeon when your crew is prepared.',
      notice: 'success',
      showProgress: false,
      progress: 0,
      canOpen: true,
      canClose: false,
    };
  }
  return {
    title: 'Standby',
    subtitle:
      'State is unclear. If the portal moved, use Rescan Matrix to relink.',
    notice: 'warn',
    showProgress: false,
    progress: 0,
    canOpen: false,
    canClose: false,
  };
}

function StatusNotice(props: {
  kind: NoticeKind;
  title: string;
  subtitle: string;
}) {
  const { kind, title, subtitle } = props;
  const body = (
    <Box>
      <Box bold>{title}</Box>
      <Box color="label" mt={0.5}>
        {subtitle}
      </Box>
    </Box>
  );
  if (kind === 'info') {
    return <NoticeBox info>{body}</NoticeBox>;
  }
  if (kind === 'success') {
    return <NoticeBox success>{body}</NoticeBox>;
  }
  if (kind === 'danger') {
    return <NoticeBox danger>{body}</NoticeBox>;
  }
  return <NoticeBox color="yellow">{body}</NoticeBox>;
}

const fmtScale = (n: number) =>
  (Math.round(n * 100) / 100).toLocaleString(undefined, {
    minimumFractionDigits: 0,
    maximumFractionDigits: 2,
  });

export const PortalControl = (props) => {
  const { act, data } = useBackend<PortalControlData>();
  const {
    void_boss_kills = 0,
    void_creature_health_scale = 1,
    void_creature_damage_scale = 1,
  } = data;

  const derived = deriveState(data);

  return (
    <Window width={440} height={420} theme="void" title="Portal control">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section
              title="Status"
              buttons={
                <Button
                  icon="sync-alt"
                  color="transparent"
                  onClick={() => act('linkup')}
                >
                  Rescan Matrix
                </Button>
              }
            >
              <StatusNotice
                kind={derived.notice}
                title={derived.title}
                subtitle={derived.subtitle}
              />
              {derived.showProgress && (
                <Box mt={1}>
                  <ProgressBar
                    value={derived.progress / 100}
                    minValue={0}
                    maxValue={1}
                    color="blue"
                  >
                    {derived.progress}%
                  </ProgressBar>
                </Box>
              )}
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section title="Dungeon">
              <Stack vertical>
                <Stack.Item>
                  <Button
                    fluid
                    icon="door-open"
                    color="good"
                    disabled={!derived.canOpen}
                    onClick={() => act('generate_new')}
                  >
                    Open dungeon
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    fluid
                    icon="door-closed"
                    color="bad"
                    disabled={!derived.canClose}
                    onClick={() => act('deactivate')}
                  >
                    Close dungeon
                  </Button>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Divider />
            <Section title="Void retaliation">
              <Box color="label" mb={1} fontSize="0.9rem">
                Void bosses you destroy make void creatures tougher in later
                pockets (health and damage scale up).
              </Box>
              <Box>
                <Box>
                  <Box inline color="label" width="10rem">
                    Bosses defeated
                  </Box>
                  <Box inline bold>
                    {void_boss_kills}
                  </Box>
                </Box>
                <Box mt={0.5}>
                  <Box inline color="label" width="10rem">
                    Creature HP
                  </Box>
                  <Box inline>×{fmtScale(void_creature_health_scale)}</Box>
                </Box>
                <Box mt={0.5}>
                  <Box inline color="label" width="10rem">
                    Creature damage
                  </Box>
                  <Box inline>×{fmtScale(void_creature_damage_scale)}</Box>
                </Box>
              </Box>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
