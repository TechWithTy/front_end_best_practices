# Screen Capturing

## Capability
Capture and share screens during collaboration or onboarding sessions using Capture Handle & Surface Control.

## Implementation
1. Leverage `navigator.mediaDevices.getDisplayMedia` for initial capture.
2. When available, use Capture Handle APIs to control remote surfaces (Chrome Origin Trial).
3. Provide UI to stop sharing and revoke handles.
4. Encrypt/secure streams if transmitting to backend services.
