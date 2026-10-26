import { useEffect, useState } from 'react';
import { ByondUi } from 'tgui-core/components';

export const CharacterPreview = (props: {
  width?: string;
  height: string;
  id: string;
}) => {
  const { width = '225px' } = props;

  // Use state tracking to force a micro-delay re-render on initial mount.
  // This gives the parent window time to layout its grid bounds properly.
  const [isReady, setIsReady] = useState(false);

  useEffect(() => {
    const timer = setTimeout(() => {
      setIsReady(true);
    }, 50); // A tiny 50ms buffer ensures the HTML container structure settles first.

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
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        overflow: 'hidden',
      }}
    >
      <ByondUi
        width="100%"
        height="100%"
        style={{
          maxWidth: '100%',
          maxHeight: '100%',
          aspectRatio: '1 / 1',
        }}
        params={{
          id: props.id,
          type: 'map',
        }}
      />
    </div>
  );
};
