# AR / VR (WebXR)

## Capability
Place virtual property models or run immersive training using WebXR APIs.

## Implementation
1. Detect WebXR support and session modes (`immersive-ar`, `immersive-vr`).
2. Load lightweight scene (Three.js or Babylon) only when requested to avoid bundle bloat.
3. Provide fallback 3D previews or videos when hardware unsupported.
4. Handle session lifecycle (enter/exit) and permissions gracefully.
