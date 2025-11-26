# React Native WebView Methods

This file captures the public instance methods available on the WebView ref.

## `goForward()`
Navigate forward one step in the WebView history.

```ts
webViewRef.current?.goForward();
```

## `goBack()`
Navigate backward one step in history.

```ts
webViewRef.current?.goBack();
```

## `reload()`
Reload the current page.

```ts
webViewRef.current?.reload();
```

## `stopLoading()`
Stop the current navigation.

```ts
webViewRef.current?.stopLoading();
```

## `injectJavaScript(str)`
Execute JavaScript within the page context.

```ts
webViewRef.current?.injectJavaScript("window.ReactNativeWebView.postMessage('ping');");
```

See [Communicating between JS and Native](../Guide.md#communicating-between-js-and-native).

## `requestFocus()`
Ask the WebView to receive focus (useful for TV apps or focus-driven UIs).

```ts
webViewRef.current?.requestFocus();
```

## `postMessage(str)`
Send a message into the WebView to be received by `window.ReactNativeWebView.onMessage`.

```ts
webViewRef.current?.postMessage(JSON.stringify({ type: 'refresh' }));
```

## `clearFormData()` *(Android)*
Remove autocomplete popups for the focused field.

```ts
webViewRef.current?.clearFormData();
```

## `clearCache(includeDiskFiles)`
Clear browser cache. On iOS, also clears storage/databases when `true`. On Windows, clears cookies (Edge shares cache).

```ts
webViewRef.current?.clearCache(true);
```

## `clearHistory()` *(Android)*
Clear back/forward history list.

```ts
webViewRef.current?.clearHistory();
```
