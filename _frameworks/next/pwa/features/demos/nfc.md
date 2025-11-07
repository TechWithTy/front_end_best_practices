# NFC Demo
Browse: [https://progressier.com/pwa-capabilities/nfc](https://progressier.com/pwa-capabilities/nfc)

Last updated: 2025-11-07

## Summary
The demo scans NFC tags on supported Android devices, showing how a PWA can read and write data without native code.

## Implementation Insights
- Uses the Web NFC API (`NDEFReader`) which currently ships on Android Chrome.
- Requires user gesture and secure context before invoking `reader.scan()` or `writer.write()`.
- Provides messaging for unsupported browsers.

## Deal Scale Implementation Example
Reader utility for event check-ins.

```ts
export async function readNfcTag() {
	if (!("NDEFReader" in window)) throw new Error("Web NFC not supported");
	const reader = new (window as any).NDEFReader();
	await reader.scan();
	return new Promise<string>((resolve) => {
		reader.onreading = (event: NDEFReadingEvent) => {
			const record = event.message.records[0];
			const textDecoder = new TextDecoder(record.encoding ?? "utf-8");
			resolve(textDecoder.decode(record.data));
		};
	});
}
```

## Notes for Deal Scale
- Wrap in feature detection and show instructions to tap the tag near the designated device area, just like the demo.
- Store audit trails whenever NFC data triggers sensitive workflows (e.g., property access logs).
