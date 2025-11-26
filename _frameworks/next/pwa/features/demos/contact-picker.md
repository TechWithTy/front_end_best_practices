# Contact Picker Demo
Browse: [https://progressier.com/pwa-capabilities/contact-picker](https://progressier.com/pwa-capabilities/contact-picker)

Last updated: 2025-11-07

## Summary
The demo uses the Contact Picker API to let users select contacts from native address books and displays selected fields.

## Implementation Insights
- Calls `navigator.contacts.select` with desired properties (name, email, phone).
- Requires a secure origin and user gesture; includes fallbacks when unsupported.
- Highlights privacy messaging around accessing personal contacts.

## Deal Scale Implementation Example
Utility for onboarding quick audience creation.

```ts
export async function pickContacts() {
	if (!("contacts" in navigator) || !("select" in navigator.contacts)) {
		throw new Error("Contact Picker API not supported");
	}

	const contacts = await navigator.contacts.select(
		["name", "email", "tel"],
		{ multiple: true }
	);

	return contacts.map((contact) => ({
		name: contact.name?.[0] ?? "",
		email: contact.email?.[0] ?? "",
		phone: contact.tel?.[0] ?? "",
	}));
}
```

## Notes for Deal Scale
- Leverage this flow in campaign creation to quickly seed custom audiences.
- Audit and store consent logs since contact data may be sensitive.
