# Geolocation

## Capability
Request user location to tailor market analytics or map-based lead searches.

## Implementation
1. Use `navigator.geolocation.getCurrentPosition` / `watchPosition` after explicit user action (e.g., “Use my location”).
2. Update permissions copy and privacy policy to explain usage.
3. Feed coordinates into existing market or map stores (`lib/stores/leadsMarket`).
4. Cache last-known location in IndexedDB for offline defaults.
5. Provide fallback input (manual address) when permission is denied.
