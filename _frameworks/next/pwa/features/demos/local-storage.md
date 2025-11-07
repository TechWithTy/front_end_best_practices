# Local Storage Demo
Browse: [https://progressier.com/pwa-capabilities/localstorage-demo](https://progressier.com/pwa-capabilities/localstorage-demo)

Last updated: 2025-11-07

## Summary
The demo persists form input to `localStorage`, restoring it on reload to prove PWAs can save lightweight state offline.

## Implementation Insights
- Uses `localStorage.setItem`/`getItem` with JSON serialization.
- Shows the importance of namespacing keys to avoid collisions.
- Demonstrates clearing stored data through UI controls.

## Deal Scale Implementation Example
Helper for remembering last-used campaign filters.

```ts
const KEY = "dealscale:campaigntable:filters";

export function loadSavedFilters() {
	try {
		const raw = localStorage.getItem(KEY);
		return raw ? JSON.parse(raw) : null;
	} catch (err) {
		console.warn("Failed to parse saved filters", err);
		return null;
	}
}

export function saveFilters(filters: unknown) {
	try {
		localStorage.setItem(KEY, JSON.stringify(filters));
	} catch (err) {
		console.warn("Failed to persist filters", err);
	}
}
```

## Notes for Deal Scale
- Prefer IndexedDB for larger payloads, but `localStorage` remains useful for simple UI preferences.
- Debounce writes to avoid excessive `setItem` calls during rapid filter changes.
