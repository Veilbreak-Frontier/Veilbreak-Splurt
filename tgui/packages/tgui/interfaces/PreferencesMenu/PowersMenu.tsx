import { Box, Button, Image, Section, Stack } from 'tgui-core/components';

import { resolveAsset } from '../../assets';
import { useBackend } from '../../backend';
import type { PowerEntry, PreferencesMenuData } from './types';

export const Powers = (props: { power: PowerEntry }) => {
  const { act } = useBackend<PreferencesMenuData>();
  const power = props.power;
  return (
    <Stack.Item
      style={{
        opacity: power.color,
      }}
    >
      <Section title={power.name}>
        {power.description}
        <br />
        <br />
        <b>{'Cost: ' + power.cost}</b>
        <br />
      </Section>

      <Button
        icon={power.powertype || 'star'}
        color={power.state}
        tooltip={power.rootpower ?? undefined}
        tooltipPosition="right"
        onClick={() => {
          if (power.state === 'bad') {
            act('remove_power', { power_name: power.name });
          } else {
            act('give_power', { power_name: power.name });
          }
        }}
      >
        {power.word} <Box />
      </Button>
    </Stack.Item>
  );
};

type PowerPageProps = {
  handleOpenMortal: () => void;
  handleOpenSorcerous: () => void;
  handleOpenResonant: () => void;
};

function Gap(props: { amount: number }) {
  return <Box height={`calc(${props.amount}px + 0.2em)`} />;
}

export const PowersPage = (props: PowerPageProps) => {
  return (
    <Stack vertical>
      <Gap amount={80} />
      <Stack align="center" fill justify="center">
        <Stack.Item align="center" maxWidth="33%">
          <Stack align="center" vertical>
            <Image
              onClick={props.handleOpenSorcerous}
              src={resolveAsset('seal.png')}
              align="center"
              width={20}
            />
          </Stack>
          <Section align="center" title="The Sorcerous">
            In myths and fables, in times even before technology, particularly
            studious individuals learned how to unseam realities fabric with the
            song of the Resonance. Now, though the practices have changed and
            the myths faded, those dedicated, Sorcerous individuals still bend
            and break Natures will.
          </Section>
        </Stack.Item>
        <Stack.Item align="center" maxWidth="33%">
          <Stack align="center" vertical>
            <Image
              onClick={props.handleOpenResonant}
              src={resolveAsset('heart.png')}
              align="center"
              width={20}
            />
          </Stack>
          <Section align="center" title="The Resonant">
            Intense focus, and a spoon slowly bends. Deep meditation as the
            practicioner exhales fog with every breath, even though the room is
            warm. A baby born on the eclipse. Despite their differences, all
            these individuals are Resonant, and inherently flaunt Natures
            assertions.
          </Section>
        </Stack.Item>
        <Stack.Item align="center" maxWidth="33%">
          <Stack align="center" vertical>
            <Image
              onClick={props.handleOpenMortal}
              src={resolveAsset('gear.png')}
              align="center"
              width={20}
            />
          </Stack>
          <Section align="center" title="The Mortal">
            A man working the night-shift at a dull outpost. Another running
            through gunfire to save his comrade; later, that woman offering a
            folded flag to the man who saved her mother. A scientist pushing the
            edge of his field; a janitor mopping the floors of that same
            facility.
          </Section>
        </Stack.Item>
      </Stack>
    </Stack>
  );
};
