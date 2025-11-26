# Geolocation Demo
Browse: [https://progressier.com/pwa-capabilities/geolocation](https://progressier.com/pwa-capabilities/geolocation)

Last updated: 2025-11-07

## Summary
Progressier’s demo walks through requesting the Geolocation permission, displaying the browser prompt, and rendering coordinates on a map preview so users can see the result in real time.

## Implementation Insights
- Requires a secure origin (HTTPS) and a user gesture before calling `navigator.geolocation.getCurrentPosition` or `watchPosition`.
- Includes graceful handling for permission denial and highlights the need for fallback inputs.
- Demonstrates updating the UI with latitude/longitude and reverse geocoding to a human-readable address.

## Deal Scale Implementation Example
Prototype component for campaign targeting (place inside `components/maps` namespace).

```tsx
"use client";
import { useState } from "react";

type Position = { lat: number; lng: number } | null;

export function UseCurrentLocationButton({ onResolve }: { onResolve: (pos: Position) => void }) {
	const [error, setError] = useState<string | null>(null);

	async function handleLocate() {
		if (!("geolocation" in navigator)) {
			setError("Geolocation not supported in this browser.");
			return;
		}

		navigator.geolocation.getCurrentPosition(
			({ coords }) => {
				const position: Position = { lat: coords.latitude, lng: coords.longitude };
				onResolve(position);
				setError(null);
			},
			(err) => setError(err.message),
			{ enableHighAccuracy: true, timeout: 10_000 }
		);
	}

	return (
		<div className="space-y-2">
			<button className="text-sm text-primary underline" onClick={() => void handleLocate()}>
				Use my location
			</button>
			{error ? <p className="text-xs text-destructive">{error}</p> : null}
		</div>
	);
}
```

## Notes for Deal Scale
- Reuse this flow for market targeting and quick lead lookup from the field.
- Log permission outcomes for analytics so CS can assist users who repeatedly deny location access.
