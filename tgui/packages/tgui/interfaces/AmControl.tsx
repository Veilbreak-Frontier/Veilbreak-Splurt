import { useBackend } from '../backend';
import { Button, LabeledList, NumberInput, ProgressBar, Section } from '../components';
import { Window } from '../layouts';

type Data = {
  active: boolean;
  stability: number;
  linked_shielding: number;
  linked_cores: number;
  reported_core_efficiency: number;
  stored_core_stability: number;
  stored_power: string;
  fueljar: {
    fuel: number;
    fuel_max: number;
  } | null;
  fuel_injection: number;
};

export const AmControl = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    active,
    stability,
    linked_shielding,
    linked_cores,
    reported_core_efficiency,
    stored_core_stability,
    stored_power,
    fueljar,
    fuel_injection,
  } = data;

  return (
    <Window width={450} height={420}>
      <Window.Content>
        <Section
          title="Status"
          extra={
            <Button
              icon={active ? 'power-off' : 'play'}
              content={active ? 'Injecting' : 'Standby'}
              color={active ? 'good' : 'danger'}
              onClick={() => act('togglestatus')}
            />
          }
        >
          <LabeledList>
            <LabeledList.Item label="Stability">
              <ProgressBar
                value={stability}
                minValue={0}
                maxValue={100}
                ranges={{
                  good: [70, 100],
                  average: [30, 70],
                  bad: [0, 30],
                }}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Reactor Parts">
              {linked_shielding}
            </LabeledList.Item>
            <LabeledList.Item label="Cores">{linked_cores}</LabeledList.Item>
            <LabeledList.Item label="Current Efficiency">
              {reported_core_efficiency}
            </LabeledList.Item>
            <LabeledList.Item
              label="Average Core Stability"
              buttons={
                <Button
                  icon="sync"
                  content="Update"
                  onClick={() => act('refreshstability')}
                />
              }
            >
              <ProgressBar
                value={stored_core_stability}
                minValue={0}
                maxValue={100}
                ranges={{
                  good: [70, 100],
                  average: [30, 70],
                  bad: [0, 30],
                }}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Last Produced">
              {stored_power}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Fuel">
          {fueljar ? (
            <LabeledList>
              <LabeledList.Item
                label="Fuel Jar"
                buttons={
                  <Button
                    icon="eject"
                    content="Eject"
                    onClick={() => act('ejectjar')}
                  />
                }
              >
                <ProgressBar
                  value={fueljar.fuel}
                  minValue={0}
                  maxValue={fueljar.fuel_max}
                  ranges={{
                    good: [70, 100],
                    average: [30, 70],
                    bad: [0, 30],
                  }}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Injection Rate">
                <NumberInput
                  value={fuel_injection}
                  minValue={0}
                  maxValue={100}
                  step={1}
                  stepPixelDensity={5}
                  onChange={(value) =>
                    act('strength', {
                      value,
                    })
                  }
                />
              </LabeledList.Item>
            </LabeledList>
          ) : (
            'No fuel receptacle detected.'
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
