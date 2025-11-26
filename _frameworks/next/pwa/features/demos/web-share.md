# Web Share Demo
Browse: [https://progressier.com/pwa-capabilities/web-share](https://progressier.com/pwa-capabilities/web-share)

Last updated: 2025-11-07

## Summary
Progressier demonstrates invoking the native share sheet for URLs, text, and files from within a PWA.

## Implementation Insights
- Uses `navigator.share` for basic payloads, and `navigator.canShare({ files })` before attaching file data.
- Provides UI feedback when sharing succeeds or fails.
- Includes fallback instructions when the API is not available.

## Deal Scale Implementation Example
Share button for campaign summary reports.

```tsx
"use client";
import { Button } from "@/components/ui/button";

export function CampaignShareButton({ summaryUrl }: { summaryUrl: string }) {
	async function handleShare() {
		if (!navigator.share) {
			await navigator.clipboard.writeText(summaryUrl);
			alert("Link copied to clipboard");
			return;
		}
		await navigator.share({
			title: "Deal Scale Campaign Summary",
			text: "Review performance for our latest outreach.",
			url: summaryUrl,
		});
	}

	return (
		<Button variant="outline" onClick={() => void handleShare()}>
			Share summary
		</Button>
	);
}
```

## Notes for Deal Scale
- Adopt the same fallback to “Copy link” when running on unsupported browsers.
- Instrument share events to gauge which reports or dashboards are most frequently shared.
