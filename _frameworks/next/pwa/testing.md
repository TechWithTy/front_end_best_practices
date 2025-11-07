# Testing

| Command | Purpose |
| --- | --- |
| `pnpm test:pwa` | Vitest suite covering hooks/stores for push, install, service worker updates |
| `pnpm test:stores` | Non-Playwright store/unit coverage |
| `pnpm test:stores:playwright` | Legacy Playwright specs under `lib/stores/user/_tests` |

Guidelines:
- Run `pnpm test:pwa` on every PWA-related change.
- Extend `tests/pwa/pwa.spec.ts` with new hook/store behaviour.
- Use Playwright (`test:stores:playwright`) when native-like UI regression coverage is needed.
