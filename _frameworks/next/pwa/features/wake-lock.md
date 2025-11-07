# Screen Wake Lock

## Capability
Prevent device from sleeping during lengthy workflows (e.g., live campaign monitoring).

## Implementation
1. Detect `navigator.wakeLock` and request `wakeLock.request('screen')` within a user gesture.
2. Reacquire lock on visibility changes (`document.visibilitychange`).
3. Provide UI toggle so users can opt out.
4. Release lock when workflow ends to conserve battery.
