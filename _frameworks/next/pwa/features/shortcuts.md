# Shortcuts

## Capability
Expose quick actions from the app icon (desktop/mobile) that deep-link into dashboard flows.

## Implementation
1. Add `shortcuts` array to `manifest.json`, e.g.,
   ```json
   {
     "name": "New Campaign",
     "url": "/dashboard/campaigns?prefill=new",
     "icons": [{ "src": "/icons/shortcut-campaign.png", "sizes": "96x96" }]
   }
   ```
2. Ensure routes support query parameters to pre-load context (campaign builder, lead list, etc.).
3. Test across platforms (Android Chrome, Windows Edge) to verify icon assets and labels.
4. Track usage in analytics to refine available shortcuts.
