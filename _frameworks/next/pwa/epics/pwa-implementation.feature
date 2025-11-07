Feature: Deal Scale PWA Implementation Epic
  Background: Shared tooling and dependencies
    Given I install baseline PWA tooling with
      | command                             |
      | pnpm add next-pwa workbox-window    |
      | pnpm add -D @types/service-worker   |
      | pnpm add -D vitest @testing-library/react @testing-library/jest-dom |
      | pnpm add -D @playwright/test        |
    And I ensure environment vars for push (VAPID keys) exist in `.env.local`
    And I confirm Lighthouse CLI is available via `pnpm add -D lighthouse`

  @service-worker
  Scenario: Harden the custom Workbox service worker
    Given I update `public/sw-config.js` around lines 1-200 to include API, analytics, media, and font runtime caching
    And I refine `public/sw-custom.js` ensuring `clientsClaim`, `skipWaiting`, and background sync queues for POSTs
    When I rebuild the Next.js app with `pnpm build`
    Then the generated `public/sw.js` reflects the Workbox runtime strategy map

  @next-config
  Scenario: Wire `next-pwa` into the build pipeline
    Given I open `next.config.js` and wrap the exported config with `withPWA({ dest: "public", register: true, skipWaiting: true, swSrc: "./public/sw-custom.js" })`
    And I set security headers across `/sw-custom.js` and `/manifest.webmanifest`
    When I run `pnpm lint`
    Then no Biome errors surface for the updated configuration module

  @push-notifications
  Scenario: Implement push subscription storage
    Given I update `lib/stores/pushStore.ts` around lines 1-80 to expose `subscription`, `permission`, and `lastUpdatedAt`
    And I complete `lib/services/pushClient.ts` with `persistSubscription`, `removeSubscription`, and `getVapidPublicKey`
    And I implement API handlers in `app/api/push/subscribe/route.ts`, `.../unsubscribe/route.ts`, and `.../send/route.ts`
    When I run `pnpm test:pwa`
    Then the push store and hook specs pass

  @install-prompt
  Scenario: Deliver custom install prompt UX
    Given I enhance `hooks/useInstallPrompt.ts` to gate banners after 3 visits
    And I render `components/pwa/InstallPrompt.tsx` within `components/layout/providers.tsx`
    When I simulate `beforeinstallprompt` via Vitest
    Then the hook exposes `showInstallPrompt` and `canInstall === true`

  @offline
  Scenario: Offline draft resilience
    Given I persist campaign drafts in `lib/stores/campaignDraftStore.ts` using Zustand `persist`
    And I display connectivity state via `components/layout/OfflineBanner.tsx`
    And I preload offline fallback in `sw-config.js`
    When I toggle network offline in Playwright
    Then the lead list shell renders with cached data and banner visible

  @updates
  Scenario: Notify users about new builds
    Given I refine `hooks/useServiceWorkerUpdate.ts` to broadcast `SKIP_WAITING`
    And I expose toast UI through `components/pwa/UpdatePrompt.tsx`
    When a waiting service worker is detected in integration tests
    Then the toast renders offering a refresh CTA

  @assets
  Scenario: Maintain manifest and icon hygiene
    Given I verify `public/manifest.webmanifest` includes icons, shortcuts, and categories matching Deal Scale modules
    And I store generated icons under `public/icons/`
    When Lighthouse audits the build `pnpm exec lighthouse http://localhost:3000 --preset=pwa`
    Then the audit reports manifest and icon checks as passing

  @testing
  Scenario Outline: Execute dedicated PWA test suites
    Given I stage the <suite> tests via package scripts
    When I run <command>
    Then the suite completes with status 0

    Examples:
      | suite       | command                                |
      | unit        | pnpm test:pwa                          |
      | integration | pnpm vitest run tests/pwa/integration  |
      | e2e         | pnpm playwright test tests/pwa/e2e      |
      | lighthouse  | pnpm exec lighthouse http://localhost:3000 --preset=pwa |

  @docs
  Scenario: Document architecture and verification
    Given I extend `_docs/front_end_best_practices/_frameworks/next/pwa/` overview, configuration, runtime-patterns, testing, and capability files to match implemented features
    And I record demo mappings inside `_docs/front_end_best_practices/_frameworks/next/pwa/features/demos/`
    When I push updates to the documentation set
    Then the epic maintains traceability between code, tests, and docs
