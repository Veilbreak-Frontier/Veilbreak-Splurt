import { Box, Button, Image, NoticeBox, ProgressBar, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type ItemData = {
  name: string;
  ref: string;
  icon: string;
  is_shard: BooleanLike;
};

type Data = {
  is_infusing: BooleanLike;
  infusion_progress: number;
  can_infuse: BooleanLike;
  items: ItemData[];
};

export const VoidInfuser = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    is_infusing,
    infusion_progress,
    can_infuse,
    items = [],
  } = data;

  return (
    <Window width={400} height={350} title="Void Infuser">
      <Window.Content>
        <Section title="Machine Status" textAlign="center">
          {is_infusing ? (
            <Box>
              <NoticeBox info mb={2}>Infusion in progress...</NoticeBox>
              <ProgressBar
                value={infusion_progress}
                minValue={0}
                maxValue={1}
                color="purple"
              />
            </Box>
          ) : (
            <NoticeBox success>Ready</NoticeBox>
          )}
        </Section>
        <Section title="Contents">
          {items.length === 0 ? (
            <Box color="label" italic textAlign="center">
              The infuser is empty.
            </Box>
          ) : (
            items.map((item) => (
              <Section 
                key={item.ref} 
                level={2} 
                title={item.name}
                buttons={
                  <Button
                    icon="eject"
                    disabled={!!is_infusing}
                    onClick={() => act('eject', { ref: item.ref })}
                  >
                    Eject
                  </Button>
                }
              >
                <Image
                  src={`data:image/jpeg;base64,${item.icon}`}
                  height="32px"
                  width="32px"
                  verticalAlign="middle"
                />
                <Box inline ml={2} color="label">
                  {item.is_shard ? 'Void Shard' : 'Target Item'}
                </Box>
              </Section>
            ))
          )}
        </Section>
        <Section textAlign="center">
          <Button
            icon="magic"
            color="purple"
            disabled={!can_infuse || !!is_infusing}
            onClick={() => act('infuse')}
            fluid
          >
            Infuse
          </Button>
        </Section>
      </Window.Content>
    </Window>
  );
};
