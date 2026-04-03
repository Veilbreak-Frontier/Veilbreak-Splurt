import { Box, Button, Image, NoticeBox, ProgressBar, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { useBackend, useLocalState } from '../backend';
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
  recipes: string[];
};

export const VoidInfuser = (props) => {
  const { act, data } = useBackend<Data>();
  const [showRecipes, setShowRecipes] = useLocalState('show_recipes', false);
  const {
    is_infusing,
    infusion_progress,
    can_infuse,
    items = [],
    recipes = [],
  } = data;

  return (
    <Window width={400} height={400} title="Void Infuser">
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
        <Section 
          title={showRecipes ? "Recipes" : "Contents"}
          buttons={
            <Button
              icon="book"
              tooltip="View Recipes"
              color={showRecipes ? "blue" : "transparent"}
              onClick={() => setShowRecipes(!showRecipes)}
            >
              Recipes
            </Button>
          }
        >
          {showRecipes ? (
            <Box>
              <Box mb={2} color="label">Valid target items for infusion:</Box>
              {recipes.length > 0 ? recipes.map((recipe) => (
                <Box key={recipe} ml={2} mb={1}>
                  • {recipe}
                </Box>
              )) : (
                <Box italic color="label">No recipes found.</Box>
              )}
            </Box>
          ) : (
            <Box>
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
            </Box>
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

