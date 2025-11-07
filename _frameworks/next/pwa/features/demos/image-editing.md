# Image Editing Demo
Browse: [https://progressier.com/pwa-capabilities/image-editing](https://progressier.com/pwa-capabilities/image-editing)

Last updated: 2025-11-07

## Summary
This demo offers client-side image editing—cropping, filters, and annotations—showing how PWAs can replace native photo apps.

## Implementation Insights
- Uses Canvas APIs for real-time adjustments without server uploads.
- Demonstrates undo/redo controls and export options.
- Highlights the importance of performance optimizations for large images.

## Deal Scale Implementation Example
Core canvas wrapper for annotating property photos.

```tsx
"use client";
import { useEffect, useRef } from "react";

export function CanvasEditor({ image, onExport }: { image: HTMLImageElement; onExport: (blob: Blob) => void }) {
	const canvasRef = useRef<HTMLCanvasElement>(null);

	useEffect(() => {
		const canvas = canvasRef.current;
		if (!canvas) return;
		const ctx = canvas.getContext("2d");
		if (!ctx) return;

		canvas.width = image.width;
		canvas.height = image.height;
		ctx.drawImage(image, 0, 0);
	}, [image]);

	async function handleExport() {
		const canvas = canvasRef.current;
		if (!canvas) return;
		canvas.toBlob((blob) => blob && onExport(blob), "image/png", 0.92);
	}

	return (
		<div className="space-y-2">
			<canvas ref={canvasRef} className="rounded border" />
			<button className="text-primary underline" onClick={() => void handleExport()}>
				Export image
			</button>
		</div>
	);
}
```

## Notes for Deal Scale
- Adopt similar tooling for annotating property photos or marketing assets.
- Ensure we provide accessible controls (keyboard shortcuts, ARIA labels) as seen in polished demos.
