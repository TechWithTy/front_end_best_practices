# In-App Browser Demo
Browse: [https://progressier.com/pwa-capabilities/in-app-browser](https://progressier.com/pwa-capabilities/in-app-browser)

Last updated: 2025-11-07

## Summary
Progressier demonstrates embedding external sites in a webview-like shell, providing navigation controls and secure origin messaging.

## Implementation Insights
- Typically implemented via `<iframe>` with sandbox policies or by launching new window contexts.
- Highlights privacy considerations and the need to surface the destination URL to users.
- Shows how PWAs can mimic native in-app browsers without handing off to Safari/Chrome.

## Deal Scale Implementation Example
Lightweight wrapper for previewing external lead sources.

```tsx
"use client";
import { useState } from "react";
import { Button } from "@/components/ui/button";

export function InAppBrowser({ src }: { src: string }) {
	const [isOpen, setIsOpen] = useState(false);

	return (
		<div className="space-y-2">
			<Button onClick={() => setIsOpen(true)}>Open preview</Button>
			{isOpen ? (
				<div className="h-[480px] overflow-hidden rounded border">
					<iframe title="in-app browser" src={src} className="h-full w-full" sandbox="allow-scripts allow-same-origin" />
				</div>
			) : null}
		</div>
	);
}
```

## Notes for Deal Scale
- Always display the destination URL and avoid storing credentials inside embedded frames.
- Apply CSP headers to restrict embedded origins to trusted partners.
