import { Icon, Image } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import type { Material, MaterialIconEntry } from './Types';

const MATERIAL_ICONS: Record<string, [number, string][]> = {
  iron: [
    [0, 'sheet-metal'],
    [17, 'sheet-metal_2'],
    [34, 'sheet-metal_3'],
  ],
  glass: [
    [0, 'sheet-glass'],
    [17, 'sheet-glass_2'],
    [34, 'sheet-glass_3'],
  ],
  silver: [
    [0, 'sheet-silver'],
    [17, 'sheet-silver_2'],
    [34, 'sheet-silver_3'],
  ],
  gold: [
    [0, 'sheet-gold'],
    [17, 'sheet-gold_2'],
    [34, 'sheet-gold_3'],
  ],
  diamond: [
    [0, 'sheet-diamond'],
    [17, 'sheet-diamond_2'],
    [34, 'sheet-diamond_3'],
  ],
  plasma: [
    [0, 'sheet-plasma'],
    [17, 'sheet-plasma_2'],
    [34, 'sheet-plasma_3'],
  ],
  uranium: [
    [0, 'sheet-uranium'],
    [17, 'sheet-uranium_2'],
    [34, 'sheet-uranium_3'],
  ],
  bananium: [
    [0, 'sheet-bananium'],
    [17, 'sheet-bananium_2'],
    [34, 'sheet-bananium_3'],
  ],
  titanium: [
    [0, 'sheet-titanium'],
    [17, 'sheet-titanium_2'],
    [34, 'sheet-titanium_3'],
  ],
  'bluespace crystal': [[0, 'bluespace_crystal']],
  plastic: [
    [0, 'sheet-plastic'],
    [17, 'sheet-plastic_2'],
    [34, 'sheet-plastic_3'],
  ],
};

export type MaterialIconProps = {
  /**
   * The name of the material.
   */
  materialName: string;

  /**
   * The number of sheets of the material.
   */
  sheets?: number;

  /**
   * Base64-encoded sheet icon from the server, when available.
   */
  icon?: string;
};

export const resolveMaterialIcon = (
  material: Pick<Material, 'ref' | 'name' | 'icon'>,
  materialIcons?: MaterialIconEntry[],
): string | undefined => {
  if (material.icon) {
    return material.icon;
  }

  return materialIcons?.find((entry) => entry.id === material.ref)?.icon;
};

export const materialIconsByName = (
  materialIcons?: MaterialIconEntry[],
  materials?: Material[],
): Record<string, string> => {
  const map: Record<string, string> = {};

  for (const entry of materialIcons ?? []) {
    map[entry.name] = entry.icon;
  }

  for (const material of materials ?? []) {
    const icon = resolveMaterialIcon(material, materialIcons);
    if (icon) {
      map[material.name] = icon;
    }
  }

  return map;
};

const formatBase64Icon = (icon: string) =>
  icon.startsWith('data:') ? icon : `data:image/jpeg;base64,${icon}`;

/**
 * A 32x32 material icon. Animates between different stack sizes of the given
 * material.
 */
export const MaterialIcon = (props: MaterialIconProps) => {
  const { materialName, sheets = 0, icon } = props;

  if (icon) {
    return (
      <Image
        width="32px"
        height="32px"
        src={formatBase64Icon(icon)}
      />
    );
  }

  const icons = MATERIAL_ICONS[materialName];

  if (!icons) {
    return <Icon name="question-circle" />;
  }

  let activeIdx = 0;

  while (icons[activeIdx + 1] && icons[activeIdx + 1][0] <= sheets) {
    activeIdx += 1;
  }

  return (
    <div className={'FabricatorMaterialIcon'}>
      {icons.map(([_, iconState], idx) => (
        <div
          key={idx}
          className={classes([
            'FabricatorMaterialIcon__Icon',
            idx === activeIdx && 'FabricatorMaterialIcon__Icon--active',
            'sheetmaterials32x32',
            iconState,
          ])}
        />
      ))}
    </div>
  );
};
