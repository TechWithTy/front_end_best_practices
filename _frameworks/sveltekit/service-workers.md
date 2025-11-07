# SvelteKit Service Workers
Browse: [https://kit.svelte.dev/docs/service-workers](https://kit.svelte.dev/docs/service-workers)

Last updated: 2025-11-07

## Summary
SvelteKit automatically bundles and registers a service worker when you add `src/service-worker.js`. The documentation walks through precaching build assets, handling `install/activate/fetch` events, versioning caches, and opting out of automatic registration when you need custom logic.

## Implementation Insights
- Built assets (`build`) and static files (`files`) are exposed via the `$service-worker` module for precaching.
- The default registration uses `navigator.serviceWorker.register` after `load`; you can disable it and register manually with `{ type: dev ? 'module' : 'classic' }` during development.
- Service workers should carefully cache resources, purge old caches on `activate`, and fall back to the network to avoid stale data.

## Example Snippet (from docs)
```js
import { build, files, version } from '$service-worker';
const CACHE = `cache-${version}`;
const ASSETS = [...build, ...files];

self.addEventListener('install', (event) => {
  event.waitUntil((async () => {
    const cache = await caches.open(CACHE);
    await cache.addAll(ASSETS);
  })());
});

self.addEventListener('fetch', (event) => {
  if (event.request.method !== 'GET') return;
  event.respondWith((async () => {
    const cache = await caches.open(CACHE);
    if (ASSETS.includes(new URL(event.request.url).pathname)) {
      return (await cache.match(event.request)) ?? fetch(event.request);
    }
    try {
      const response = await fetch(event.request);
      if (response instanceof Response && response.status === 200) {
        cache.put(event.request, response.clone());
      }
      return response;
    } catch {
      return (await cache.match(event.request)) ?? Promise.reject();
    }
  })());
});
```

## Notes for Deal Scale
- Even though we use Next.js, SvelteKit’s guide is a clear reference for structuring Workbox-free service workers (install/activate/fetch lifecycle, versioned caches). We can mirror the pattern inside `public/sw-custom.js`.
- Reminder: seamless offline support often requires local-first architecture (see [https://localfirstweb.dev/](https://localfirstweb.dev/)). For Deal Scale, we focus on precaching shell assets and queuing mutations rather than full offline CRUD.
