# Background Sync API

## Capability
Defer queued tasks (e.g., campaign launches, analytics submissions) until connectivity is restored.

## Implementation
1. Configure Workbox background sync queues in `sw-config.js` (e.g., `campaign-sync-queue`).
2. In `sw-custom.js`, register routes using `BackgroundSyncPlugin`.
3. At enqueue time, provide unique IDs for deduplication and error handling.
4. Show syncing status in UI when the app regains connectivity.
