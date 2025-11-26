# App Shortcuts Demo
Browse: [https://progressier.com/pwa-capabilities/app-shortcuts](https://progressier.com/pwa-capabilities/app-shortcuts)

Last updated: 2025-11-07

## Summary
Progressier illustrates manifest-defined shortcuts that appear on the home screen or taskbar, enabling users to deep-link into specific app sections instantly.

## Implementation Insights
- Shows the manifest structure for `shortcuts` with names, icons, and URLs.
- Demonstrates OS-specific UIs (Android long-press, desktop context menus).
- Provides guidance when the browser does not support shortcuts, encouraging manual navigation.

## Deal Scale Implementation Example
Add to `public/manifest.json`:

```json
{
  "shortcuts": [
    {
      "name": "New Campaign",
      "short_name": "Campaign",
      "description": "Create a new multi-channel campaign",
      "url": "/dashboard/campaigns?prefill=new",
      "icons": [{ "src": "/icons/shortcut-campaign.png", "sizes": "96x96" }]
    },
    {
      "name": "Lead Search",
      "url": "/dashboard/lead-list",
      "icons": [{ "src": "/icons/shortcut-leads.png", "sizes": "96x96" }]
    }
  ]
}
```

## Notes for Deal Scale
- Align our manifest entries with the flows most frequently used by agents (e.g., New Campaign, Lead Search).
- Localize shortcut labels since OS menus display them verbatim.
