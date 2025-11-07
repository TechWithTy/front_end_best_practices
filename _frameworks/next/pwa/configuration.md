# Configuration Checklist

Use this checklist before shipping PWA changes:

1. **Manifest**
   - Update `name`, `short_name`, `description`, `scope`, `start_url`.
   - Provide maskable icons (192px, 512px) and shortcuts (e.g., `/dashboard`).
2. **Service worker**
   - Edit `public/sw-config.js` runtime caches and queue names.
   - Confirm `next.config.js` imports the config and passes it to `next-pwa`.
   - Rebuild whenever `sw-custom.js` changes (Workbox precache manifest updates).
3. **Security headers**
   - Ensure `/sw-custom.js` returns with `Cache-Control: no-cache`, `Content-Type` JavaScript, and CSP `script-src 'self'`.
4. **Environment**
   - Keep `NEXT_PUBLIC_VAPID_PUBLIC_KEY` + `VAPID_PRIVATE_KEY` in `.env.local`.
   - Use `next dev --experimental-https` or a dev proxy with TLS when testing notifications.
5. **CI/CD**
   - Add `pnpm test:pwa` to relevant pipelines (at least per-branch).
   - Validate `pnpm lint` includes `public/sw-config.js` and `sw-custom.js` if applicable.
