import { type ComponentProps, useEffect, useState } from 'react';
import { useBackend } from 'tgui/backend';
import { Button, Dropdown, Stack } from 'tgui-core/components';
import { capitalizeFirst } from 'tgui-core/string';

import {
  type FeatureChoiced,
  type FeatureChoicedServerData,
  type FeatureNumeric,
  FeatureSliderInput,
  type FeatureValueProps,
} from '../../base';
import { generateOptions } from '../../dropdowns';

type DropdownOptions = ComponentProps<typeof Dropdown>['options'];

function populateSortedBlooperOptions(
  serverData: FeatureChoicedServerData,
  setDropdownOptions: (newValue: DropdownOptions) => void,
) {
  const options = generateOptions(serverData);
  options.sort((a, b) =>
    String(a.displayText).localeCompare(String(b.displayText), undefined, {
      sensitivity: 'base',
    }),
  );
  setDropdownOptions(options);
}

const FeatureBlooperDropdownInput = (
  props: FeatureValueProps<string, string, FeatureChoicedServerData>,
) => {
  const { act } = useBackend();
  const { serverData, handleSetValue, value } = props;
  const [dropdownOptions, setDropdownOptions] = useState<DropdownOptions>([]);

  useEffect(() => {
    if (serverData) {
      populateSortedBlooperOptions(serverData, setDropdownOptions);
    }
  }, [serverData]);

  const displayText = serverData?.display_names?.[value] || String(value);

  return (
    <Stack>
      <Stack.Item grow>
        <Dropdown
          disabled={!serverData}
          onSelected={handleSetValue}
          displayText={displayText ? capitalizeFirst(displayText) : ''}
          options={dropdownOptions}
          selected={value}
          width="100%"
          menuWidth="max-content"
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          onClick={() => {
            act('play_blooper');
          }}
          icon="play"
          width="100%"
          height="100%"
          disabled={!serverData?.choices?.length}
        />
      </Stack.Item>
    </Stack>
  );
};

export const blooper_choice: FeatureChoiced = {
  name: 'Character Voice',
  component: FeatureBlooperDropdownInput,
};

export const blooper_speed: FeatureNumeric = {
  name: 'Character Voice Speed %',
  description: 'Lower number, slower voice. Higher number, faster voice.',
  component: FeatureSliderInput,
};

export const blooper_pitch: FeatureNumeric = {
  name: 'Character Voice Pitch %',
  description: 'Lower number, deeper pitch. Higher number, higher pitch.',
  component: FeatureSliderInput,
};

export const blooper_pitch_range: FeatureNumeric = {
  name: 'Character Voice Range %',
  description:
    'Lower number, less pitch range. Higher number, more pitch range.',
  component: FeatureSliderInput,
};
