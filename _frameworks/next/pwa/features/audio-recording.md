# Audio Recording

## Capability
Record audio notes or agent scripts via MediaRecorder and Web Audio.

## Implementation
1. Request `getUserMedia({ audio: true })` and handle permission prompts.
2. Use `MediaRecorder` to capture chunks; convert to Blob for uploads (UploadThing/S3).
3. Visualize waveform via Web Audio API for UX.
4. Provide pause/resume controls and show recording indicators to meet privacy expectations.
