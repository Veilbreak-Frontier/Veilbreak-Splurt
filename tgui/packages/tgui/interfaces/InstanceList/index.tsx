import { useState } from 'react';
import {
  Box,
  Button,
  DmIcon,
  Input,
  NoticeBox,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import { useBackend } from '../../backend';
import { Window } from '../../layouts';

type InstanceItem = {
  ref: string;
  name: string;
  type: string;
  area: string;
  coords: string;
  location_details?: string;
  icon?: string | null;
  icon_state?: string | null;
};

type InstanceListData = {
  target_path: string;
  target_path_name: string;
  total_count: number;
  instances: InstanceItem[];
};

export function InstanceList() {
  const { act, data } = useBackend<InstanceListData>();
  const [filter, setFilter] = useState('');

  const {
    target_path = '',
    target_path_name = '',
    total_count = 0,
    instances = [],
  } = data || {};

  const filteredInstances = instances.filter((inst) => {
    if (!filter.trim()) return true;
    const search = filter.toLowerCase();
    return (
      inst.name.toLowerCase().includes(search) ||
      inst.type.toLowerCase().includes(search) ||
      inst.area.toLowerCase().includes(search) ||
      inst.coords.toLowerCase().includes(search) ||
      (inst.location_details &&
        inst.location_details.toLowerCase().includes(search))
    );
  });

  return (
    <Window
      height={600}
      title={`Instances: ${target_path_name || target_path || 'None'}`}
      width={700}
      theme="admin"
    >
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section
              title="Search Filter & Status"
              buttons={
                <Button
                  icon="sync"
                  onClick={() => act('refresh')}
                  tooltip="Refresh instance list"
                >
                  Refresh
                </Button>
              }
            >
              <Stack align="center">
                <Stack.Item grow>
                  <Input
                    placeholder="Filter instances by name, area, coords..."
                    value={filter}
                    onChange={(value) => setFilter(value)}
                    fluid
                  />
                </Stack.Item>
                <Stack.Item>
                  <Box color="label" bold>
                    Found: {total_count} instance{total_count !== 1 ? 's' : ''}
                  </Box>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item grow>
            <Section fill scrollable>
              {!target_path ? (
                <NoticeBox textAlign="center" color="blue">
                  No object path selected. Use the Instance Finder to select an
                  item path.
                </NoticeBox>
              ) : instances.length === 0 ? (
                <NoticeBox textAlign="center" color="yellow">
                  No active instances of <code>{target_path}</code> found in
                  the world.
                </NoticeBox>
              ) : filteredInstances.length === 0 ? (
                <NoticeBox textAlign="center" color="blue">
                  No instances match filter "{filter}".
                </NoticeBox>
              ) : (
                <Table>
                  <Table.Row header>
                    <Table.Cell width="32px"></Table.Cell>
                    <Table.Cell>Name & Type</Table.Cell>
                    <Table.Cell>Location / Area</Table.Cell>
                    <Table.Cell width="160px" collapsing textAlign="right">
                      Actions
                    </Table.Cell>
                  </Table.Row>
                  {filteredInstances.map((inst) => (
                    <Table.Row key={inst.ref}>
                      <Table.Cell align="center">
                        {inst.icon ? (
                          <DmIcon
                            icon={inst.icon}
                            icon_state={inst.icon_state || ''}
                            height="24px"
                            width="24px"
                          />
                        ) : (
                          <Box color="label">-</Box>
                        )}
                      </Table.Cell>
                      <Table.Cell>
                        <Box bold>{inst.name}</Box>
                        <Box
                          style={{
                            fontSize: '10px',
                            color: 'rgba(200, 200, 200, 0.6)',
                            fontFamily: 'monospace',
                          }}
                        >
                          {inst.type}
                        </Box>
                      </Table.Cell>
                      <Table.Cell>
                        <Box bold>{inst.area}</Box>
                        <Box
                          style={{
                            fontSize: '11px',
                            color: 'rgba(180, 220, 255, 0.8)',
                          }}
                        >
                          {inst.coords}{' '}
                          {inst.location_details && (
                            <span
                              style={{ color: '#aaa', fontStyle: 'italic' }}
                            >
                              ({inst.location_details})
                            </span>
                          )}
                        </Box>
                      </Table.Cell>
                      <Table.Cell textAlign="right">
                        <Stack justify="end">
                          <Stack.Item>
                            <Button
                              icon="location-arrow"
                              color="good"
                              onClick={() => act('teleport', { ref: inst.ref })}
                              tooltip="Teleport to instance location"
                            >
                              Teleport
                            </Button>
                          </Stack.Item>
                          <Stack.Item>
                            <Button
                              icon="wrench"
                              color="warning"
                              onClick={() => act('vv', { ref: inst.ref })}
                              tooltip="View Variables (VV)"
                            >
                              VV
                            </Button>
                          </Stack.Item>
                        </Stack>
                      </Table.Cell>
                    </Table.Row>
                  ))}
                </Table>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
