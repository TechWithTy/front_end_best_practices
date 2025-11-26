# Screen Capture Demo
Browse: [https://progressier.com/pwa-capabilities/screen-capture-desktop](https://progressier.com/pwa-capabilities/screen-capture-desktop)

Last updated: 2025-11-07

## Summary
The demo records the desktop screen, providing controls to start/stop capture and preview the resulting video.

## Implementation Insights
- Uses `navigator.mediaDevices.getDisplayMedia` and `MediaRecorder`.
- Highlights OS-level permission prompts and monitor selection on desktop.
- Demonstrates saving the captured video locally.

## Deal Scale Implementation Example
Screen capture helper for support sessions.

```tsx
"use client";
import { useRef, useState } from "react";
import { Button } from "@/components/ui/button";

export function ScreenCapture({ onComplete }: { onComplete: (blob: Blob) => void }) {
	const [isRecording, setIsRecording] = useState(false);
	const previewRef = useRef<HTMLVideoElement>(null);
	const recorderRef = useRef<MediaRecorder | null>(null);
	const chunksRef = useRef<BlobPart[]>([]);

	async function startCapture() {
		const stream = await navigator.mediaDevices.getDisplayMedia({ video: true, audio: true });
		if (previewRef.current) previewRef.current.srcObject = stream;
		const recorder = new MediaRecorder(stream);
		recorder.ondataavailable = (evt) => chunksRef.current.push(evt.data);
		recorder.onstop = () => {
			const blob = new Blob(chunksRef.current, { type: "video/webm" });
			chunksRef.current = [];
			onComplete(blob);
		};
		recorder.start();
		recorderRef.current = recorder;
		setIsRecording(true);
	}

	function stopCapture() {
		recorderRef.current?.stop();
		setIsRecording(false);
	}

	return (
		<div className="space-y-2">
			<video ref={previewRef} autoPlay muted className="rounded border" />
			<div className="flex gap-2">
				<Button onClick={() => void startCapture()} disabled={isRecording}>
					Start capture
				</Button>
				<Button onClick={stopCapture} disabled={!isRecording} variant="destructive">
					Stop
				</Button>
			</div>
		</div>
	);
}
```

## Notes for Deal Scale
- Useful for recording campaign configuration walkthroughs or support sessions.
- Add legal/privacy notices before recording, similar to the demo’s reminders.
