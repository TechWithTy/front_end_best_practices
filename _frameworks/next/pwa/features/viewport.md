# Viewport

## Capability
Control viewport behaviour for better keyboard handling on mobile installs.

## Implementation
1. Ensure `<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">` lives in `app/layout.tsx` head.
2. Test on iOS Safari to confirm the keyboard doesn’t cause layout jumps for form-heavy dialogs.
3. Use CSS safe-area inset variables for notch devices.
4. Keep `environment` overlays minimal to avoid conflicting with the viewport meta tag.
