# File System Demo
Browse: [https://progressier.com/pwa-capabilities/file-system-desktop](https://progressier.com/pwa-capabilities/file-system-desktop)

Last updated: 2025-11-07

## Summary
The demo showcases the File System Access API on desktop browsers—opening files, editing them in place, and saving changes back to disk without server round-trips.

## Implementation Insights
- Requires user gestures for `showOpenFilePicker` / `showSaveFilePicker`, as demonstrated via buttons in the UI.
- Highlights permission prompts and the need to remember or forget previously granted access.
- Shows real-time updates to the file contents, proving the PWA can act like a native editor.

## Deal Scale Implementation Example
Helper for importing campaign CSVs. Place in `lib/utils/file-system.ts` and call from upload modals.

```tsx
export async function openLeadCsv(): Promise<File | null> {
	if (!("showOpenFilePicker" in window)) {
		console.warn("File System Access API not supported");
		return null;
	}

	const [handle] = await window.showOpenFilePicker({
		multiple: false,
		types: [
			{
				description: "CSV",
				accept: { "text/csv": [".csv"] },
			},
		],
	});

	const file = await handle.getFile();
	return file;
}
```

## Notes for Deal Scale
- Use the same patterns for lead-list CSV imports and exports, providing a fallback for browsers without the API.
- Warn users when the API is unavailable and offer a traditional upload flow, mirroring the demo’s progressive enhancement approach.
