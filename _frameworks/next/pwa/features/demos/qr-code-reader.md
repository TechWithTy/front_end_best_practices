# QR Code Reader Demo
Browse: [https://progressier.com/pwa-capabilities/qr-code-and-barcode-reader](https://progressier.com/pwa-capabilities/qr-code-and-barcode-reader)

Last updated: 2025-11-07

## Summary
This demo scans QR codes and barcodes using the camera, immediately decoding the content and displaying it in the UI.

## Implementation Insights
- Relies on the Barcode Detection API with a camera stream produced by `getUserMedia`.
- Handles live scanning feedback, including success and error states when codes are unreadable.
- Demonstrates permission handling and fallback messaging for unsupported browsers.

## Deal Scale Implementation Example
Scanner widget for property flyers (`components/scanner/QrScanner.tsx`).

```tsx
"use client";
import { useEffect, useRef, useState } from "react";

export function QrScanner({ onDetect }: { onDetect: (value: string) => void }) {
	const videoRef = useRef<HTMLVideoElement>(null);
	const [error, setError] = useState<string | null>(null);

	useEffect(() => {
		let detector: BarcodeDetector | null = null;
		let stop = false;

		async function enableScanner() {
			if (!("BarcodeDetector" in window)) {
				setError("BarcodeDetector API not supported");
				return;
			}
			try {
				detector = new BarcodeDetector({ formats: ["qr_code", "code_128"] });
				const stream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: "environment" } });
				if (videoRef.current) videoRef.current.srcObject = stream;
				const scan = async () => {
					if (stop || !videoRef.current) return;
					try {
						const detections = await detector!.detect(videoRef.current);
						if (detections.length) onDetect(detections[0].rawValue);
					} catch {}
					requestAnimationFrame(scan);
				};
				scan();
			} catch (err) {
				setError((err as DOMException).message);
			}
		}

		void enableScanner();

		return () => {
			stop = true;
			const tracks = (videoRef.current?.srcObject as MediaStream | null)?.getTracks();
			tracks?.forEach((track) => track.stop());
		};
	}, [onDetect]);

	return (
		<div className="space-y-2">
			<video ref={videoRef} autoPlay playsInline className="rounded border" />
			{error ? <p className="text-xs text-destructive">{error}</p> : null}
		</div>
	);
}
```

## Notes for Deal Scale
- Apply the same UX for scanning property flyers or event badges to auto-populate lead forms.
- Provide guidance when users deny camera access and log these events for support teams.
