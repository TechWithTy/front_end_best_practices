# Audio (Media Session)

## Capability
Integrate playback controls with OS media UI for training videos or audio summaries.

## Implementation
1. Feature-detect `navigator.mediaSession`.
2. Set metadata (title, artist, artwork) whenever audio starts.
3. Register action handlers (`play`, `pause`, `seekforward`, etc.) to control in-app player.
4. Sync progress across tabs via BroadcastChannel if needed.
