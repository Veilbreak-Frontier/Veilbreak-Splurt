import { storage } from 'common/storage';
import { useCallback, useEffect, useState } from 'react';
import {
  Button,
  DmIcon,
  Input,
  NoticeBox,
  Section,
  Stack,
  VirtualList,
} from 'tgui-core/components';
import { useFuzzySearch } from 'tgui-core/fuzzysearch';

import { useBackend } from '../../backend';
import { listNames, listTypes } from '../SpawnPanel/constants';
import type { CreateObjectData } from '../SpawnPanel/types';
import { InstanceFinderSettings } from './InstanceFinderSettings';

type InstanceFinderData = {
  selected_path?: string;
};

interface InstanceFinderSearchProps {
  objList: CreateObjectData;
}

export function InstanceFinderSearch(props: InstanceFinderSearchProps) {
  const { act, data } = useBackend<InstanceFinderData>();
  const { objList = { atoms: {} } } = props;

  const [selectedObj, setSelectedObj] = useState<string | null>(
    data?.selected_path || null,
  );
  const [searchBy, setSearchBy] = useState(false);
  const [sortBy, setSortBy] = useState(listTypes.Objects);
  const [hideMapping, setHideMapping] = useState(false);
  const [showIcons, setShowIcons] = useState(false);
  const [showPreview, setShowPreview] = useState(false);

  const allObjects = objList.atoms;

  const getSearchString = useCallback(
    (key: string) => {
      const item = allObjects[key];
      if (!item) return key;
      return searchBy ? key : `${key} ${item.name || ''}`;
    },
    [searchBy, allObjects],
  );

  const { query, setQuery, results } = useFuzzySearch({
    searchArray: Object.keys(allObjects),
    matchStrategy: 'smart',
    getSearchString,
  });

  const filteredResults = results.filter((obj) => {
    const item = allObjects[obj];
    if (!item) return false;
    if (sortBy !== listTypes[item.type]) return false;
    if (hideMapping && item.mapping) return false;
    return true;
  });

  useEffect(() => {
    if (data?.selected_path) {
      setSelectedObj(data.selected_path);
    }
  }, [data?.selected_path]);

  useEffect(() => {
    const loadStoredValues = async () => {
      const storedSearchText = await storage.get('instancefinder-searchText');
      const storedSearchBy = await storage.get('instancefinder-searchBy');
      const storedSortBy = await storage.get('instancefinder-sortBy');
      const storedHideMapping = await storage.get(
        'instancefinder-hideMapping',
      );
      const storedShowIcons = await storage.get('instancefinder-showIcons');
      const storedShowPreview = await storage.get(
        'instancefinder-showPreview',
      );
      const storedSelectedObj = await storage.get(
        'instancefinder-selectedObj',
      );

      if (storedSearchText) setQuery(storedSearchText);
      if (storedSearchBy !== undefined) setSearchBy(storedSearchBy);
      if (storedSortBy) setSortBy(storedSortBy);
      if (storedHideMapping !== undefined) setHideMapping(storedHideMapping);
      if (storedShowIcons !== undefined) setShowIcons(storedShowIcons);
      if (storedShowPreview !== undefined) setShowPreview(storedShowPreview);
      if (storedSelectedObj && allObjects[storedSelectedObj]) {
        setSelectedObj(storedSelectedObj);
        act('selected-atom-changed', { newObj: storedSelectedObj });
      }
    };

    loadStoredValues();
  }, []);

  const handleObjectSelect = (obj: string) => {
    setSelectedObj(obj);
    storage.set('instancefinder-selectedObj', obj);
    act('selected-atom-changed', { newObj: obj });
  };

  const handleFindInstances = (objPath: string) => {
    act('find-instances', { path: objPath });
  };

  const updateSearchText = (value: string) => {
    setQuery(value);
    storage.set('instancefinder-searchText', value);
  };

  const updateSearchBy = (value: boolean) => {
    setSearchBy(value);
    storage.set('instancefinder-searchBy', value);
  };

  const updateSortBy = (value: string) => {
    setSortBy(value);
    storage.set('instancefinder-sortBy', value);
  };

  const updateHideMapping = (value: boolean) => {
    setHideMapping(value);
    storage.set('instancefinder-hideMapping', value);
  };

  const updateShowIcons = (value: boolean) => {
    setShowIcons(value);
    storage.set('instancefinder-showIcons', value);
  };

  const updateShowPreview = (value: boolean) => {
    setShowPreview(value);
    storage.set('instancefinder-showPreview', value);
  };

  return (
    <Stack vertical fill>
      <Stack.Item>
        <InstanceFinderSettings
          selectedObj={selectedObj}
          onFind={handleFindInstances}
        />
      </Stack.Item>

      {showPreview && selectedObj && allObjects[selectedObj] && (
        <Stack.Item>
          <Section style={{ height: '5.5em' }}>
            <Stack>
              <Stack.Item>
                <Button
                  width="4.5em"
                  height="4.5em"
                  color="transparent"
                  style={{ alignContent: 'center' }}
                >
                  <DmIcon
                    width="3.5em"
                    icon={allObjects[selectedObj].icon}
                    icon_state={allObjects[selectedObj].icon_state}
                  />
                </Button>
              </Stack.Item>
              <Stack.Item
                grow
                style={{ maxHeight: '4.5em', overflowY: 'auto' }}
              >
                <Stack vertical>
                  <Stack.Item bold>{allObjects[selectedObj].name}</Stack.Item>
                  <Stack.Item
                    italic
                    style={{ color: 'rgba(200, 200, 200, 0.7)' }}
                  >
                    {allObjects[selectedObj].description || 'no description'}
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            </Stack>
          </Section>
        </Stack.Item>
      )}

      <Stack.Item>
        <Section>
          <Stack vertical>
            <Stack>
              <Stack.Item>
                <Button
                  icon={sortBy}
                  onClick={() => {
                    const types = Object.values(listTypes);
                    const currentIndex = types.indexOf(sortBy);
                    const nextIndex = (currentIndex + 1) % types.length;
                    updateSortBy(types[nextIndex]);
                  }}
                  tooltip="Cycle searching target (objects, mobs, turfs)"
                >
                  {
                    listNames[
                      Object.keys(listTypes).find(
                        (key) => listTypes[key] === sortBy,
                      ) || 'Objects'
                    ]
                  }
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon={searchBy ? 'code' : 'font'}
                  onClick={() => updateSearchBy(!searchBy)}
                  tooltip="Cycle search method (by name, by type)"
                >
                  {searchBy ? 'By type' : 'By name'}
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button.Checkbox
                  onClick={() => updateHideMapping(!hideMapping)}
                  color={!hideMapping ? 'good' : undefined}
                  checked={!hideMapping}
                  tooltip="Toggle mapping objects visibility"
                >
                  Mapping
                </Button.Checkbox>
              </Stack.Item>
              <Stack.Item>
                <Button.Checkbox
                  onClick={() => updateShowIcons(!showIcons)}
                  color={showIcons ? 'good' : undefined}
                  checked={showIcons}
                  tooltip="Toggle preview icons on hover"
                >
                  Icons
                </Button.Checkbox>
              </Stack.Item>
              <Stack.Item>
                <Button.Checkbox
                  onClick={() => updateShowPreview(!showPreview)}
                  color={showPreview ? 'good' : undefined}
                  checked={showPreview}
                  tooltip="Toggle object preview panel"
                >
                  Preview
                </Button.Checkbox>
              </Stack.Item>
              <Stack.Item>
                <Button
                  height="1.7em"
                  color="transparent"
                  icon="close"
                  onClick={() => updateSearchText('')}
                />
              </Stack.Item>
            </Stack>
            <Stack.Item grow>
              <Input
                placeholder="Search object types..."
                value={query}
                onChange={(value) => updateSearchText(value)}
                fluid
              />
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>

      <Stack.Item grow>
        <Section fill scrollable={filteredResults.length !== 0}>
          {query === '' ? (
            <NoticeBox textAlign="center" color="blue" width="100%">
              Begin typing to search object types...
            </NoticeBox>
          ) : !filteredResults.length ? (
            <NoticeBox textAlign="center" color="blue" width="100%">
              Nothing found
            </NoticeBox>
          ) : (
            <VirtualList>
              {filteredResults.map((obj, index) => (
                <Button
                  key={index}
                  color="transparent"
                  tooltip={
                    showIcons && allObjects[obj] ? (
                      <DmIcon
                        icon={allObjects[obj].icon}
                        icon_state={allObjects[obj].icon_state}
                      />
                    ) : undefined
                  }
                  tooltipPosition="top-start"
                  fluid
                  selected={selectedObj === obj}
                  style={{
                    backgroundColor:
                      selectedObj === obj
                        ? 'rgba(160, 200, 255, 0.1)'
                        : undefined,
                    color: selectedObj === obj ? '#fff' : undefined,
                  }}
                  onDoubleClick={() => {
                    handleObjectSelect(obj);
                    handleFindInstances(obj);
                  }}
                  onClick={() => handleObjectSelect(obj)}
                >
                  {searchBy ? (
                    obj
                  ) : (
                    <>
                      {allObjects[obj]?.name}
                      <span
                        className="label label-info"
                        style={{
                          marginLeft: '0.5em',
                          color: 'rgba(200, 200, 200, 0.5)',
                          fontSize: '10px',
                        }}
                      >
                        {obj}
                      </span>
                    </>
                  )}
                </Button>
              ))}
            </VirtualList>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
}
