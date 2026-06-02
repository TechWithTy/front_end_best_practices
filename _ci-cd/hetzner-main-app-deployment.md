# DealScale Main App → Hetzner Deployment Plan

> Production UI + AI orchestration dashboard deployed alongside the FastAPI backend on Hetzner Cloud for lowest latency and unified operations.

---

## 1. Architecture Overview

- **Cloudflare CDN** fronts everything (`app.dealscale.io`, `api.dealscale.io`), caches static assets, shields Hetzner from DDoS, and terminates TLS.
- **Hetzner Cloud** hosts both services:
  - `app.dealscale.io`: Next.js SSR / RSC workload behind Traefik.
  - `api.dealscale.io`: FastAPI workers + Pulsar listeners.
- **Shared data plane** on the same VPC / region:
  - PostgreSQL (Supabase or Hetzner Cloud volumes)
  - Redis/Valkey cache + queues
  - Pulsar event bus
- **Shared observability**: Prometheus, Grafana, Loki, OpenTelemetry traces, Traefik dashboard.

**Benefits:** zero cross-region latency, shared secrets/auth, identical autoscaling profiles, unified caching, lower infra cost than Vercel SSR, and easier multi-agent orchestration.

---

## 2. Infrastructure Components

| Component | Stack | Notes |
| --- | --- | --- |
| Main App | Next.js 14, SSR/RSC, Docker | Served through Traefik, supports server actions + streaming |
| Backend | FastAPI, Uvicorn/Gunicorn | Runs event workers, Pulsar listeners, multi-tenant APIs |
| Shared Services | Postgres, Redis/Valkey, Pulsar | All inside Hetzner for LAN-speed calls |
| Edge Layer | Cloudflare CDN/Zero Trust | Global caching, Bot management, SSL, Zero Trust access |
| Observability | Prometheus, Grafana, Loki | Unified metrics/logs/traces |

---

## 3. Deployment Model (Zero-Downtime)

Directory layout (`/srv/dealscale/`):

```
/srv/dealscale/
├── docker-compose.yml
├── traefik/
├── app/
│   └── Dockerfile
├── api/
│   └── Dockerfile
├── logs/
├── ssl/
├── env/
├── prometheus/
└── grafana/
```

**Flow:**
1. CI builds Next.js + FastAPI images, pushes to GHCR.
2. GitHub Actions (or Taskmaster agent) SSHs into Hetzner node.
3. Pulls fresh images, runs `docker compose up -d --no-deps app`.
4. Traefik performs rolling swap via health checks (`/healthz`, `/api/ready`).
5. Old containers removed only after success → zero session loss.

Kubernetes is optional; Docker Compose keeps things simple today.

---

## 4. CI/CD Pipeline (GitHub Actions)

### High-Level Flow

```
git push
  ↓
GitHub Actions
  ↓
pnpm lint • pnpm test • pnpm typecheck
  ↓
pnpm build (Next.js standalone)
  ↓
docker build (multi-stage) → push to GHCR
  ↓
SSH → Hetzner → docker compose pull/up
  ↓
Health check & smoke tests
  ↓
Slack notification (success/failure)
```

**Zero downtime** via Traefik health checks, rolling restarts (`--no-deps app`), blue/green container names, and optional canary labels.

### GitHub Actions Workflow (`.github/workflows/deploy-main-app.yml`)

```yaml
name: Deploy Main App to Hetzner

on:
  push:
    branches: [main]
  workflow_dispatch:

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: dealscale/main-app

jobs:
  build_and_deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: 20

      - name: Install pnpm
        run: npm install -g pnpm

      - name: Install dependencies
        run: pnpm install --frozen-lockfile

      - name: Lint & type-check
        run: pnpm biome check && pnpm typecheck

      - name: Run tests
        run: pnpm test --if-present

      - name: Build app
        run: pnpm build

      - uses: docker/setup-buildx-action@v3

      - uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - uses: docker/build-push-action@v5
        with:
          push: true
          tags: |
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:latest
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}

      - name: Deploy to Hetzner
        uses: appleboy/ssh-action@v1.0.3
        with:
          host: ${{ secrets.HETZNER_HOST }}
          username: ${{ secrets.HETZNER_USER }}
          key: ${{ secrets.HETZNER_SSH_KEY }}
          script: |
            cd /srv/dealscale
            docker compose pull app
            docker compose up -d --no-deps app

      - name: Smoke test
        run: |
          sleep 10
          curl -fsS https://app.dealscale.io/api/health
          curl -fsS https://app.dealscale.io/login

      - name: Notify Slack
        if: always()
        uses: rtCamp/action-slack-notify@v2
        with:
          slack_webhook: ${{ secrets.SLACK_WEBHOOK }}
          message: "Hetzner deploy: ${{ job.status }} — ${{ github.sha }}"
```

### Rollback Step (optional)

Add `infra/rollback.sh` on the server:

```bash
#!/usr/bin/env bash
set -euo pipefail
cd /srv/dealscale
docker compose rollback app || docker compose up -d app@previous
```

Then append to workflow:

```yaml
  - name: Rollback
    if: failure()
    uses: appleboy/ssh-action@v1.0.3
    with:
      host: ${{ secrets.HETZNER_HOST }}
      username: ${{ secrets.HETZNER_USER }}
      key: ${{ secrets.HETZNER_SSH_KEY }}
      script: |
        cd /srv/dealscale
        ./infra/rollback.sh
```

---

## 5. Global Delivery (Cloudflare)

- Cloudflare proxy in front of Hetzner reduces latency 80–90% by caching static JS/CSS/fonts and ISR pages.
- Edge routing handles redirects, bot filtering, analytics.
- Hetzner only serves SSR + API hits; Cloudflare handles the rest.

DNS flow: `app.dealscale.io → Cloudflare Proxy → Hetzner Floating IP → Traefik → Containers`.

---

## 6. Server Bootstrap Commands

```bash
sudo apt update && sudo apt install -y docker.io docker-compose
curl -L https://traefik.io/install.sh | sudo bash
sudo usermod -aG docker deploy
# install exporters + observability stack
./scripts/install-node-exporter.sh
./scripts/install-prometheus.sh
./scripts/install-grafana.sh
./scripts/install-loki.sh
```

Ensure `/srv/dealscale` has correct permissions and `.env` files are readable only by the deploy user.

---

## 7. Secrets Management

Options (prefer per environment):
- Cloudflare Zero Trust Tunnel secrets.
- Doppler or 1Password Secrets Automation.
- Encrypted `.env` files (ansible-vault, sops).

Inject secrets at container runtime (Traefik + app + api) so images stay portable.

---

## 8. Scaling Strategy

- **Horizontal app scaling:** add Hetzner node, update Compose with additional replicas; Traefik + Cloudflare handle load balancing. Floating IPs enable failover.
- **Vertical scaling:** upgrade VM CPU/RAM/SSD for bursty AI workloads.
- **Database scaling:** isolate Postgres to dedicated instance, enable read replicas for analytics, schedule backups via Supabase or pgBackRest.
- **Cache/event scaling:** run Redis/Valkey cluster and Pulsar partitions based on queue throughput.

---

## 9. Health Checks & Telemetry

- App readiness: `/api/ready` (SSR + API handshake).
- Backend health: `/healthz` (FastAPI, DB, Redis checks).
- Prometheus scrape Traefik + app + backend.
- OpenTelemetry spans forwarded to Grafana Tempo / Jaeger.
- Dashboards: latency, error %, cache hit rate, queue depth, GPU usage (if applicable).

---

## 10. Comparison vs Vercel

| Requirement | Vercel | Hetzner (this plan) |
| --- | --- | --- |
| Latency to backend | ❌ High | ✅ 0.3 ms LAN |
| Cost | ❌ High | ✅ Predictable, low |
| API rate limits | ❌ Strict | ✅ None |
| GPU / AI workloads | ❌ Unsupported | ✅ Supported |
| Observability | ❌ Limited | ✅ Full stack |
| Custom workers | ❌ Hard | ✅ Native |
| Multi-agent orchestration | ❌ Painful | ✅ Same network |

**Conclusion:** keep the production app beside the backend on Hetzner; Cloudflare handles global delivery while you retain full control and better economics.

---

## 11. Dockerfile (Multi-Stage)

```
# Stage 1: build
FROM node:20-alpine AS builder
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN npm install -g pnpm && pnpm install --frozen-lockfile
COPY . .
RUN pnpm build

# Stage 2: runtime
FROM node:20-alpine
ENV NODE_ENV=production
WORKDIR /app
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json .
COPY --from=builder /app/node_modules ./node_modules
EXPOSE 3000
CMD ["pnpm", "start"]
```

Push this image to GHCR (`ghcr.io/dealscale/main-app:SHA`).

---

## 12. Production docker-compose.yml (Hetzner)

```
version: "3.9"

services:
  app:
    image: ghcr.io/dealscale/main-app:latest
    container_name: dealscale-app
    restart: always
    env_file: .env.production
    networks: [web]
    labels:
      - traefik.enable=true
      - traefik.http.routers.dealscale-app.rule=Host(`app.dealscale.io`)
      - traefik.http.routers.dealscale-app.entrypoints=websecure
      - traefik.http.routers.dealscale-app.tls.certresolver=letsencrypt
      - traefik.http.services.dealscale-app.loadbalancer.server.port=3000
    healthcheck:
      test: ["CMD", "wget", "--spider", "-q", "http://localhost:3000/api/health"]
      interval: 10s
      timeout: 5s
      retries: 5

networks:
  web:
    external: true
```

Traefik handles TLS, certificates, and canary routing via labels like `traefik.http.middlewares.canary91.weight`.

---

## 13. Smoke Tests & Canary Releases

- **Smoke tests:** `curl -fsS https://app.dealscale.io/login` or Playwright headless spec to ensure critical flows render.
- **Canary:** deploy duplicate service `app-canary` with `traefik.http.routers.dealscale-app-canary.middlewares=weight@file` to send 10% traffic until metrics are green. Promote by retagging `latest`.

---

## 14. Automation & Agents

- **Git-Agent:** prepares PRs and ensures pipeline config matches `_docs/front_end_best_practices/_ci-cd`.
- **DevOps-Agent:** edits workflow files + Docker manifests.
- **QA-Agent:** triggers Playwright smoke suite post-deploy.
- **Safety-Agent:** monitors Prometheus SLO dashboards; if error budget exceeded, triggers rollback script.

All steps log to Grafana + Slack for auditability.

