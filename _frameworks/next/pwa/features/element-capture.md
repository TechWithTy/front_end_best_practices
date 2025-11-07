# Element Capture

## Capability
Record or share a specific DOM element (e.g., analytics chart) instead of the entire screen.

## Implementation
1. Confirm support for `HTMLVideoElement.requestVideoFrameCallback` + Element Capture API.
2. Mark target elements with capture metadata and expose toggle in UI.
3. When capture is active, pipe element stream to recording or sharing workflows.
4. Fall back to full-screen capture if API unavailable.
