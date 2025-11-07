# React Native WebView Props A–F

This file covers properties from `source` through `forceDarkOn`, mirroring the upstream API reference.

## `source`
Loads static HTML or a URI (with optional headers) in the WebView. Static HTML requires setting [`originWhitelist`](./props-a-f.md#originwhitelist) to `['*']`.

**Load URI**
- `uri` (string) – Target URL (local or remote).
- `method` (string) – HTTP method; Android/Windows only support GET/POST.
- `headers` (object) – Extra headers (GET-only on Android).
- `body` (string) – UTF-8 request body (POST-only on Android/Windows).

See the [Guide](../Guide.md#setting-custom-headers) for header examples.

**Static HTML**
- `html` (string) – Raw HTML content.
- `baseUrl` (string) – Base URL for relative paths (also sent as origin for CORS). See [Android WebView docs](https://developer.android.com/reference/android/webkit/WebView#loadDataWithBaseURL).

| Type   | Required |
| ------ | -------- |
| object | No       |

---

## `automaticallyAdjustContentInsets`
Adjusts content inset when the WebView sits behind navigation UI. Defaults to `true` (iOS only).

| Type | Required | Platform |
| ---- | -------- | -------- |
| bool | No       | iOS      |

---

## `automaticallyAdjustsScrollIndicatorInsets`
Controls scroll indicator insets for WebViews behind bars. Defaults to `false`. (iOS 13+).

| Type | Required | Platform |
| ---- | -------- | -------- |
| bool | No       | iOS(13+) |

---

## `injectedJavaScript`
Inject JavaScript after document load (before subresources). Ensure the string evaluates cleanly. Requires an `onMessage` handler on iOS to execute.

| Type   | Required | Platform                     |
| ------ | -------- | ---------------------------- |
| string | No       | iOS, Android, macOS, Windows |

Example:
```jsx
const INJECTED = `(() => {
  window.ReactNativeWebView.postMessage(JSON.stringify(window.location));
})();`;

<WebView
  source={{ uri: 'https://reactnative.dev' }}
  injectedJavaScript={INJECTED}
  onMessage={handleMessage}
/>
```

---

## `injectedJavaScriptBeforeContentLoaded`
Inject JavaScript after the document element exists but before subresources load. Android support is experimental—prefer `injectedJavaScriptObject` when possible.

| Type   | Required | Platform                           |
| ------ | -------- | ---------------------------------- |
| string | No       | iOS, macOS, Android (experimental) |

---

## `injectedJavaScriptForMainFrameOnly`
When `true` (default; mandatory on Android), limits `injectedJavaScript` to the main frame. `false` targets all frames (iOS/macOS only).

| Type | Required | Platform                                          |
| ---- | -------- | ------------------------------------------------- |
| bool | No       | iOS & macOS (Android supports `true` only)        |

---

## `injectedJavaScriptBeforeContentLoadedForMainFrameOnly`
Same semantics as above but for `injectedJavaScriptBeforeContentLoaded`.

| Type | Required | Platform                                          |
| ---- | -------- | ------------------------------------------------- |
| bool | No       | iOS & macOS (Android supports `true` only)        |

---

## `injectedJavaScriptObject`
Injects a JavaScript object accessible via `window.ReactNativeWebView.injectedObjectJson()`.

| Type | Required | Platform            |
| ---- | -------- | ------------------- |
| obj  | No       | iOS, Android        |

Example:
```jsx
<WebView
  source={{ uri: 'https://reactnative.dev' }}
  injectedJavaScriptObject={{ customValue: 'myCustomValue' }}
/>
```
```html
<script>
  window.onload = () => {
    const raw = window.ReactNativeWebView.injectedObjectJson?.();
    if (raw) {
      const { customValue } = JSON.parse(raw);
      // ...
    }
  };
</script>
```

---

## `mediaPlaybackRequiresUserAction`
Requires user interaction before HTML5 media playback. Defaults to `true`. Set to `false` to avoid stalled playback on some iOS videos.

| Type | Required | Platform            |
| ---- | -------- | ------------------- |
| bool | No       | iOS, Android, macOS |

---

## `nativeConfig`
Override the native component (`component`, `props`, `viewManager`) used for rendering.

| Type   | Required | Platform            |
| ------ | -------- | ------------------- |
| object | No       | iOS, Android, macOS |

---

## `onError`
Invoked when loading fails.

| Type     | Required |
| -------- | -------- |
| function | No       |

Native event includes:
```
canGoBack
canGoForward
code
description
didFailProvisionalNavigation
domain
loading
target
title
url
```

---

## `onLoad`
Called when loading finishes.

| Type     | Required |
| -------- | -------- |
| function | No       |

Native event includes `canGoBack`, `canGoForward`, `loading`, `target`, `title`, `url`.

---

## `onLoadEnd`
Runs whether load succeeds or fails.

| Type     | Required |
| -------- | -------- |
| function | No       |

---

## `onLoadStart`
Invoked when navigation begins.

| Type     | Required |
| -------- | -------- |
| function | No       |

---

## `onLoadProgress`
Fires during loading with `progress` (0–1).

| Type     | Required | Platform            |
| -------- | -------- | ------------------- |
| function | No       | iOS, Android, macOS |

---

## `onHttpError`
Called when an HTTP error is received (Android API 23+).

| Type     | Required |
| -------- | -------- |
| function | No       |

Native event adds `description` (Android only) and `statusCode`.

---

## `onRenderProcessGone`
Android API 26+: triggered when the render process crashes or is killed.

| Type     | Required |
| -------- | -------- |
| function | No       |

Native event: `didCrash`.

---

## `onMessage`
Handles messages from `window.ReactNativeWebView.postMessage`. Receives `event.nativeEvent.data` (string).

| Type     | Required |
| -------- | -------- |
| function | No       |

---

## `onNavigationStateChange`
Fires on navigation start/end with `navState` including `canGoBack`, `canGoForward`, `loading`, `target`, `title`, `url`, and iOS-only extras.

| Type     | Required |
| -------- | -------- |
| function | No       |

---

## `onOpenWindow`
Intercepts requests to open new windows (e.g., `window.open`, `target="_blank"`).

| Type     | Required |
| -------- | -------- |
| function | No       |

Native event: `targetUrl`.

---

## `onContentProcessDidTerminate`
iOS/macOS callback when the WebView process terminates (often due to memory pressure).

| Type     | Required | Platform                |
| -------- | -------- | ----------------------- |
| function | No       | iOS & macOS WKWebView   |

---

## `onScroll`
Receives scroll events.

| Type     | Required | Platform                     |
| -------- | -------- | ---------------------------- |
| function | No       | iOS, macOS, Android, Windows |

Native event exposes `contentInset`, `contentOffset`, `contentSize`, `layoutMeasurement`, `velocity`, `zoomScale`.

---

## `originWhitelist`
Whitelist of allowed origins for navigation (wildcards supported). Defaults to `['http://*', 'https://*']`.

| Type             | Required | Platform            |
| ---------------- | -------- | ------------------- |
| array of strings | No       | iOS, Android, macOS |

---

## `renderError`
Custom error view renderer.

| Type     | Required | Platform            |
| -------- | -------- | ------------------- |
| function | No       | iOS, Android, macOS |

---

## `renderLoading`
Custom loading indicator. Requires `startInLoadingState` set to `true`.

| Type     | Required | Platform            |
| -------- | -------- | ------------------- |
| function | No       | iOS, Android, macOS |

---

## `scalesPageToFit`
Android boolean controlling automatic scaling. Defaults to `true`.

| Type | Required | Platform |
| ---- | -------- | -------- |
| bool | No       | Android  |

---

## `onShouldStartLoadWithRequest`
Custom request handler. Return `true` to allow, `false` to block. Not invoked on the initial Android load.

| Type     | Required | Platform            |
| -------- | -------- | ------------------- |
| function | No       | iOS, Android, macOS |

`request` includes `title`, `url`, `loading`, `target`, navigation state, and iOS-specific fields.

---

## `startInLoadingState`
Shows the loading view during the first load. Required for `renderLoading`.

| Type | Required | Platform            |
| ---- | -------- | ------------------- |
| bool | No       | iOS, Android, macOS |

---

## `style`
Style object for the WebView. (Add `flex: 0` when specifying `height`).

| Type  | Required |
| ----- | -------- |
| style | No       |

---

## `containerStyle`
Style object for the WebView container (wraps the native view).

| Type  | Required |
| ----- | -------- |
| style | No       |

---

## `decelerationRate`
Scroll deceleration constant. Accepts numeric values or `
