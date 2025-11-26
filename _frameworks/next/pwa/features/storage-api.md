# Storage API

## Capability
Monitor and manage storage usage for cached data, drafts, and media.

## Implementation
1. Use `navigator.storage.estimate()` to display storage consumption and quota.
2. Provide controls to clear caches/drafts when nearing limits.
3. Combine with IndexedDB management to free space programmatically.
4. Communicate storage usage in user settings to avoid silent failures.
