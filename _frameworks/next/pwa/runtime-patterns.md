# Runtime Patterns

## Push and Notifications
- `PushManager` requests permission post-engagement and stores a JSON subscription via `usePushStore`.
- `/api/push/subscribe` persists subscriptions; `/api/push/send` delivers payloads decorated with deep links.
- Service worker displays notifications and focus/opens windows using cached URLs.

## Offline UX
- Workbox `NetworkFirst` for API payloads; `CacheFirst` for media; `StaleWhileRevalidate` for dynamic dashboards.
- Background Sync queues POSTs (`campaign-sync-queue`, `analytics-sync-queue`).
- `OfflineBanner` surfaces `navigator.onLine === false` state.

## Install Prompt
- `useInstallPrompt` waits for 3+ visits or explicit engagement before showing `InstallPrompt`.
- iOS fallback explains share-sheet workflow since `beforeinstallprompt` is unsupported.

## Update Detection
- `useServiceWorkerUpdate` listens for waiting workers and exposes `applyUpdate()` (calls `SKIP_WAITING`).
- `UpdatePrompt` surfaces a toast and reloads once the new worker activates.

## Network-aware Rendering
- `useNetworkQuality` monitors `navigator.connection.effectiveType` and downlinks.
- Slow connections replace charts with placeholders and skip heavy imports.
