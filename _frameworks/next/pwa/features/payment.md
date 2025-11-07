# Payment Request API

## Capability
Enable checkout experiences (credit card, Apple Pay, Google Pay) via browser-native UI.

## Implementation
1. Detect `window.PaymentRequest` and feature support per browser.
2. Prepare payment details (total, line items) and merchant info.
3. Tie into existing billing backend (Stripe) via tokenization.
4. Provide fallback to hosted Stripe checkout when unsupported.
