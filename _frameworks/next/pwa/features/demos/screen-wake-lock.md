# Screen Wake Lock Demo
Browse: [https://progressier.com/pwa-capabilities/screen-wake-lock](https://progressier.com/pwa-capabilities/screen-wake-lock)

Last updated: 2025-11-07

## Summary
This demo keeps the device screen awake during critical tasks, showing both success and error states for the Screen Wake Lock API.

## Implementation Insights
- Requests `navigator.wakeLock.request('screen')` with user-initiated buttons.
- Handles visibility changes and automatically re-acquires the lock when appropriate.
- Provides clear messaging when the API is unsupported or the request fails.

## Deal Scale Implementation Example
Hook for long-running campaign monitoring (`hooks/useWakeLock.ts`).

```ts
"use client";
import { useEffect, useRef, useState } from "react";

export function useWakeLock(enabled: boolean) {
	const wakeLockRef = useRef<WakeLockSentinel | null>(null);
	const [error, setError] = useState<string | null>(null);

	useEffect(() => {
		async function requestLock() {
			if (!enabled || !("wakeLock" in navigator)) return;
			try {
				wakeLockRef.current = await navigator.wakeLock.request("screen");
				setError(null);
			} catch (err) {
				setError((err as DOMException).message);
			}
		}

		void requestLock();

		return () => {
			wakeLockRef.current?.release();
			wakeLockRef.current = null;
		};
	}, [enabled]);

	return { supported: "wakeLock" in navigator, error };
}
```

## Notes for Deal Scale
- Use wake lock during long-running campaign uploads or phone banking sessions.
- Mirror their UI toggle so users can opt out to conserve battery.
