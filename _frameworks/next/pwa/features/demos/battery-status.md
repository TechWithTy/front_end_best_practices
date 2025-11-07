# Battery Status Demo
Browse: [https://progressier.com/pwa-capabilities/battery-status-api](https://progressier.com/pwa-capabilities/battery-status-api)

Last updated: 2025-11-07

## Summary
Progressier visualizes the device battery level, charging status, and estimated time to full/empty, updating in real time as conditions change.

## Implementation Insights
- Uses `navigator.getBattery()` (legacy API; supported in Chromium-based browsers).
- Subscribes to events like `chargingchange`, `levelchange`, `chargingtimechange` to refresh the UI.
- Includes graceful fallback for browsers that removed the API (Safari, Firefox).

## Deal Scale Implementation Example
Telemetry hook for long-running kiosk mode sessions.

```ts
"use client";
import { useEffect, useState } from "react";

type BatterySnapshot = { level: number; charging: boolean } | null;

export function useBatteryStatus() {
	const [snapshot, setSnapshot] = useState<BatterySnapshot>(null);

	useEffect(() => {
		let battery: BatteryManager | null = null;
		async function init() {
			if (!("getBattery" in navigator)) return;
			battery = await (navigator as any).getBattery();
			const update = () => setSnapshot({ level: battery!.level, charging: battery!.charging });
			update();
			battery.addEventListener("levelchange", update);
			battery.addEventListener("chargingchange", update);
		}
		void init();
		return () => {
			if (!battery) return;
			battery.removeEventListener("levelchange", () => {});
			battery.removeEventListener("chargingchange", () => {});
		};
	}, []);

	return snapshot;
}
```

## Notes for Deal Scale
- Useful for kiosk deployments where the dashboard runs on tablets all day—show warnings as the battery depletes.
- Because browser support is limited, treat this as an enhancement and default to traditional monitoring otherwise.
