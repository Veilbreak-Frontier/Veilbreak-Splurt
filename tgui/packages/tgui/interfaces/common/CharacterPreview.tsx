import { useEffect, useState } from 'react';
import { ByondUi } from 'tgui-core/components';

export const CharacterPreview = (props: {
  width?: string;
  height: string;
  id: string;
}) => {
  const { width = '225px' } = props;
  const [isReady, setIsReady] = useState(false);
  const [remountKey, setRemountKey] = useState(0);

  useEffect(() => {
    // Phase 1: Wait for CSS Grid/Flexbox containers to stabilize
    const timer = setTimeout(() => {
      setIsReady(true);
    }, 150);

    return () => clearTimeout(timer);
  }, []);

  useEffect(() => {
    if (!isReady) return;

    // Phase 2: Force a secondary layout tick to break BYOND's sizing cache
    const nativeTick = setTimeout(() => {
      setRemountKey((prev) => prev + 1);
    }, 100);

    return () => clearTimeout(nativeTick);
  }, [isReady]);

  if (!isReady) {
    return (
      <div
        style={{
          width: width,
          height: props.height,
          minHeight: props.height === '100%' ? '250px' : props.height,
        }}
      />
    );
  }

  const cleanHeight = props.height === '100%' ? '100%' : props.height;
  const minHeightFallback = props.height === '100%' ? '250px' : 'auto';

  return (
    <div
      style={{
        width: width,
        height: cleanHeight,
        minHeight: minHeightFallback,
        position: 'relative',
        display: 'block',
        overflow: 'hidden',
      }}
    >
      <ByondUi
        key={`${props.id}-${remountKey}`} // Changing this key completely obliterates and recreates the BYOND skin control
        width={width}
        height={cleanHeight}
        style={{
          position: 'absolute',
          top: 0,
          left: 0,
          width: '100%',
          height: '100%',
          minHeight: minHeightFallback,
        }}
        params={{
          id: props.id,
          type: 'map',
        }}
      />
    </div>
  );
};
