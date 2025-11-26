# Video Recording Demo
Browse: [https://progressier.com/pwa-capabilities/video-recording](https://progressier.com/pwa-capabilities/video-recording)

Last updated: 2025-11-07

## Summary
The demo records video via the device camera, previews the feed, and lets users download or share the captured clip.

## Implementation Insights
- Combines `getUserMedia({ video: true })` with `MediaRecorder` for video capture.
- Highlights permission prompts and fallback messaging for unsupported platforms.
- Demonstrates basic controls for switching cameras (front/back) on mobile devices.

## Deal Scale Implementation Example
Prototype component for property walkthrough capture.

```tsx
"use client";
import { useEffect, useRef, useState } from "react";
import { Button } from "@/components/ui/button";

export function VideoRecorder({ onSave }: { onSave: (blob: Blob) => void }) {
	const videoRef = useRef<HTMLVideoElement>(null);
	const recorderRef = useRef<MediaRecorder | null>(null);
	const [isRecording, setIsRecording] = useState(false);

	useEffect(() => () => recorderRef.current?.stop(), []);

	async function start() {
		const stream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: "environment" }, audio: true });
		if (videoRef.current) videoRef.current.srcObject = stream;
		const recorder = new MediaRecorder(stream);
		recorder.ondataavailable = (evt) => onSave(new Blob([evt.data], { type: "video/webm" }));
		recorder.start();
		recorderRef.current = recorder;
		setIsRecording(true);
	}

	function stop() {
		recorderRef.current?.stop();
		setIsRecording(false);
	}

	return (
		<div className="space-y-2">
			<video ref={videoRef} autoPlay playsInline className="rounded-lg border" />
			<div className="flex gap-2">
				<Button disabled={isRecording} onClick={() => void start()}>Start</Button>
				<Button disabled={!isRecording} onClick={stop} variant="destructive">
					Stop
				</Button>
			</div>
		</div>
	);
}
```

## Notes for Deal Scale
- Use this pattern for property walk-throughs or customer testimonials submitted from the field.
- Provide storage warnings for large files and consider automatic uploads to our storage pipeline.
