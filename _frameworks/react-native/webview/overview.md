# React Native WebView Overview
Browse: [https://github.com/react-native-webview/react-native-webview#readme](https://github.com/react-native-webview/react-native-webview#readme)

Last updated: 2025-11-07

## Summary
`react-native-webview` is the community-maintained replacement for the legacy core WebView. It supports iOS, Android, macOS, Windows, and Expo, and exposes rich APIs for navigation, messaging, file upload, and platform-specific tweaks. In Deal Scale, WebView is relevant for embedding partner dashboards, rendering contract PDFs, or exposing tenant-specific microsites without leaving the mobile shell.

## Installation
```sh
pnpm add react-native-webview
cd ios && pod install && cd ..
```
- On Android, enable multidex if `:app:mergeDexRelease` fails.
- Ensure the native module is linked (autolinking on RN 0.60+, manual link otherwise).

## Basic Usage
```tsx
import { WebView } from "react-native-webview";

export function DealScaleWebview({ uri }: { uri: string }) {
	return <WebView source={{ uri }} style={{ flex: 1 }} startInLoadingState />;
}
```
- Set `style={{ flex: 1 }}` so the view fills screen.
- Use `originWhitelist={["https://*"]}` to restrict allowed origins when needed.

## Key Capabilities
- **Messaging bridge** via `onMessage` and `injectJavaScript`.
- **Navigation control** with `onNavigationStateChange` and `onShouldStartLoadWithRequest`.
- **File uploads** and camera integration on Android/iOS.
- **Pull-to-refresh** (`refreshControl`) and inline loading indicators.
- **Open source**: frequent releases, Fabric support, Expo compatibility.

## Platform Considerations
- **iOS**: set `allowsInlineMediaPlayback` and `sharedCookiesEnabled` for SSO flows.
- **Android**: configure `domStorageEnabled`, `mixedContentMode`, and `hardwareAccelerationDisabled` as needed.
- **Windows/macOS**: rely on Microsoft-maintained implementation (check README for setup).

## Deal Scale Notes
- Wrap partner embeds in a dedicated WebView screen and expose deep links (`deal-scale://webview?url=`).
- Enforce per-tenant origin allowlists; reject unexpected redirects in `onShouldStartLoadWithRequest`.
- Use the messaging bridge to bubble analytics events back into our Redux/Zustand stores.
- Provide offline fallback by layering PWA caching (if the remote site supports it) and showing a reconnect banner when `onError` fires.
