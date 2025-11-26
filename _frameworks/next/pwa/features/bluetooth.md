# Web Bluetooth

## Capability
Connect to BLE devices (e.g., smart lockboxes or voice peripherals) directly from the PWA.

## Implementation
1. Require secure context (HTTPS) and user gesture to call `navigator.bluetooth.requestDevice`.
2. Define filters/services for supported hardware.
3. Handle GATT connections and read/write characteristics for device control.
4. Provide pairing guides and error handling for dropped connections.
