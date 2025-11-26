# Audio Session API

## Capability
Control how Deal Scale audio mixes with other apps (e.g., duck background music during voice coaching).

## Implementation
1. Detect `navigator.audioSession` (Chromium experimental).
2. Choose category (e.g., `"playback"`, `"speech"`) when starting audio.
3. Handle interruptions and route changes where supported.
4. Provide fallback behaviour for browsers without API (default mix).
