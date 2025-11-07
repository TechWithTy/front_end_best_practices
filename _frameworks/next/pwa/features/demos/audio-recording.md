# Audio Recording Demo
Browse: [https://progressier.com/pwa-capabilities/audio-recording](https://progressier.com/pwa-capabilities/audio-recording)

Last updated: 2025-11-07

## Summary
This demo captures microphone input in the browser, visualizes waveform data, and lets users play back or save the recording.

## Implementation Insights
- Uses `navigator.mediaDevices.getUserMedia({ audio: true })` followed by `MediaRecorder` to store chunks.
- Demonstrates recording controls (start, pause, stop) and playback of the resulting blob.
- Highlights the permission prompt and fallback messaging when audio capture is unsupported.

## Deal Scale Implementation Example
Audio memo component for agent notes (drop into `components/voice/VoiceMemo.tsx`).

```tsx
"use client";
import { useEffect, useRef, useState } from "react";
import { Button } from "@/components/ui/button";

export function VoiceMemo({ onSave }: { onSave: (blob: Blob) => void }) {
	const [isRecording, setIsRecording] = useState(false);
	const recorderRef = useRef<MediaRecorder | null>(null);
	const chunksRef = useRef<BlobPart[]>([]);

	useEffect(() => () => recorderRef.current?.stop(), []);

	async function startRecording() {
		const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
		const recorder = new MediaRecorder(stream);
		recorder.ondataavailable = (evt) => chunksRef.current.push(evt.data);
		recorder.onstop = () => {
			const blob = new Blob(chunksRef.current, { type: "audio/webm" });
			chunksRef.current = [];
			onSave(blob);
		};
		recorder.start();
		recorderRef.current = recorder;
		setIsRecording(true);
	}

	function stopRecording() {
		recorderRef.current?.stop();
		setIsRecording(false);
	}

	return (
		<div className="flex gap-2">
			<Button disabled={isRecording} onClick={() => void startRecording()}>
				Start
			</Button>
			<Button disabled={!isRecording} onClick={stopRecording} variant="destructive">
				Stop
			</Button>
		</div>
	);
}
```

## Notes for Deal Scale
- Use similar controls for agent coaching notes or quick voice memos on leads.
- Remind users to grant microphone permissions and provide safe defaults when they decline.
