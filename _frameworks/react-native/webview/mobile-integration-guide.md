# React Native WebView Integration Guide

Last updated: 2025-11-08  
Audience: Mobile Platform Guild  
Related endpoints: `GET /api/mobile/webviews`

## Overview
This guide explains how to consume the Deal Scale WebView manifests inside the standalone React Native shell. Follow the steps in sequence to minimise risk to existing PWA behaviour while enabling full-featured embeds for partner dashboards, contract flows, and microsites.

## 1. Bootstrap Manifest Layer
- Fetch `/api/mobile/webviews` during app bootstrap. Cache the result in Zustand or React Query with a five-minute stale window and background revalidation.
- Mirror the `MobileWebviewManifest` TypeScript type so client code stays aligned with the server schema.
- Respect the `featureFlags` array: skip manifest entries unless `webview.enabled` is present.

### Sample manifest type
```typescript
export type MobileWebviewManifest = {
	id: string;
	title: string;
	description: string;
	uri: string;
	allowedOrigins: string[];
	offlineFallbackPath: string | null;
	featureFlags: string[];
	analytics: { page: string; eventPrefix: string } | null;
	allowedMessagingTopics: string[];
};
```

## 2. Navigation & Deep Links
- Register a `WebViewScreen` (e.g., `mobile://webview/:id`) with the existing navigation stack.
- Resolve `:id` against the cached manifest; if not found or disabled, redirect to a native fallback screen.
- Handle deep links and push notifications that reference embed IDs by ensuring manifests load before route resolution.

## 3. WebView Container
- Create a `<DealScaleWebView>` wrapper around `react-native-webview`.
- Required behaviours:
  - `source={{ uri: manifest.uri }}` with strict `originWhitelist` derived from `manifest.allowedOrigins`.
  - `allowsBackForwardNavigationGestures`, `mixedContentMode="never"`, `allowsInlineMediaPlayback`.
  - Custom loading spinner, pull-to-refresh, and offline banner driven by connection state.
- Inject the standard messaging bridge on load: `window.dealscale.postMessage({ type, payload })`.

## 4. Messaging Bridge
- Define TypeScript contracts for messages using `manifest.allowedMessagingTopics`.
- Dispatch `onMessage` events to domain-specific handlers:
  - `analytics` → log with PostHog or internal telemetry using `eventPrefix`.
  - `session` → refresh auth tokens or prompt re-login.
  - `notifications` → surface native banners or modals.
- Strip messages originating from non-allowed origins and debounce high-frequency events to protect performance.

## 5. Auth Session Synchronisation
- Enable shared cookies (`sharedCookiesEnabled` on iOS, `CookieManager` sync on Android) so Auth.js sessions bridge correctly.
- Use `onShouldStartLoadWithRequest` to append short-lived headers (JWT or HMAC) for authenticated endpoints.
- Listen for `session-expiring` messages to trigger native refresh workflows.
- Clear WebView storage on logout or tenant switch to avoid credential leakage.

## 6. Offline & Error Handling
- Show a skeleton UI until the first successful navigation event.
- On `onError` or `onHttpError`, render a local fallback using `manifest.offlineFallbackPath` if provided.
- Subscribe to native connectivity events to auto-retry and display a reconnect banner.
- Log all failures to Sentry with the current manifest ID for traceability.

## 7. Platform-Specific Requirements
### iOS
- Configure `WKWebView` with `limitsNavigationsToAppBoundDomains`.
- Implement `UIDocumentPickerViewController` handling for file uploads.
- Support `SFSafariViewController` fallback for external authentication flows.

### Android
- Enable `domStorage` and `thirdPartyCookiesEnabled` where required.
- Override `shouldOverrideUrlLoading` to intercept unsupported schemes and open them natively.
- Provide custom `onShowFileChooser` implementation for camera/library uploads.

### Windows/macOS (if targeted)
- Ensure WebView2 runtime deployment and keyboard accessibility parity.

## 8. Observability
- Emit analytics events (`webview_loaded`, `webview_error`, custom topics) through the existing telemetry pipeline.
- Attach trace headers (e.g., `x-ds-trace-id`) for distributed tracing across embedded web and backend services.
- Forward console warnings/errors from the WebView to native logging for diagnostics.

## 9. Testing Strategy
- **Unit**: React Native Testing Library for wrapper, bridge, and manifest resolver logic.
- **Integration**: Detox scenarios covering navigation, messaging, offline behaviour, and file uploads.
- **Contract**: Validate embedded partner apps comply with the messaging schema (JSON fixtures per manifest).
- **Security**: Run OWASP mobile checks plus static analysis to ensure origin and script restrictions hold.

## 10. Rollout Checklist
1. Feature flag WebView entry points using LaunchDarkly or equivalent.
2. Run internal beta with staging partners and monitor telemetry for at least one sprint.
3. Gradually enable production tenants; track crash-free rate, performance metrics, and user feedback.
4. Maintain rollback capability—disable the WebView flag to revert to native experiences instantly.

## 11. Ongoing Maintenance
- Keep `lib/config/mobile/webviews.ts` updated as partners onboard.
- Review telemetry dashboards weekly to catch regressions.
- Update this guide when messaging topics or security requirements evolve.

Following this guide ensures the React Native shell can safely consume the Deal Scale WebView experiences without disrupting existing PWA functionality.

















