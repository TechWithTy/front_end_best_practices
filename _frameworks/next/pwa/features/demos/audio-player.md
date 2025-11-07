# Audio Player Demo
Browse: [https://progressier.com/pwa-capabilities/audio-player-pwa](https://progressier.com/pwa-capabilities/audio-player-pwa)

Last updated: 2025-11-07

## Summary
The audio player example highlights Media Session API support, including lock-screen artwork, transport controls, and metadata updates for background playback.

## Implementation Insights
- Shows how to set `navigator.mediaSession.metadata` and handle action callbacks (`play`, `pause`, `seekto`).
- Demonstrates that the UI continues playing when the app is minimized or locked.
- Emphasizes fallback when the API is unsupported, defaulting to in-page controls.

## Deal Scale Implementation Example
Candidate hook for `lib/hooks/useMediaSession.ts` consumed by training audio player.

```tsx
"use client";
import { useEffect } from "react";

type MediaSessionConfig = {
	title: string;
	artist?: string;
	album?: string;
	artwork?: { src: string; sizes: string; type?: string }[];
	onPlay?: () => void;
	onPause?: () => void;
};

export function useMediaSession(config: MediaSessionConfig) {
	useEffect(() => {
		if (!("mediaSession" in navigator)) return;

		navigator.mediaSession.metadata = new MediaMetadata({
			title: config.title,
			artist: config.artist,
			album: config.album,
			artwork: config.artwork,
		});

		if (config.onPlay) navigator.mediaSession.setActionHandler("play", config.onPlay);
		if (config.onPause) navigator.mediaSession.setActionHandler("pause", config.onPause);

		return () => {
			navigator.mediaSession.metadata = null;
			navigator.mediaSession.setActionHandler("play", null);
			navigator.mediaSession.setActionHandler("pause", null);
		};
	}, [config]);
}
```

## Notes for Deal Scale
- Apply the same metadata pattern to AI call recordings and training audio so that agents can control playback while multitasking.
- Consider replicating their UI hints instructing users to add the PWA to the home screen for better audio controls.
