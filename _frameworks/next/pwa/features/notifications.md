# Notifications

## Capability
Deliver push notifications even when the dashboard is closed to alert users about lead updates, campaign results, or credits.

## Implementation
1. **Client**
   - `PushManager` (client component) waits for meaningful action, requests permission, and registers service worker.
   - `usePushStore` tracks support, permission state, subscription JSON, and registration status.
2. **Service Worker**
   - `sw-custom.js` listens for `push` events, parses payload, shows notifications, and routes clicks to deep links.
3. **Backend**
   - `/api/push/subscribe` / `/unsubscribe` store or remove subscriptions.
   - `/api/push/send` uses `web-push` to deliver payloads with fallback data and handles invalid endpoints.
4. **Testing**
   - `tests/pwa/pwa.spec.ts` validates store behaviour and update flow; smoke test via Chrome/Edge push sandbox.

Use “What PWA Can Do Today” to verify platform support for push and declarative web push features before extending functionality.[^what-pwa]

[^what-pwa]: What PWA Can Do Today — [https://whatpwacando.today/](https://whatpwacando.today/)
