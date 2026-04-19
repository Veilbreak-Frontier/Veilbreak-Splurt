import {
  Button,
  Collapsible,
  Divider,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import type { NTOSData } from '../layouts/NtosWindow';

type AccessOption = {
  key: string;
  label: string;
  selected: boolean;
};

type Target = {
  ref: string;
  name: string;
  job: string;
};

type IncomingInvite = {
  id: string;
  sponsorName: string;
  sponsorJob: string;
  accessSummary: string;
  expiresIn: number;
};

type ActiveGuest = {
  id: string;
  guestName: string;
  guestStatus: string;
};

type GuestAccessData = {
  hasId: boolean;
  sponsorEligible: boolean;
  sponsorBlockReason: string;
  accessOptions: AccessOption[];
  targets: Target[];
  selectedTargetRef: string | null;
  incomingInvites: IncomingInvite[];
  activeGuests: ActiveGuest[];
} & NTOSData;

export const NtosGuestAccessPass = () => {
  const { data, act } = useBackend<GuestAccessData>();

  const {
    hasId,
    sponsorEligible,
    sponsorBlockReason,
    accessOptions,
    targets,
    selectedTargetRef,
    incomingInvites,
    activeGuests,
  } = data;

  return (
    <NtosWindow width={470} height={640}>
      <NtosWindow.Content scrollable>
        <Stack vertical>
          <Stack.Item>
            <Section title="Incoming invitations">
              {!incomingInvites?.length && (
                <NoticeBox info>No pending invitations.</NoticeBox>
              )}
              {incomingInvites?.map((inv) => (
                <Stack vertical key={inv.id} mb={1}>
                  <Stack.Item>
                    <strong>{inv.sponsorName}</strong> ({inv.sponsorJob})
                  </Stack.Item>
                  <Stack.Item fontSize="12px" color="label">
                    Access: {inv.accessSummary}
                  </Stack.Item>
                  <Stack.Item fontSize="11px" color="label">
                    Expires in ~{inv.expiresIn}s
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      color="good"
                      icon="check"
                      onClick={() => act('PRG_acceptInvite', { id: inv.id })}
                    >
                      Accept
                    </Button>
                    <Button
                      color="bad"
                      icon="times"
                      onClick={() => act('PRG_denyInvite', { id: inv.id })}
                    >
                      Deny
                    </Button>
                  </Stack.Item>
                  <Divider />
                </Stack>
              ))}
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section title="My guests">
              {!sponsorEligible && (
                <NoticeBox warning>
                  Sponsorship unavailable: {sponsorBlockReason}
                </NoticeBox>
              )}
              {sponsorEligible && !activeGuests?.length && (
                <NoticeBox info>You are not sponsoring anyone.</NoticeBox>
              )}
              {activeGuests?.map((g) => (
                <Stack key={g.id} justify="space-between" align="center" mb={1}>
                  <Stack.Item>
                    <strong>{g.guestName}</strong>{' '}
                    <span style={{ fontSize: '11px', opacity: 0.75 }}>
                      ({g.guestStatus})
                    </span>
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      color="bad"
                      icon="user-slash"
                      onClick={() => act('PRG_revokeGuest', { id: g.id })}
                    >
                      Terminate
                    </Button>
                  </Stack.Item>
                </Stack>
              ))}
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section title="Invite a guest">
              {!hasId && (
                <NoticeBox warning>
                  Insert your ID into this PDA to sponsor access.
                </NoticeBox>
              )}
              {hasId && !sponsorEligible && (
                <NoticeBox warning>{sponsorBlockReason}</NoticeBox>
              )}
              {sponsorEligible && (
                <Stack vertical>
                  <Stack.Item>
                    <NoticeBox info>
                      Choose a crewmember whose PDA has this app, then tick
                      which accesses you are willing to mirror. They must
                      accept on their device.
                    </NoticeBox>
                  </Stack.Item>
                  <Stack.Item>
                    <span style={{ fontWeight: 'bold' }}>Recipient</span>
                    <Divider />
                    {targets?.map((t) => (
                      <Button
                        key={t.ref}
                        fluid
                        selected={selectedTargetRef === t.ref}
                        onClick={() =>
                          act('PRG_selectTarget', { ref: t.ref })
                        }
                      >
                        {t.name} — {t.job}
                      </Button>
                    ))}
                    {!targets?.length && (
                      <NoticeBox>No other devices online.</NoticeBox>
                    )}
                  </Stack.Item>
                  <Stack.Item>
                    <Stack>
                      <Stack.Item grow>
                        <span style={{ fontWeight: 'bold' }}>
                          Access to share
                        </span>
                      </Stack.Item>
                      <Stack.Item>
                        <Button
                          icon="eraser"
                          onClick={() => act('PRG_clearAccess')}
                        >
                          Clear
                        </Button>
                      </Stack.Item>
                    </Stack>
                    <Collapsible title={`${accessOptions?.filter((o) => o.selected).length ?? 0} selected`}>
                      {accessOptions?.map((opt) => (
                        <Button.Checkbox
                          fluid
                          key={opt.key}
                          checked={opt.selected}
                          onClick={() =>
                            act('PRG_toggleAccess', { key: opt.key })
                          }
                        >
                          {opt.label}
                        </Button.Checkbox>
                      ))}
                    </Collapsible>
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      fluid
                      color="good"
                      icon="paper-plane"
                      disabled={!selectedTargetRef}
                      onClick={() => act('PRG_sendInvite')}
                    >
                      Send invitation
                    </Button>
                  </Stack.Item>
                </Stack>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
