# React Native WebView Props G–Z

This file continues the props reference starting with `menuItems` and ending with `paymentRequestEnabled`.

## `menuItems`
Custom context-menu entries when selecting text. Provide array of `{ label, key }` objects. An empty array suppresses the menu. Use with [`onCustomMenuSelection`](#oncustommenuselection).

| Type                               | Required | Platform           |
| ---------------------------------- | -------- | ------------------ |
| array of { label: string, key: string } | No   | iOS, Android       |

Example:
```jsx
<WebView
  menuItems=[
    { label: 'Tweet', key: 'tweet' },
    { label: 'Save for later', key: 'saveForLater' },
  ]
/>
```

---

## `onCustomMenuSelection`
Called when a custom menu item is tapped; event includes `label`, `key`, and `selectedText`.

| Type     | Required | Platform           |
| -------- | -------- | ------------------ |
| function | No       | iOS, Android       |

---

## `basicAuthCredential`
Provides `{ username, password }` for HTTP Basic Auth.

| Type   | Required |
| ------ | -------- |
| object | No       |

---

## `useWebView2`
Windows-only toggle using WinUI WebView2 (Edge/Chromium) instead of legacy control. Supports Fast Refresh.

| Type    | Required | Platform |
| ------- | -------- | -------- |
| boolean | No       | Windows  |

---

## `minimumFontSize`
Android minimum font size (1–72). Default 8. Helps fit UI when users pick large system font sizes.

| Type   | Required | Platform |
| ------ | -------- | -------- |
| number | No       | Android  |

---

## `downloadingMessage`
Android toast message shown when downloads start. Default "Downloading".

| Type   | Required | Platform |
| ------ | -------- | -------- |
| string | No       | Android  |

---

## `lackPermissionToDownloadMessage`
Android toast message when storage permission is missing. Default explains permission denial.

| Type   | Required | Platform |
| ------ | -------- | -------- |
| string | No       | Android  |

---

## `allowsProtectedMedia`
Android DRM playback toggle (default `false`). Reload to revoke existing grants.

| Type    | Required | Platform |
| ------- | -------- | -------- |
| boolean | No       | Android  |

---

## `fraudulentWebsiteWarningEnabled`
Enables iOS 13+ phishing/malware warnings. Default `true`.

| Type    | Required | Platform |
| ------- | -------- | -------- |
| boolean | No       | iOS      |

---

## `webviewDebuggingEnabled`
Allows remote debugging (Safari/Chrome). Defaults to `false`; iOS <16.4 always allowed debugging.

| Type    | Required | Platform        |
| ------- | -------- | ---------------- |
| boolean | No       | iOS & Android    |

---

## `paymentRequestEnabled`
Enables Payment Request API (e.g., Google Pay) inside the WebView. Default `false`.

| Type    | Required | Platform |
| ------- | -------- | -------- |
| boolean | No       | Android  |
