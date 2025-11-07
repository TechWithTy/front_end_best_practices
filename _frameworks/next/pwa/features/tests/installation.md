# Installation – Test Plan

## Scenario
User completes onboarding and is prompted to install the PWA.

## Setup
- Render component wrapping `InstallPrompt` + `useInstallPrompt` hook.
- Mock:
  - `window.addEventListener('beforeinstallprompt')` to dispatch synthetic event with `prompt` stub.
  - `localStorage` entries for visit counts.
  - `appinstalled` event.

## Assertions
- Banner appears after visit threshold and engagement event.
- Calling CTA triggers `prompt()` and hides banner on success.
- `appinstalled` event fires analytics callback and dismisses UI.

## Follow-ups
- Manual test on Chrome/Edge to confirm OS prompt behaviour.
