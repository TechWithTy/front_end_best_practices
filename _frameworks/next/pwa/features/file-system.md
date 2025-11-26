# File System API

## Capability
Read and write local files (e.g., CSV lead lists) directly without traditional upload dialogs.

## Implementation
1. Feature-detect `window.showOpenFilePicker` / `showSaveFilePicker` (Chromium-only).
2. Offer optional “Open local list” flow for power users; fall back to conventional upload.
3. Securely parse selected files client-side (CSV parser already in `lib/_utils`).
4. Request `FileSystemWritableFileStream` for exporting reports.
5. Handle permission revocation and cleanup handles when users sign out.
