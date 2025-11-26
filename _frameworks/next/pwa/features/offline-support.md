# Offline Support

## Capability
Ensure core dashboards and campaigns remain usable when the network is unavailable.

## Implementation
1. Configure Workbox runtime caching in `public/sw-config.js`:
   - `NetworkFirst` for API calls
   - `CacheFirst` for media/fonts
   - `StaleWhileRevalidate` for analytics dashboards
2. Precache shell assets via `precacheAndRoute(self.__WB_MANIFEST)` in `sw-custom.js`.
3. Handle `fetch` fallbacks with `setCatchHandler` returning cached offline pages.
4. Persist campaign drafts via `useCampaignDraftStore` (Zustand + IndexedDB) and background sync queues (`campaign-sync-queue`).
5. Surface offline state using `OfflineBanner` + `useOnlineStatus` to disable destructive actions.

Consult “What PWA Can Do Today” for best-in-class offline demos and compatibility notes.[^what-pwa]

[^what-pwa]: What PWA Can Do Today — [https://whatpwacando.today/](https://whatpwacando.today/)
