import { useEffect, useState } from 'react';
import { Stack } from 'tgui-core/components';
import { fetchRetry } from 'tgui-core/http';

import { resolveAsset } from '../../assets';
import { Window } from '../../layouts';
import { logger } from '../../logging';
import { InstanceFinderSearch } from './InstanceFinderSearch';
import type { CreateObjectData } from '../SpawnPanel/types';

export function InstanceFinder() {
  const [data, setData] = useState<CreateObjectData | undefined>();

  useEffect(() => {
    fetchRetry(resolveAsset('spawnpanel_atom_data.json'))
      .then((response) => response.json())
      .then(setData)
      .catch((error) => {
        logger.log(
          'Failed to fetch spawnpanel_atom_data.json',
          JSON.stringify(error),
        );
      });
  }, []);

  return (
    <Window height={550} title="Instance Finder" width={500} theme="admin">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow>
            {data && <InstanceFinderSearch objList={data} />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
