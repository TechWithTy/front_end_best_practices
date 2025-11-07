# Barcode Detection

## Capability
Scan QR codes or barcodes (e.g., property flyers, event badges) using the camera.

## Implementation
1. Verify support for `BarcodeDetector`.
2. Request camera stream (`getUserMedia`) and pass frames to `detect`.
3. Debounce detections and autofill campaign or lead forms with scanned IDs.
4. Provide fallback to manual code entry if unsupported.
