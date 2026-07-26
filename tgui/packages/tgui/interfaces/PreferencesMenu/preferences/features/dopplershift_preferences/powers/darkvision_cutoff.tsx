import type { FeatureNumeric } from '../../base';
import { FeatureSliderInput } from '../../base';

export const darkvision_cutoff_red: FeatureNumeric = {
  name: 'Darkvision Red Cutoff',
  description: 'Red vision tint cutoff for darkvision.',
  component: FeatureSliderInput,
};

export const darkvision_cutoff_green: FeatureNumeric = {
  name: 'Darkvision Green Cutoff',
  description: 'Green vision tint cutoff for darkvision.',
  component: FeatureSliderInput,
};

export const darkvision_cutoff_blue: FeatureNumeric = {
  name: 'Darkvision Blue Cutoff',
  description: 'Blue vision tint cutoff for darkvision.',
  component: FeatureSliderInput,
};
