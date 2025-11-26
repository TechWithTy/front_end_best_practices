# Vibration API

## Capability
Provide subtle haptic feedback for mobile interactions (e.g., confirming lead save).

## Implementation
1. Feature-detect `navigator.vibrate` and guard behind user gestures.
2. Define short patterns (`navigator.vibrate([20, 10, 20])`) for key events.
3. Offer user settings to disable haptics and respect system-level preferences.
4. Avoid excessive vibration to conserve battery.
