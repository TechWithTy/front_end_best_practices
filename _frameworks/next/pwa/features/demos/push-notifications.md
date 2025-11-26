# Push Notifications Demo
Browse: [https://progressier.com/pwa-capabilities/push-notifications](https://progressier.com/pwa-capabilities/push-notifications)

Last updated: 2025-11-07

## Summary
The demo showcases the full lifecycle of enabling notifications: requesting permission, registering a service worker, saving the subscription, and triggering a sample notification payload.

## Implementation Insights
- Uses the Web Push API with VAPID keys to send payloads from a backend endpoint.
- Highlights progressive enhancement—UI changes depending on permission state (default, granted, denied).
- Demonstrates notification click handling that focuses or opens a client window.

## Deal Scale Implementation Example
Located in `components/pwa/PushManager.tsx` and surfaced globally via `components/layout/providers.tsx`.

```tsx
"use client";
import { usePushManager } from "@/hooks/usePushManager";
import { Button } from "@/components/ui/button";

export function PushOptIn() {
	const { permission, requestPermission, isRegistering } = usePushManager();

	if (permission === "granted") {
		return <p className="text-sm text-muted-foreground">Alerts enabled ✅</p>;
	}

	return (
		<Button
			disabled={isRegistering}
			onClick={() => void requestPermission({ showToast: true })}
		>
			{isRegistering ? "Enabling…" : "Enable campaign alerts"}
		</Button>
	);
}
```

## Notes for Deal Scale
- Mirror the progressive UI for our `PushManager` component to educate users before prompting.
- Capture analytics when permission is denied so CSMs can follow up with high-value accounts.
