import { Box, Button, Section, Stack } from 'tgui-core/components';

interface InstanceFinderSettingsProps {
  selectedObj: string | null;
  onFind: (path: string) => void;
}

export function InstanceFinderSettings(props: InstanceFinderSettingsProps) {
  const { selectedObj, onFind } = props;

  return (
    <Section title="Target Object Path">
      <Stack align="center">
        <Stack.Item grow>
          <Box
            bold
            style={{
              fontSize: '13px',
              fontFamily: 'monospace',
              wordBreak: 'break-all',
              color: selectedObj ? '#5eeb5e' : '#aaa',
            }}
          >
            {selectedObj || 'No object path selected'}
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="search"
            color="good"
            disabled={!selectedObj}
            style={{
              padding: '6px 16px',
              fontSize: '13px',
              fontWeight: 'bold',
            }}
            onClick={() => {
              if (selectedObj) {
                onFind(selectedObj);
              }
            }}
            tooltip={
              selectedObj
                ? `Find active instances of ${selectedObj}`
                : 'Select an object path below first'
            }
          >
            Find Instances
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
}
