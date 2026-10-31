import { useEffect } from 'react';
import { ByondUi } from 'tgui-core/components';
import { globalEvents } from 'tgui-core/events';

export const CharacterPreview = (props: {
  width?: string; // SKYRAT EDIT
  height: string;
  id: string;
}) => {
  // SKYRAT EDIT
  const { width = '225px' } = props;
  // SKYRAT EDIT END

  useEffect(() => {
    const handleGeometryFinished = () => {
      window.dispatchEvent(new Event('resize'));
    };

    globalEvents.on('window-geometry-finished', handleGeometryFinished);
    return () => {
      globalEvents.off('window-geometry-finished', handleGeometryFinished);
    };
  }, []);

  return (
    <ByondUi
      width={width} // SKYRAT EDIT
      height={props.height}
      params={{
        id: props.id,
        type: 'map',
      }}
    />
  );
};
