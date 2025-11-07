# Speech Recognition Demo
Browse: [https://progressier.com/pwa-capabilities/speech-recognition](https://progressier.com/pwa-capabilities/speech-recognition)

Last updated: 2025-11-07

## Summary
The demo performs real-time transcription using the Web Speech API (`webkitSpeechRecognition`) and displays text as the user speaks.

## Implementation Insights
- Requires prefixes (currently Chrome-only) and handles interim vs. final results.
- Shows start/stop controls and error messaging when the microphone or API fails.
- Demonstrates language selection impacting recognition accuracy.

## Deal Scale Implementation Example
Speech-to-text helper for call logs.

```ts
export function createRecognizer(onTranscript: (text: string, isFinal: boolean) => void) {
	const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
	if (!SpeechRecognition) throw new Error("Speech Recognition unsupported");

	const recognition = new SpeechRecognition();
	recognition.lang = "en-US";
	recognition.continuous = true;
	recognition.interimResults = true;
	recognition.onresult = (event) => {
		const result = event.results[event.results.length - 1];
		onTranscript(result[0].transcript, result.isFinal);
	};

	return recognition;
}
```

## Notes for Deal Scale
- Apply to automated note-taking during calls, with a fallback manual note field when unsupported.
- Respect privacy laws by obtaining consent before transcription.
