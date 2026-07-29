/*
Power data now arrives in two halves:
- server prefs contain the constant catalog for each power
- ui data contains the current character-specific state

This helper recombines those halves into the full shape the powers pages want to render.
Augmented is the only slightly special case, because its augment metadata is split between constant slot info and runtime arm assignment state.
*/

import type {
  Power,
  PowerByPathId,
  PowerPathId,
  PowerStateByPathId,
  PowerStaticByPathId,
} from './types';

export function mergePowerPathData(
  powerStaticPaths: PowerStaticByPathId = {} as PowerStaticByPathId,
  powerStatePaths: PowerStateByPathId = {} as PowerStateByPathId,
): PowerByPathId {
  const mergedPowerPaths = {} as PowerByPathId;
  const staticPaths = powerStaticPaths || {};
  const statePaths = powerStatePaths || {};

  for (const pathId of Object.keys(staticPaths) as PowerPathId[]) {
    const staticPowers = staticPaths[pathId] || [];
    const statePowers = statePaths?.[pathId] || [];
    const stateByName = new Map(
      statePowers.map((powerState) => [powerState.name, powerState]),
    );

    mergedPowerPaths[pathId] = staticPowers.map((powerStatic): Power => {
      const powerState = stateByName.get(powerStatic.name);
      return {
        ...powerStatic,
        ...powerState,
        has_power: powerState?.has_power || false,
        state: powerState?.state || 'transparent',
        augment:
          powerStatic.augment || powerState?.augment
            ? {
                ...(powerStatic.augment || {}),
                ...(powerState?.augment || {}),
              }
            : null,
      };
    });
  }

  return mergedPowerPaths;
}
