# Payment Requests Demo
Browse: [https://progressier.com/pwa-capabilities/payment-requests](https://progressier.com/pwa-capabilities/payment-requests)

Last updated: 2025-11-07

## Summary
The demo triggers the Payment Request API to display native checkout UIs, supporting cards and wallets like Apple Pay/Google Pay.

## Implementation Insights
- Requires HTTPS and a supported browser (Chrome, Edge, Android WebView).
- Defines `PaymentMethodData` (e.g., basic-card) and `PaymentDetailsInit` objects before calling `new PaymentRequest(...)`.
- Shows error handling and fallback messaging when payment requests are unavailable.

## Deal Scale Implementation Example
Checkout helper bridging to Stripe intent confirmation.

```ts
export async function launchPaymentRequest(total: number) {
	if (!window.PaymentRequest) throw new Error("Payment Request API not supported");

	const supportedInstruments: PaymentMethodData[] = [
		{ supportedMethods: "basic-card", data: { supportedNetworks: ["visa", "mastercard", "amex"] } },
	];

	const details: PaymentDetailsInit = {
		total: { label: "Deal Scale Subscription", amount: { currency: "USD", value: total.toFixed(2) } },
	};

	const request = new PaymentRequest(supportedInstruments, details);
	const response = await request.show();
	// send response.details to backend for processing, then complete
	await response.complete("success");
}
```

## Notes for Deal Scale
- Tie the captured card data into our Stripe PaymentIntent confirmation endpoint.
- Provide fallback to hosted checkout when the API is unsupported or the payment fails mid-flow.
