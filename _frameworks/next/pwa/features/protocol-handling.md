# Protocol Handling

## Capability
Register custom URL schemes so Deal Scale opens when users click matching links (e.g., `dealscale://lead/123`).

## Implementation
1. Add `protocol_handlers` array to `manifest.json` specifying scheme and target URL.
2. Implement routing in Next.js to parse incoming parameters and load the correct dashboard view.
3. For unsupported browsers, provide fallback link explaining manual navigation.
4. Verify on Chromium-based browsers (desktop & Android). Safari currently limited.
