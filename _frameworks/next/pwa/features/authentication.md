# Authentication (WebAuthn)

## Capability
Enable passwordless login using device biometrics or security keys through Web Authentication API.

## Implementation
1. Extend Auth.js credentials provider to support WebAuthn registration and assertion endpoints.
2. Use `navigator.credentials.create` and `navigator.credentials.get` with multifactor fallback.
3. Store public keys in backend (FastAPI/Prisma) tied to tenant/user.
4. Update sign-in UI to offer fingerprint or hardware key options.
5. Provide recovery flows (email OTP) for unsupported browsers.
