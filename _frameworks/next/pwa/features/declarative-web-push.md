# Declarative Web Push

## Capability
Receive push notifications without a long-lived service worker by registering declarative rules (currently Chrome-origin trial).

## Implementation Plan
1. Track Chrome origin trial timelines; feature is experimental and limited to specific channels.[^what-pwa]
2. When mature, configure `manifest.json` with declarative push configuration (pending spec) and fall back to classic service worker for other browsers.
3. Update `/api/push/send` to detect declarative recipients and skip Web Push payload when the browser handles delivery.
4. Maintain capability detection and analytics to decide when to use declarative vs. classic push.

[^what-pwa]: What PWA Can Do Today — [https://whatpwacando.today/](https://whatpwacando.today/)
