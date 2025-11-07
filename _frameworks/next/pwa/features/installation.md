# Installation

## Capability
Allow users to install the PWA onto their devices from supported browsers.

## Implementation
1. Maintain `manifest.json` with `name`, `short_name`, `start_url`, `scope`, `display: "standalone"`, theme colors, and maskable icons.
2. Ensure the custom service worker (`sw-custom.js`) is registered site-wide.
3. Use `useInstallPrompt` to capture the `beforeinstallprompt` event and store the deferred prompt.
4. Render `InstallPrompt` after meaningful engagement (e.g., campaign launch completion) and call `prompt()`.
5. Listen for `appinstalled` to log telemetry, award badges, or hide the banner.
