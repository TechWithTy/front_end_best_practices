# Web Share API

## Capability
Share campaign insights or lead reports through the native OS share sheet.

## Implementation
1. Detect `navigator.share` and prepare payload (title, text, URL, optional files).
2. Trigger from CTA buttons (e.g., Share campaign summary).
3. Provide fallback UI (copy link) when unsupported.
4. For file sharing (`navigator.canShare({ files })`), compress exports (CSV/PDF) before passing to the API.
