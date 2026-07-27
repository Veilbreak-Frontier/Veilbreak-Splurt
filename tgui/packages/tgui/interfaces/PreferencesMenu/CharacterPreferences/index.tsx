import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import {
  Button,
  Dropdown,
  Flex,
  Stack,
} from 'tgui-core/components';
import { exhaustiveCheck } from 'tgui-core/exhaustive';

import { PageButton } from '../components/PageButton';
import { LanguagesPage } from '../LanguagesMenu';
import { LimbsPage } from '../LimbsPage';
import {
  getPowerCatalogData,
  getPowerPathData,
  useSelectedPowerPath,
} from '../PowerPathBridge';
import { PowerPathPage } from '../PowerPathPage';
import { PowersPage } from '../PowersMenu';
import { SelectedPowersPage } from '../SelectedPowersPage';
import type { PreferencesMenuData } from '../types';
import { AntagsPage } from './AntagsPage';
import { JobsPage } from './JobsPage';
import { LoadoutPage } from './loadout';
import { MainPage } from './MainPage';
import { QuirkPersonalityPage } from './QuirksPage';
import { SpeciesPage } from './SpeciesPage';

enum Page {
  Antags,
  Main,
  Jobs,
  Species,
  Quirks,
  Loadout,
  Languages,
  Powers,
  PowerPath,
  SelectedPowers,
  Limbs,
}

type ProfileProps = {
  activeSlot: number;
  onClick: (index: number) => void;
  profiles: (string | null)[];
};

function CharacterProfiles(props: ProfileProps) {
  const { activeSlot, onClick, profiles } = props;

  return (
    <Flex align="center">
      <Flex.Item>
        <Dropdown
          width="auto"
          selected={activeSlot as unknown as string}
          displayText={profiles[activeSlot]}
          options={profiles.map((profile, slot) => ({
            value: slot,
            displayText: profile ?? 'New Character',
          }))}
          onSelected={(slot) => {
            onClick(slot);
          }}
        />
      </Flex.Item>
      <Flex.Item ml={1}>
        <Button
          onClick={() => {
            act('duplicate_current_slot');
          }}
          fontSize="13px"
          icon="copy"
          tooltip="Duplicate Current Character (Experimental)"
          tooltipPosition="top"
        />
      </Flex.Item>
    </Flex>
  );
}

export function CharacterPreferenceWindow(props) {
  const { act, data } = useBackend<PreferencesMenuData>();

  const [currentPage, setCurrentPage] = useState(Page.Main);

  const { selectedPowerPathId, setSelectedPowerPathId } =
    useSelectedPowerPath();
  const powerCatalogData = getPowerCatalogData();
  const powerPathConfig = getPowerPathData(
    powerCatalogData,
    selectedPowerPathId,
  );

  const activePowersThemeColor =
    currentPage === Page.PowerPath ? powerPathConfig.themeColor : undefined;

  let pageContents;

  switch (currentPage) {
    case Page.Antags:
      pageContents = <AntagsPage />;
      break;
    case Page.Jobs:
      pageContents = <JobsPage />;
      break;
    case Page.Languages:
      pageContents = <LanguagesPage />;
      break;
    case Page.Limbs:
      pageContents = <LimbsPage />;
      break;
    case Page.PowerPath:
      pageContents = (
        <PowerPathPage
          handleClosePath={() => setCurrentPage(Page.Powers)}
          pathId={selectedPowerPathId}
        />
      );
      break;
    case Page.SelectedPowers:
      pageContents = (
        <SelectedPowersPage
          handleClosePage={() => setCurrentPage(Page.Powers)}
        />
      );
      break;
    case Page.Powers:
      pageContents = (
        <PowersPage
          handleOpenSelectedPowers={() => setCurrentPage(Page.SelectedPowers)}
          handleOpenPath={(pathId) => {
            setSelectedPowerPathId(pathId);
            setCurrentPage(Page.PowerPath);
          }}
        />
      );
      break;
    case Page.Main:
      pageContents = (
        <MainPage openSpecies={() => setCurrentPage(Page.Species)} />
      );
      break;
    case Page.Species:
      pageContents = (
        <SpeciesPage closeSpecies={() => setCurrentPage(Page.Main)} />
      );
      break;
    case Page.Quirks:
      pageContents = <QuirkPersonalityPage />;
      break;
    case Page.Loadout:
      pageContents = <LoadoutPage />;
      break;
    default:
      exhaustiveCheck(currentPage);
  }

  return (
    <Stack vertical fill>
      {/* Profile selector + Duplicate button – on their own line */}
      <Stack.Item>
        <CharacterProfiles
          activeSlot={data.active_slot - 1}
          onClick={(slot) => {
            act('change_slot', {
              slot: slot + 1,
            });
          }}
          profiles={data.character_profiles}
        />
      </Stack.Item>

      <Stack.Divider />
      <Stack.Item>
        <Stack fill>
          <Stack.Item grow>
            <PageButton
              currentPage={currentPage}
              page={Page.Main}
              setPage={setCurrentPage}
              otherActivePages={[Page.Species]}
            >
              Character
            </PageButton>
          </Stack.Item>

          <Stack.Item grow>
            <PageButton
              currentPage={currentPage}
              page={Page.Loadout}
              setPage={setCurrentPage}
            >
              Loadout
            </PageButton>
          </Stack.Item>

          <Stack.Item grow>
            <PageButton
              currentPage={currentPage}
              page={Page.Jobs}
              setPage={setCurrentPage}
            >
              Occupations
            </PageButton>
          </Stack.Item>

          <Stack.Item grow>
            <PageButton
              currentPage={currentPage}
              page={Page.Languages}
              setPage={setCurrentPage}
            >
              Languages
            </PageButton>
          </Stack.Item>

          <Stack.Item grow>
            <PageButton
              currentPage={currentPage}
              page={Page.Limbs}
              setPage={setCurrentPage}
            >
              Markings/Organs
            </PageButton>
          </Stack.Item>

          <Stack.Item grow>
            <PageButton
              currentPage={currentPage}
              page={Page.Powers}
              setPage={setCurrentPage}
              activeStyle={
                activePowersThemeColor
                  ? {
                      backgroundColor: activePowersThemeColor,
                      borderColor: activePowersThemeColor,
                      color: 'black',
                    }
                  : undefined
              }
              otherActivePages={[Page.PowerPath, Page.SelectedPowers]}
            >
              Powers
            </PageButton>
          </Stack.Item>

          <Stack.Item grow>
            <PageButton
              currentPage={currentPage}
              page={Page.Antags}
              setPage={setCurrentPage}
            >
              Antagonists
            </PageButton>
          </Stack.Item>

          <Stack.Item grow>
            <PageButton
              currentPage={currentPage}
              page={Page.Quirks}
              setPage={setCurrentPage}
            >
              Quirks and Personality
            </PageButton>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Divider />
      <Stack.Item grow position="relative" overflowX="hidden" overflowY="auto">
        {pageContents}
      </Stack.Item>
    </Stack>
  );
}
