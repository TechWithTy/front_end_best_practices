# Installation Demo
Browse: [https://progressier.com/pwa-capabilities/installation](https://progressier.com/pwa-capabilities/installation)

Last updated: 2025-11-07

## Summary
Progressier demonstrates install prompts across desktop and mobile, showing how PWAs appear in system install banners and how fallback messaging works when criteria are not met.

## Implementation Insights
- Requires a valid manifest plus service worker; the demo visually confirms these prerequisites before enabling the install CTA.
- Covers both `beforeinstallprompt` and manual add-to-home-screen flows.
- Illustrates UX for informing users when the install button is unavailable.

## Deal Scale Implementation Example
Located in `components/pwa/InstallPrompt.tsx` and consumed via `components/layout/providers.tsx`.

```tsx
"use client";
import { Button } from "@/components/ui/button";
import { InstallPrompt } from "@/components/pwa/InstallPrompt";
import { useInstallPrompt } from "@/hooks/useInstallPrompt";

export function InstallBanner() {
	const { shouldShowBanner, showInstallPrompt, dismissBanner, isPrompting } =
		useInstallPrompt();

	if (!shouldShowBanner) return null;

	return (
		<div className="rounded-xl border bg-background p-4 shadow-lg">
			<p className="text-sm text-muted-foreground">
				Install Deal Scale for offline dashboards and push alerts.
			</p>
			<div className="mt-3 flex gap-2">
				<Button disabled={isPrompting} onClick={() => void showInstallPrompt()}>
					{isPrompting ? "Preparing…" : "Install app"}
				</Button>
				<Button variant="ghost" onClick={dismissBanner}>
					Maybe later
				</Button>
			</div>
		</div>
	);
}
```

## Notes for Deal Scale
- Adopt similar gating logic in `InstallPrompt` so the button only appears when the browser is ready.
- Provide OS-specific instructions (e.g., iOS share sheet) consistent with the demo’s copy.
