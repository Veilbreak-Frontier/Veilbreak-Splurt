import { type Feature, FeatureShortTextInput } from '../../base';

export const ignite_incantation: Feature<string> = {
  name: 'Ignite Incantation',
  description: 'Custom incantation spoken when casting Ignite.',
  component: FeatureShortTextInput,
};

