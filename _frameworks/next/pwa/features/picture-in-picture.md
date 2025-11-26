# Picture-in-Picture

## Capability
Keep dashboards (e.g., live calls, training videos) visible as floating windows using Document Picture-in-Picture.

## Implementation
1. Detect support for `documentPictureInPicture.requestWindow`.
2. Create a lightweight component that renders key metrics or call controls inside the PiP window.
3. Sync state via `BroadcastChannel` or `postMessage` between main window and PiP document.
4. Provide controls to close PiP and return focus to the main app.
5. Evaluate UX for multi-window interactions; guard behind feature flag initially.
