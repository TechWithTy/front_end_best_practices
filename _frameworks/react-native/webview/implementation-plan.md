# React Native WebView Implementation Plan

Last updated: 2025-11-08  
Owner: Mobile Platform Guild  
Related docs: [overview](./overview.md), [props reference](./reference/README.md), [Next.js PWA plan](../next/pwa/roadmap.md)

## 1. Objectives
- Embed partner dashboards, contract signing flows, and tenant microsites in the mobile shell without duplicating web UI work.
- Maintain performance parity with native screens and preserve observability, security, and offline guarantees.
- Establish a reusable WebView container that integrates with Deal Scale navigation, analytics, and auth stacks.

## 2. Deliverables & Timeline
| Milestone | Target | Exit Criteria |
| --- | --- | --- |
| Architecture sign-off | Week 1 | Approved tech brief covering navigation, messaging, and security posture. |
| Prototype embed screen | Week 3 | Basic `WebViewScreen` with URL allowlist, loading state, and analytics events. |
| Platform hardening | Week 5 | iOS/Android parity, offline banner, file upload handling, deep link support. |
| Observability & QA | Week 6 | Playwright smoke tests, Detox/E2E checklist, dashboards in Grafana. |
| Production rollout | Week 8 | Feature flag enabled for first partner, incident runbook published. |

## 3. Architecture Overview
1. **Route Surface**
   - Introduce `mobile://webview/:id` deep link resolving to `WebViewScreen`.
   - Push from existing navigation stacks using shared `NavigationService`.
2. **Configuration Source**
   - Store tenant-specific WebView descriptors via the typed manifest in `lib/config/mobile/webviews.ts`.
   - Expose read-only configuration to clients through `GET /api/mobile/webviews` (implemented in `app/api/mobile/webviews/route.ts`) with CDN-friendly cache headers.
3. **Rendering Layer**
   - `<DealScaleWebView />` wrapper exporting consistent props: `uri`, `title`, `scriptSnippets`, `allowMessaging`.
   - Compose from `react-native-webview`, Zustand store for runtime state, and shared loading/error components.
4. **Messaging Bridge**
   - Standardize `window.dealscale.postMessage({ type, payload })` JavaScript interface injected at load.
   - Handle events in React Native via `onMessage` and dispatch to domain-specific handlers (analytics, auth refresh).
5. **Security & Compliance**
   - Enforce origin allowlists per tenant, TLS-only, and optional mutual auth headers.
   - Sanitise injected scripts, disable `javaScriptEnabled` when not required, and enable Safe Browsing flags on Android.

## 4. Platform Readiness Checklist
### 4.1 iOS
- Enable `WKWebView` configuration for shared cookies: `sharedCookiesEnabled`, `limitsNavigationsToAppBoundDomains`.
- Configure ATS exceptions for partner domains via `Info.plist`.
- Implement `SFSafariViewController` fallback when WebView detects unsupported features.
- Add file picker delegate support for uploads (camera, photo library).

### 4.2 Android
- Set `domStorageEnabled`, `thirdPartyCookiesEnabled`, `mixedContentMode="never"` by default.
- Ship custom `shouldOverrideUrlLoading` to intercept non-http(s) schemes.
- Handle file uploads through `onShowFileChooser` bridge, integrate with native permission prompts.
- Verify WebView2 (Android System WebView) minimum version via Play Store requirements.

### 4.3 Windows/macOS (if applicable)
- Validate WinUI WebView2 package and ensure auto-updater handles runtime distribution.
- Provide keyboard/mouse accessibility parity with desktop expectations.

## 5. Auth & Session Strategy
1. Share Auth.js session cookies using platform-specific cookie managers.
2. Inject short-lived JWT headers via `onShouldStartLoadWithRequest` to sign outbound requests.
3. Renew tokens when `session-expiring` message arrives from the embedded site.
4. Prevent auth leakage by clearing WebView data on logout and when switching tenants.

## 6. Offline & Error Handling
- Display cached skeleton until initial navigation success or failure.
- Listen for `onError` / `onHttpError` to show retry CTA and escalate to Sentry.
- Integrate with existing offline store: show reconnection banner and auto-retry on connectivity regain.
- Provide manual refresh gesture (pull-to-refresh) and developer reload via debug menu.

## 7. Observability & Telemetry
- Emit analytics events via messaging bridge: `webview_loaded`, `webview_error`, `webview_message`.
- Log console warnings/errors from injected script to centralized logger.
- Attach trace headers (`x-ds-trace-id`) to all requests for distributed tracing across WebView and backend.
- Monitor performance metrics (TTI, input delay) using injected `PerformanceObserver` and forward to PostHog.

## 8. QA & Testing Strategy
1. **Unit Tests**
   - Component tests with React Native Testing Library for wrappers, state, and messaging dispatch.
2. **Integration Tests**
   - Detox flows simulating navigation to WebView screens, message passing, file uploads.
3. **Cross-Platform Matrix**
   - Minimum OS versions: iOS 16, Android 13. Cover dark mode, accessibility settings, low connectivity.
4. **Embedded Site Contract**
   - Maintain contract tests ensuring partner app implements required messaging schema.
5. **Security Testing**
   - Run OWASP mobile checks, verify Content Security Policy enforcement inside embedded app.

## 9. Rollout Plan
1. Ship behind remote feature flag `webview.enabled`.
2. Launch internal beta with staging partner site; collect telemetry for one sprint.
3. Stagger production rollout by tenant cohort; monitor crash-free rate and performance.
4. Provide rollback switch in LaunchDarkly to disable WebView module instantly.

## 10. Dependencies & Owners
| Area | Owner | Notes |
| --- | --- | --- |
| WebView container, messaging | Mobile Core | Implements shared wrapper & bridge. |
| Backend `/api/webviews` | Platform API | Supplies configuration & allowlists. |
| Analytics instrumentation | Data Engineering | Ensures event schemas, dashboards. |
| QA automation | Quality Guild | Expands Detox suite and monitors regressions. |
| Partner onboarding | Partner Ops | Validates embedded content readiness. |

## 11. Open Questions
- Do we need payment flows within WebView that trigger native purchase SDKs?
- Should we ship a hybrid navigation mode allowing fallback to native modules mid-session?
- How will we version the messaging schema with external partners to prevent drift?

Track answers in the Mobile Platform guild backlog; update this plan once decisions are finalized.

