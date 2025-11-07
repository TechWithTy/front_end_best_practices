# Biometric Authentication Demo
Browse: [https://progressier.com/pwa-capabilities/biometric-authentication-with-passkeys](https://progressier.com/pwa-capabilities/biometric-authentication-with-passkeys)

Last updated: 2025-11-07

## Summary
The demo guides users through registering and authenticating with passkeys (WebAuthn), including on-device biometrics.

## Implementation Insights
- Shows the browser UI for passkey enrollment and usage.
- Emphasizes fallback credentials when platforms or browsers do not support passkeys.
- Highlights cross-device sync via the user’s password manager ecosystem.

## Deal Scale Implementation Example
Server action + client helper for Auth.js credentials provider.

```ts
// app/api/auth/webauthn/register/route.ts
import { NextResponse } from "next/server";
import { generateRegistrationOptions } from "@simplewebauthn/server";

export async function POST() {
	const opts = await generateRegistrationOptions({
		rpName: "Deal Scale",
		userID: "<session user id>",
		userName: "user@example.com",
		attestationType: "none",
	});
	// persist challenge in DB for verification later
	return NextResponse.json(opts);
}
```

```tsx
// components/auth/PasskeyButton.tsx
"use client";
import { startRegistration } from "@simplewebauthn/browser";

export function PasskeyRegisterButton() {
	async function handleRegister() {
		const resp = await fetch("/api/auth/webauthn/register", { method: "POST" });
		const options = await resp.json();
		const attestation = await startRegistration(options);
		await fetch("/api/auth/webauthn/verify", {
			method: "POST",
			body: JSON.stringify(attestation),
		});
	}
	return <button onClick={() => void handleRegister()}>Register passkey</button>;
}
```

## Notes for Deal Scale
- Mirror the enrollment prompts for our Auth.js providers and clearly explain fallback methods.
- Track passkey adoption metrics to decide when to encourage migration away from passwords.
