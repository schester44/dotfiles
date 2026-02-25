# Pi Chime

An audio notification extension for [pi](https://github.com/badlogic/pi-mono) that plays a chime sound when the agent is done and waiting for input.

## Installation

```bash
pi install /path/to/pi-chime
# Or add to ~/.pi/agent/extensions/ directly
```

## Features

- Plays a pleasant chime sound when Pi finishes processing
- Cross-platform support (macOS, Linux, Windows)
- Customizable sound file
- Can be temporarily disabled

## Configuration

Set these environment variables to customize behavior:

| Variable | Description |
|----------|-------------|
| `PI_CHIME_SOUND` | Path to a custom sound file to play |
| `PI_CHIME_DISABLED` | Set to `"1"` to disable the chime |

### Examples

```bash
# Use a custom sound
export PI_CHIME_SOUND="/path/to/my-sound.wav"

# Disable chime temporarily
export PI_CHIME_DISABLED=1
```

## Platform Support

### macOS
Uses `afplay` to play sounds. Default sound is `/System/Library/Sounds/Funk.aiff`.

Other nice macOS system sounds you can use:
- `/System/Library/Sounds/Ping.aiff`
- `/System/Library/Sounds/Pop.aiff`
- `/System/Library/Sounds/Purr.aiff`
- `/System/Library/Sounds/Tink.aiff`

### Linux
Tries `paplay` (PulseAudio) first, then falls back to `aplay` (ALSA). Looks for common system sounds in:
- `/usr/share/sounds/freedesktop/stereo/complete.oga`
- `/usr/share/sounds/freedesktop/stereo/bell.oga`

Falls back to terminal bell (`\x07`) if no audio system is available.

### Windows
Uses PowerShell to play sounds via `System.Media.SoundPlayer` for custom sounds, or `SystemSounds.Asterisk` for the default notification sound.

## License

MIT
