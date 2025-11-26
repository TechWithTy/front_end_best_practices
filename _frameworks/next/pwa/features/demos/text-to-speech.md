# Text-to-Speech Demo
Browse: [https://progressier.com/pwa-capabilities/text-to-speech-synthesis](https://progressier.com/pwa-capabilities/text-to-speech-synthesis)

Last updated: 2025-11-07

## Summary
This demo converts text to audio using the Speech Synthesis API, letting users choose voices and control playback speed.

## Implementation Insights
- Uses `speechSynthesis.getVoices()` to list available voices per device.
- Demonstrates queuing utterances and cancelling ongoing speech.
- Highlights fallback messaging for browsers lacking speech synthesis support.

## Deal Scale Implementation Example
Hook powering AI summary narration.

```ts
"use client";
import { useCallback } from "react";

export function useSpeech() {
	const speak = useCallback((text: string) => {
		if (!("speechSynthesis" in window)) return;
		const utterance = new SpeechSynthesisUtterance(text);
		utterance.lang = "en-US";
		window.speechSynthesis.cancel();
		window.speechSynthesis.speak(utterance);
	}, []);

	const cancel = useCallback(() => {
		if ("speechSynthesis" in window) window.speechSynthesis.cancel();
	}, []);

	return { speak, cancel };
}
```

## Notes for Deal Scale
- Integrate similar controls for reading AI-generated summaries aloud to multitasking agents.
- Cache commonly used utterances to avoid repeated synthesis where possible.
