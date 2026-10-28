import { ByondUi } from 'tgui-core/components';
import { config } from 'tgui-core/config';

export const CharacterPreview = (props: {
  width?: string;
  height: string;
  id: string;
}) => {
  const { width = '225px' } = props;

  const cleanHeight = props.height === '100%' ? '100%' : props.height;
  const minHeightFallback = props.height === '100%' ? '250px' : 'auto';

  // Parse pure integer dimensions for native window sizing
  const nativeWidthInt = parseInt(width, 10) || 225;
  const nativeHeightInt =
    props.height === '100%' ? 250 : parseInt(props.height, 10) || 250;

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
        width="100%"
        height="100%"
        style={{
          position: 'absolute',
          top: 0,
          left: 0,
          width: '100%',
          height: '100%',
        }}
        params={{
          id: props.id,
          type: 'map',
          parent: config.window,
          width: nativeWidthInt,
          height: nativeHeightInt,
        }}
      />
    </div>
  );
};
