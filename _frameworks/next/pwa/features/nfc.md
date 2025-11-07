# Web NFC

## Capability
Read/write NFC tags (e.g., property signage, on-site check-ins) from compatible devices.

## Implementation
1. Detect `NDEFReader` support (Android Chrome only for now).
2. Request permission with `reader.scan()` tied to user gesture.
3. Parse records (text/URI) and route to relevant dashboard flows.
4. For writing, use `writer.write()` with caution—validate user intent to prevent accidental overwrites.
