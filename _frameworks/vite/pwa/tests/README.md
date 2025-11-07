# Vite PWA Test Suite Plan

Last updated: 2025-11-07

## Scope
Validate the Vite `vite-plugin-pwa` integration end to end:
- Service worker registration and update flows (prompt vs autoUpdate).
- Workbox runtime caching and offline fallbacks.
- PWA manifest injection (icons, shortcuts, theme color).
- Generated assets pipeline (`@vite-pwa/assets-generator`).

## Test Layers
- **Unit (Vitest)**
  - Mock `virtual:pwa-register` hook to assert prompt callbacks.
  - Verify helper utilities (e.g., queue handling, manifest builders).
  - Snapshot manifest generation config.
- **Integration (Vitest + jsdom)**
  - Simulate SW registration, waiting worker detection, and `SKIP_WAITING` messaging.
  - Validate Workbox runtime caching config objects.
- **E2E (Playwright)**
  - Launch built app with SW enabled, verify offline navigation to cached routes.
  - Trigger updated build to ensure prompt/auto update behaviour.
  - Confirm installability via manifest icon presence and Lighthouse PWA score.

## Test Matrix
| Feature | Unit | Integration | E2E |
| --- | --- | --- | --- |
| generateSW prompt flow | ✓ | ✓ | ✓ |
| injectManifest custom SW | ✓ | ✓ | ✓ |
| Offline fallback page | ✗ | ✓ | ✓ |
| Background sync queue | ✓ | ✓ | ✗ |
| Manifest shortcuts/icons | ✓ | ✗ | ✓ |
| Assets generator CLI | ✗ | ✓ | ✓ |

## Tooling Setup
- `pnpm add -D vitest @vitest/ui @testing-library/react @testing-library/jest-dom`
- `pnpm add -D playwright @playwright/test`
- Configure `vitest.config.ts` with `environment: 'jsdom'` for component tests.
- Playwright project: `projects: [{ name: 'chromium-pwa', use: { serviceWorkers: 'allow', offline: true } }]`.

## Execution Scripts
```json
{
  "scripts": {
    "test:vite-pwa:unit": "vitest run tests/vite-pwa/unit/**/*.spec.ts",
    "test:vite-pwa:int": "vitest run tests/vite-pwa/integration/**/*.spec.ts",
    "test:vite-pwa:e2e": "playwright test tests/vite-pwa/e2e"
  }
}
```

## Acceptance Criteria
- All scripted commands pass in CI.
- Lighthouse PWA score ≥ 95 with generated assets.
- Playwright offline scenario demonstrates cached shell.
- Update prompt appears within 60s during SW update test.

## Follow-Ups
- Add contract tests for push notification integration once backend VAPID endpoints are mirrored.
- Automate assets generator check in CI (fail if icons missing or stale).
