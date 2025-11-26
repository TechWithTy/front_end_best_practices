# Offline Support – Test Plan

## Scenario
User loads analytics, goes offline, and continues interacting; background sync queues mutations.

## Setup
- Render components that rely on `useOnlineStatus`, `useCampaignDraftStore`, and cached queries.
- Mock:
  - `navigator.onLine` toggles via `vi.spyOn` and `dispatchEvent(new Event('offline'))`.
  - Workbox background sync plugin calls (mock queue `.pushRequest`).
  - IndexedDB via in-memory shim or jest IndexedDB.

## Assertions
- `OfflineBanner` appears when offline event fired.
- Mutations trigger queue enqueue rather than failing.
- Coming back online flushes queue and hides banner.

## Follow-ups
- Playwright scenario toggling network via Chrome DevTools protocol.
