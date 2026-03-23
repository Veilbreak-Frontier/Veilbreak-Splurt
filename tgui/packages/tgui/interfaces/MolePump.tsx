import {
  Box,
  Button,
  LabeledList,
  NumberInput,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';

export const MolePump = (props, context) => {
  const { act, data } = useBackend(context);
  const { on, moles_transferred, moles_to_transfer, max_moles_to_transfer } =
    data;

  const [editingMoles, setEditingMoles] = useLocalState(
    context,
    'editingMoles',
    false,
  );
  const [molesInput, setMolesInput] = useLocalState(
    context,
    'molesInput',
    moles_to_transfer,
  );

  const progress = moles_transferred / moles_to_transfer;

  return (
    <Window width={300} height={185}>
      <Window.Content>
        <Section
          title="Operation"
          buttons={
            <Button
              icon="power-off"
              content={on ? 'Active' : 'Inactive'}
              color={on ? 'success' : 'danger'}
              onClick={() => act('toggle_power')}
            />
          }
        >
          <LabeledList>
            <LabeledList.Item label="Progress">
              <ProgressBar
                value={progress}
                content={`${moles_transferred} / ${moles_to_transfer} Moles`}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Target Amount">
              <Box display="flex" alignItems="center">
                {editingMoles ? (
                  <NumberInput
                    value={molesInput}
                    unit="mol"
                    width="70px"
                    minValue={1}
                    maxValue={max_moles_to_transfer}
                    onChange={(e, value) => setMolesInput(value)}
                  />
                ) : (
                  <Box color="label" font-weight="bold">
                    {moles_to_transfer} mol
                  </Box>
                )}
                <Button
                  ml={1}
                  icon={editingMoles ? 'check' : 'pencil-alt'}
                  content={editingMoles ? 'Save' : 'Edit'}
                  onClick={() => {
                    if (editingMoles) {
                      act('set_moles', { moles: molesInput });
                    } else {
                      setMolesInput(moles_to_transfer);
                    }
                    setEditingMoles(!editingMoles);
                  }}
                />
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
