# Bluetooth Demo
Browse: [https://progressier.com/pwa-capabilities/bluetooth](https://progressier.com/pwa-capabilities/bluetooth)

Last updated: 2025-11-07

## Summary
Progressier’s example connects to a BLE peripheral, reads sensor data, and visualizes the live stream inside the PWA.

## Implementation Insights
- Uses `navigator.bluetooth.requestDevice` with filters and optional services.
- Shows the GATT connection lifecycle—connecting, reading characteristics, and handling disconnects.
- Provides fallback messaging for browsers/devices without Web Bluetooth support.

## Deal Scale Implementation Example
BLE helper for smart lockboxes (`lib/integrations/ble.ts`).

```ts
export async function connectLockbox(serviceUUID: BluetoothServiceUUID, characteristicUUID: BluetoothCharacteristicUUID) {
	if (!navigator.bluetooth) throw new Error("Web Bluetooth not supported");

	const device = await navigator.bluetooth.requestDevice({
		filters: [{ services: [serviceUUID] }],
		optionalServices: [serviceUUID],
	});

	const server = await device.gatt?.connect();
	if (!server) throw new Error("Failed to connect to device");

	const service = await server.getPrimaryService(serviceUUID);
	const characteristic = await service.getCharacteristic(characteristicUUID);

	return {
		device,
		characteristic,
		async read() {
			const value = await characteristic.readValue();
			return value;
		},
		async write(data: ArrayBuffer) {
			await characteristic.writeValueWithoutResponse(data);
		},
	};
}
```

## Notes for Deal Scale
- Follow similar patterns if integrating with smart padlocks or IoT devices in the field.
- Ensure we guard the UI behind feature detection and provide audit logs of hardware interactions.
