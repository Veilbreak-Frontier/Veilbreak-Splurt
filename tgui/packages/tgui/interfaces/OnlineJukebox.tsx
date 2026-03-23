/**
 * Standalone Online Jukebox Interface
 * Allows users to submit URLs and play tracks from a server-managed library.
 */

import { useEffect, useMemo, useState } from 'react';
import {
  Box,
  Button,
  Flex,
  Input,
  NumberInput,
  Section,
  Table,
  Tooltip,
} from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

interface LibraryTrack {
  name: string;
  duration: string;
  url_hash: string;
  play_count: number;
  last_played: string;
}

interface LibraryStats {
  total_tracks: number;
  max_tracks: number;
  most_played: { name: string; plays: number }[];
}

interface JukeboxData {
  // Status & Controls (ONLINE SYSTEM ONLY)
  volume: number;
  sound_loops: boolean;
  active_song_sound: boolean;
  api_healthy: boolean;

  // Online Track Status
  online_track_name: string | null;
  online_track_duration: number;
  playing_online: boolean;
  track_progress: number;
  online_error_message: string;

  // Library
  library_tracks: LibraryTrack[];
  library_stats: LibraryStats;

  // Force update timestamp
  update_timestamp?: number;
}

const formatTimeDs = (deciseconds: number): string => {
  if (!deciseconds || deciseconds <= 0) return '0:00';
  const totalSeconds = Math.floor(deciseconds / 10);
  const minutes = Math.floor(totalSeconds / 60);
  const seconds = totalSeconds % 60;
  return `${minutes}:${seconds < 10 ? '0' : ''}${seconds}`;
};

export const OnlineJukebox = (props) => {
  const { act, data } = useBackend<JukeboxData>();
  // Use useState for more reactive control
  const [urlInput, setUrlInput] = useState('');

  // Use data from backend, with safe defaults
  const {
    volume = 50,
    sound_loops = false,
    playing_online = false,
    online_track_name = null,
    online_track_duration = 0,
    track_progress = 0,
    online_error_message = '',
    library_tracks = [],
    library_stats = { total_tracks: 0, max_tracks: 50, most_played: [] },
    api_healthy = false,
    update_timestamp = 0,
  } = data || {};

  // Debug logging to see what data we're getting
  useEffect(() => {
    console.log('Jukebox Data:', {
      playing_online,
      online_track_name,
      online_track_duration,
      track_progress,
      volume,
      update_timestamp,
    });
  }, [playing_online, online_track_name, update_timestamp]);

  // Calculate downloading status
  const isDownloading = useMemo(() => {
    if (!online_error_message) return false;
    const msg = online_error_message.toLowerCase();
    return msg.includes('downloading') || msg.includes('download');
  }, [online_error_message]);

  // Calculate progress
  const progressPercent = useMemo(() => {
    if (online_track_duration <= 0) return 0;
    const percent = (track_progress / online_track_duration) * 100;
    return Math.min(100, Math.max(0, percent));
  }, [track_progress, online_track_duration, update_timestamp]);

  // FIX: TGUI Input passes only the value, not (event, value)
  const handleUrlChange = (value: string) => {
    setUrlInput(value || '');
  };

  // Calculate button state
  const hasValidUrl = urlInput && urlInput.trim().length > 0;
  const isButtonDisabled = !hasValidUrl || isDownloading;
  const buttonTooltip = isDownloading
    ? 'Download in progress...'
    : !hasValidUrl
      ? 'Enter a URL to import'
      : 'Download and play track';

  // Handle import button click
  const handleImportClick = () => {
    const trimmedUrl = urlInput.trim();
    if (!trimmedUrl) return;

    act('play_online', { url: trimmedUrl });
    setUrlInput(''); // Clear input after clicking
  };

  return (
    <Window
      width={700}
      height={750}
      theme="ntos"
      title="Online Jukebox Interface"
    >
      <Window.Content>
        <Flex direction="column" height="100%">
          {/* Status and Controls Section */}
          <Flex.Item>
            <Section
              title="Playback Status"
              buttons={
                <Flex>
                  <Button
                    icon={api_healthy ? 'check-circle' : 'times-circle'}
                    color={api_healthy ? 'green' : 'red'}
                    content={api_healthy ? 'API Online' : 'API Offline'}
                    tooltip="The external download and stats API server status."
                  />
                  <Button
                    icon="sync"
                    onClick={() => act('refresh_library')}
                    tooltip="Refresh Library From Server File and Check API Health"
                  >
                    Refresh
                  </Button>
                </Flex>
              }
            >
              <Box
                bold
                textAlign="center"
                fontSize="18px"
                color={playing_online ? 'green' : 'gray'}
                mb={1}
              >
                {/* FIX: Show track name if available, regardless of playing state */}
                {online_track_name
                  ? `Now Playing: ${online_track_name}`
                  : 'Stopped'}
              </Box>

              {/* Error/Status Message */}
              {online_error_message && online_error_message.trim() !== '' && (
                <Box
                  mb={1}
                  color={isDownloading ? 'yellow' : 'red'}
                  textAlign="center"
                >
                  {online_error_message}
                </Box>
              )}

              {/* Progress Bar */}
              {playing_online && (
                <Flex align="center" mb={2}>
                  <Flex.Item grow>
                    <Box
                      height="10px"
                      backgroundColor="black"
                      position="relative"
                    >
                      <Box
                        position="absolute"
                        height="100%"
                        width={`${progressPercent}%`}
                        backgroundColor="#46b546"
                      />
                    </Box>
                  </Flex.Item>
                  <Flex.Item width="80px" textAlign="right">
                    {formatTimeDs(track_progress)} /{' '}
                    {formatTimeDs(online_track_duration)}
                  </Flex.Item>
                </Flex>
              )}

              {/* Buttons and Volume */}
              <Flex fill align="center" justify="space-between" mt={2}>
                <Flex.Item>
                  <Button
                    icon="stop"
                    color="red"
                    disabled={!playing_online && !online_track_name} // Enable stop if we have a track name, even if paused
                    onClick={() => act('stop_music')}
                  >
                    Stop
                  </Button>
                </Flex.Item>

                <Flex.Item>
                  <Button
                    icon={sound_loops ? 'sync' : 'arrow-right'}
                    color={sound_loops ? 'blue' : 'default'}
                    onClick={() => act('set_loop', { looping: !sound_loops })}
                  >
                    {sound_loops ? 'Looping' : 'Play Once'}
                  </Button>
                </Flex.Item>

                <Flex.Item>
                  <Flex align="center">
                    <Flex.Item mr={1}>Volume:</Flex.Item>
                    <Flex.Item>
                      <NumberInput
                        value={volume}
                        minValue={0}
                        maxValue={100}
                        step={10}
                        width="60px"
                        onChange={(value) =>
                          act('set_volume', { volume: value })
                        }
                      />
                    </Flex.Item>
                  </Flex>
                </Flex.Item>
              </Flex>
            </Section>
          </Flex.Item>

          {/* Import Section */}
          <Flex.Item>
            <Section title="Web Import (SoundCloud, Bandcamp)">
              <Flex>
                <Flex.Item grow mr={1}>
                  <Input
                    fluid
                    placeholder="Paste URL here..."
                    value={urlInput}
                    onChange={handleUrlChange}
                    onEnter={() => {
                      if (!isButtonDisabled) {
                        handleImportClick();
                      }
                    }}
                  />
                </Flex.Item>
                <Flex.Item>
                  <Button
                    icon="cloud-download-alt"
                    color={isButtonDisabled ? 'grey' : 'blue'}
                    disabled={isButtonDisabled}
                    onClick={handleImportClick}
                    tooltip={buttonTooltip}
                  >
                    {isDownloading ? 'Downloading...' : 'Import & Play'}
                  </Button>
                </Flex.Item>
              </Flex>

              {/* Real-time status indicator */}
              <Box mt={1} fontSize="12px" textAlign="center">
                <Box as="span" color={hasValidUrl ? 'green' : 'grey'}>
                  ● URL: {hasValidUrl ? 'Entered' : 'None'}
                </Box>
                {' | '}
                <Box as="span" color={isDownloading ? 'yellow' : 'grey'}>
                  ● Download: {isDownloading ? 'In Progress' : 'Ready'}
                </Box>
                {' | '}
                <Box as="span" color={api_healthy ? 'green' : 'orange'}>
                  ● API: {api_healthy ? 'Online' : 'Offline'}
                </Box>
              </Box>

              {/* Quick instructions */}
              <Box mt={0.5} fontSize="11px" color="grey" textAlign="center">
                <i>
                  Supported: SoundCloud, Bandcamp. Enter URL and press Enter or
                  click Import.
                </i>
              </Box>
            </Section>
          </Flex.Item>

          {/* Library Section */}
          <Flex.Item grow basis={0} style={{ overflowY: 'auto' }}>
            <Section
              title={`Music Library (${library_stats.total_tracks || 0} of ${library_stats.max_tracks || 50})`}
              fill
              buttons={
                <Button
                  icon="play"
                  color="green"
                  disabled={!library_tracks?.length || isDownloading}
                  onClick={() => {
                    if (library_tracks?.length > 0) {
                      const randomTrack =
                        library_tracks[
                          Math.floor(Math.random() * library_tracks.length)
                        ];
                      act('play_library', { url_hash: randomTrack.url_hash });
                    }
                  }}
                  tooltip={
                    !library_tracks?.length
                      ? 'Library is empty'
                      : 'Play a random track from the library'
                  }
                >
                  Play Random
                </Button>
              }
            >
              {library_stats.most_played &&
                library_stats.most_played.length > 0 && (
                  <Box mb={2}>
                    <Flex justify="space-around">
                      {library_stats.most_played.map((track, index) => (
                        <Box key={index} textAlign="center" width="30%">
                          <Box bold color="label">
                            #{index + 1} Most Played
                          </Box>
                          <Tooltip content={track.name}>
                            <Box>
                              {track.name.length > 25
                                ? `${track.name.substring(0, 25)}...`
                                : track.name}
                            </Box>
                          </Tooltip>
                          <Box color="gray">({track.plays || 0} plays)</Box>
                        </Box>
                      ))}
                    </Flex>
                  </Box>
                )}

              <Table>
                <Table.Row header>
                  <Table.Cell>Track Name</Table.Cell>
                  <Table.Cell width="70px">Duration</Table.Cell>
                  <Table.Cell width="70px">Plays</Table.Cell>
                  <Table.Cell width="120px">Last Played</Table.Cell>
                  <Table.Cell width="80px">Action</Table.Cell>
                </Table.Row>
                {!library_tracks || library_tracks.length === 0 ? (
                  <Table.Row>
                    <Table.Cell colSpan={5} textAlign="center" color="gray">
                      <i>
                        Library is empty. Import a track using the section
                        above.
                      </i>
                    </Table.Cell>
                  </Table.Row>
                ) : (
                  library_tracks.map((track) => (
                    <Table.Row key={track.url_hash} className="candystripe">
                      <Table.Cell>
                        <Tooltip content={`Hash: ${track.url_hash}`}>
                          <Box>
                            {track.name.length > 40
                              ? `${track.name.substring(0, 40)}...`
                              : track.name}
                          </Box>
                        </Tooltip>
                      </Table.Cell>
                      <Table.Cell>{track.duration || '0:00'}</Table.Cell>
                      <Table.Cell>{track.play_count || 0}</Table.Cell>
                      <Table.Cell>{track.last_played || 'Never'}</Table.Cell>
                      <Table.Cell>
                        <Button
                          icon="play"
                          onClick={() =>
                            act('play_library', { url_hash: track.url_hash })
                          }
                          disabled={isDownloading}
                          color="blue"
                          tooltip={
                            isDownloading
                              ? 'Download in progress...'
                              : 'Play this track'
                          }
                        />
                      </Table.Cell>
                    </Table.Row>
                  ))
                )}
              </Table>
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

export default OnlineJukebox;
