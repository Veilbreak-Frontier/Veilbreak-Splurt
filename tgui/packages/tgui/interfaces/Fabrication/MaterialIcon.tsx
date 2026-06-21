import { DmIcon, Icon } from 'tgui-core/components';

export type MaterialIconProps = {
  /**
   * The icon file for this material's sheet type.
   */
  icon?: string;

  /**
   * The base icon state for this material's sheet type.
   */
  icon_state?: string;

  /**
   * If true, the sheet does not use stack-size icon variants.
   */
  novariants?: boolean;

  /**
   * The number of sheets of the material.
   */
  sheets?: number;
};

const getVariantIconState = (
  base: string,
  sheets: number,
  novariants?: boolean,
) => {
  if (novariants) {
    return base;
  }

  if (sheets > 34) {
    return `${base}_3`;
  }

  if (sheets > 17) {
    return `${base}_2`;
  }

  return base;
};

/**
 * A 32x32 material icon. Animates between different stack sizes of the given
 * material.
 */
export const MaterialIcon = (props: MaterialIconProps) => {
  const { icon, icon_state, novariants, sheets = 0 } = props;

  if (!icon_state) {
    return <Icon name="question-circle" />;
  }

  return (
    <DmIcon
      icon={icon || 'icons/obj/stack_objects.dmi'}
      icon_state={getVariantIconState(icon_state, sheets, novariants)}
      width="32px"
      height="32px"
      fallback={<Icon name="question-circle" />}
    />
  );
};
