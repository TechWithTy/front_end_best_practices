# Notifications – Test Plan

## Scenario
User enables notifications and receives push payload while app inactive.

## Setup
- Use Vitest to mock `PushManager`, `Notification`, and service worker registration.
- Mock `/api/push/subscribe` request using MSW or fetch stub.
- Simulate `push` event by dispatching to service worker handler.

## Assertions
- `usePushStore` transitions through `default -> granted` state and stores subscription JSON.
- Service worker `push` event triggers `showNotification` with deep link data.
- `notificationclick` focuses existing client or opens new window at expected URL.

## Follow-ups
- Manual push test via `web-push` CLI or Firebase Cloud Messaging sandbox.
