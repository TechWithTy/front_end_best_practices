# Rsdoctor Setup & Usage (Rspack/Rsbuild Projects)

Rsdoctor is the build “doctor” for the Rspack ecosystem. It records each bundler run, surfaces bottlenecks, and gives you a browser UI for digging into loaders, plugins, chunks, and duplicate deps. This guide shows how to wire it into our Rsbuild preview stack and run the analyzer with a single pnpm script.

---

## 1. Install the tooling

```bash
pnpm add -D @rsdoctor/cli @rsdoctor/rspack-plugin
```

`@rsdoctor/rspack-plugin` hooks into Rsbuild/Rspack to emit the manifest Rsdoctor reads. `@rsdoctor/cli` exposes the `rsdoctor analyze` command we’ll call from pnpm scripts.

---

## 2. Register the plugin in Rsbuild

Edit `tools/rspack-preview/rsbuild.config.ts` (or whichever Rsbuild config drives your preview build) and add the plugin:

```ts
import { rsdoctorRspackPlugin } from "@rsdoctor/rspack-plugin";

export default defineConfig({
  // …existing config
  plugins: [
    pluginReact(),
    rsdoctorRspackPlugin({
      enableReport: true,              // emit .rsdoctor/manifest.json
      outputPath: ".rsdoctor",         // default; keep repo root for easy lookup
      analyzer: { open: false },       // let CLI decide when to open the UI
    }),
  ],
});
```

Key points:

- Leave `open: false` so the build doesn’t spawn a browser in CI; we’ll open the UI on demand.
- By default the plugin writes `.rsdoctor/manifest.json` at the project root. Make sure `.gitignore` ignores the directory (`.rsdoctor/` is already in our ignore file).

---

## 3. Add the pnpm script

Append (or confirm) the following in `package.json → scripts`:

```jsonc
"doctor:rspack": "pnpm run build:rspack && pnpm dlx @rsdoctor/cli analyze --profile .rsdoctor/manifest.json"
```

What it does:

1. Runs the existing `build:rspack` script so the Rsdoctor plugin can capture the full build.
2. Launches the Rsdoctor CLI and opens the report in your browser (use `--no-open` if running headless, e.g. CI).

> **Tip:** For CI, append `--no-open --port 49152` and pipe the CLI output to artifacts. You can also run `pnpm dlx @rsdoctor/cli bundle-diff --baseline=baseline.json --current=current.json` for regression diffing between two builds.

---

## 4. Running the doctor

```bash
pnpm run doctor:rspack
```

You’ll see:

```
[Rsbuild] …build logs…
rsdoctor/1.x.x
✔ Analyzer ready at http://localhost:4399
```

Open the printed URL to explore:

- **Compilation overview:** flame chart of loader/plugin time.
- **Asset map:** size, gzip/brotli budgets, duplicated chunks, etc.
- **Rule center:** built-in audits (duplicate deps, ES version mismatches).

---

## 5. Troubleshooting

| Symptom | Root cause | Fix |
| --- | --- | --- |
| `Error: .rsdoctor/manifest.json not found` | Build skipped or plugin missing | Re-run `pnpm run build:rspack`, ensure the plugin is registered |
| Browser doesn’t open | Running in headless shell | Add `--no-open` intentionally, then manually open the printed URL |
| Ports already in use | Another analyzer running | Pass `--port` to the CLI or stop the existing instance |
| Huge `.rsdoctor` dir in git status | Directory not ignored | Add `.rsdoctor/` to `.gitignore` |

---

## 6. Optional bundle diffing

To compare two manifests (e.g., main vs. feature branch):

```bash
pnpm dlx @rsdoctor/cli bundle-diff \
  --baseline .rsdoctor/main-manifest.json \
  --current  .rsdoctor/feature-manifest.json
```

This highlights chunk size regressions, duplicate packages, and loader timing changes in a single UI.

---

## 7. Reference

- [Rsdoctor GitHub](https://github.com/web-infra-dev/rsdoctor)
- [CLI docs](https://github.com/web-infra-dev/rsdoctor/tree/main/packages/cli)
- [Rspack plugin options](https://github.com/web-infra-dev/rsdoctor/tree/main/packages/rspack-plugin)

Keep this doc updated as Rsdoctor adds new rules or when we integrate it directly into CI/CD.

