# Media Capture

## Capability
Capture camera/microphone input for live agent scripts, property walkthroughs, or support messages.

## Implementation
1. Use `navigator.mediaDevices.getUserMedia` with permission gating (camera/mic).
2. Store streams in React state; supply to components handling video preview or audio recording.
3. For uploads, pipe MediaRecorder blobs to our storage pipeline (UploadThing/S3).
4. Provide fallback instructions when permissions are denied or device lacks hardware.
5. Ensure PWA manifest includes appropriate categories (e.g., `"categories": ["business", "productivity"]`) and update privacy disclosures.
