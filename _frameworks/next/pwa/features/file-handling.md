# File Handling API

## Capability
Open Deal Scale directly when users double-click supported files (e.g., `.dealscale-campaign`).

## Implementation
1. Add `file_handlers` to `manifest.json` with accepted MIME types/extensions and `launch_type`.
2. Implement `/file-handler` route to parse `launchParams.files` (Chrome desktop).
3. Use IndexedDB or temporary uploads to import data into the dashboard.
4. Provide fallback instructions for browsers without file handler support.
