# Background Fetch API

## Capability
Download large exports (CSV, video training modules) in the background, even if the PWA closes.

## Implementation
1. Monitor browser support (Chromium experiment). When available, call `registration.backgroundFetch.fetch()`.
2. Provide UI to monitor progress and handle completion/abort events.
3. For browsers lacking support, continue using server-side export + standard download links.
4. Respect storage quotas and inform users when background fetch fails.
