# Vite Plugin PWA Implementation Plan
Browse: [https://github.com/vite-pwa/vite-plugin-pwa](https://github.com/vite-pwa/vite-plugin-pwa)
Browse: [https://vite-pwa-org.netlify.app/assets-generator/](https://vite-pwa-org.netlify.app/assets-generator/)

Last updated: 2025-11-07

## Objectives
- Adopt `vite-plugin-pwa` with a clear map of supported capabilities.
- Align Workbox-powered strategies (generateSW vs injectManifest) with Deal Scale feature requirements.
- Integrate the `@vite-pwa/assets-generator` workflow to produce compliant icon sets and manifest entries.

## Feature Coverage Matrix
| Capability | Plugin Support | Deal Scale Usage |
| --- | --- | --- |
| Offline shell + asset precache | `generateSW` defaults with Workbox runtime caching | Mirror Next.js Workbox config; ensure lead-list dashboards stay cached |
| Stale-while-revalidate updates | `registerSW({ immediate })` prompt/auto modes | Pair with existing update toast UX |
| Background sync / periodic updates | Periodic SW update examples in repo | Align with campaign draft queue |
| Push notification hooks | Manual (virtual modules + Workbox Window) | Reuse current push stack, ensure messaging integration |
| Manifest + shortcuts injection | Manifest builder, `includeAssets`, assets generator | Keep shortcuts consistent with Next manifest |
| Assets pipeline | `@vite-pwa/assets-generator` presets | Generate minimal 2023 set from Deal Scale logo |
| Dev tooling | Dev SW support, debug logs | Use `devOptions.enabled` for staging |

## Implementation Steps
1. **Install Tooling**
   - `pnpm add -D vite-plugin-pwa @vite-pwa/assets-generator` (plugin + assets CLI).
2. **Update `vite.config.ts`**
   - Register `VitePWA` with `registerType: "prompt"`, `includeAssets`, `manifest` scaffold.
   - Choose strategy: use `generateSW` first; switch to `injectManifest` when custom SW needed.
3. **Configure Workbox**
   - Set `runtimeCaching` rules mirroring Next.js `sw-config` (API, analytics, images).
   - Enable `workbox.cleanupOutdatedCaches` and `navigateFallback`.
4. **Service Worker Logic**
   - If `injectManifest`, create `src/service-worker.ts`; port custom routes, background sync logic.
   - Use `workbox-window` in React entry for update prompts.
5. **Assets Generation**
   - Create `pwa-assets.config.ts` using `minimal-2023` preset.
   - Run `pnpm vite-pwa generate` (CLI) to produce icons and head links. Update manifest icons.
6. **React App Hook**
   - Import `virtual:pwa-register/react` to wire prompt/auto update logic with existing toast system.
7. **Testing Strategy**
   - Use plugin examples as baseline; add Vitest hooks verifying register handler, update events, and manifest injection.
   - Stage environment in Vite dev mode (`devOptions.enabled`) to validate periodic updates.
8. **Deployment Checks**
   - Confirm build artefacts include `manifest.webmanifest`, `registerSW.js`, generated assets.
   - Run Lighthouse PWA checks; ensure icon coverage per assets generator recommendations.

## Follow-Up Tasks
- Document delta between Next.js PWA and Vite PWA implementations.
- Add regression tests covering SW registration and prompt flows in Vite scaffolding.
