import { useEffect, useState } from 'react';
import { ByondUi } from 'tgui-core/components';

export const CharacterPreview = (props: {
  width?: string;
  height: string;
  id: string;
}) => {
  const { width = '225px' } = props;
  const [isReady, setIsReady] = useState(false);

  useEffect(() => {
    const timer = setTimeout(() => {
      setIsReady(true);
    }, 50);

    return () => clearTimeout(timer);
  }, []);

  if (!isReady) {
    return <div style={{ width: width, height: props.height }} />;
  }

  return (
    <div
      style={{
        width: width,
        height: props.height,
        position: 'relative',
        display: 'block',
        overflow: 'hidden',
      }}
    >
      <ByondUi
        width={width}
        height={props.height}
        style={{
          position: 'absolute',
          top: 0,
          left: 0,
          width: width,
          height: props.height,
        }}
        params={{
          id: props.id,
          type: 'map',
        }}
      />
    </div>
  );
};
