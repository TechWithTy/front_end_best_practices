# Network Information Demo
Browse: [https://progressier.com/pwa-capabilities/network-information](https://progressier.com/pwa-capabilities/network-information)

Last updated: 2025-11-07

## Summary
The demo reads connection type, effective bandwidth, and round-trip time using the Network Information API, updating the UI as conditions change.

## Implementation Insights
- Uses `navigator.connection` to inspect `effectiveType`, `downlink`, and `rtt` values.
- Subscribes to the `change` event to react to network transitions in real time.
- Provides compatibility messaging when the API is not available.

## Deal Scale Implementation Example
Hook powering `useNetworkQuality` (already used in dashboard charts).

```ts
"use client";
import { useEffect, useState } from "react";

export function useNetworkQuality() {
	type Snapshot = { effectiveType: string | null; downlink: number | null; rtt: number | null };
	const [snapshot, setSnapshot] = useState<Snapshot>({ effectiveType: null, downlink: null, rtt: null });

	useEffect(() => {
		const connection = (navigator as any).connection;
		if (!connection) return;

		const update = () =>
			setSnapshot({
				effectiveType: connection.effectiveType ?? null,
				downlink: connection.downlink ?? null,
				rtt: connection.rtt ?? null,
			});

		update();
		connection.addEventListener?.("change", update);
		return () => connection.removeEventListener?.("change", update);
	}, []);

	return snapshot;
}
```

## Notes for Deal Scale
- Mirror this logic in `useNetworkQuality` to throttle heavy charts on slow networks.
- Log network stats around failed API calls to improve debugging.
