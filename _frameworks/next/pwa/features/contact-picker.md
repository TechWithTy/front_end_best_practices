# Contact Picker

## Capability
Allow users to pull phone/email data from device contacts when setting up campaigns.

## Implementation
1. Detect `navigator.contacts.select` support.
2. Define fields (`name`, `email`, `tel`) and call within a user gesture.
3. Map returned contacts into our lead form and preview before saving.
4. Gracefully degrade to manual entry when unsupported or permission denied.
5. Update privacy policy to cover access to personal contacts.
