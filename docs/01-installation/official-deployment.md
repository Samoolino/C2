# Official Deployment Workflow

**Research checked:** 2026-11-09  
**Status:** Verified against current official deployment documentation and upstream repository README; not executed on the operator workstation.

## Recommended installation path

The current official getting-started path recommends Condor for agentic and multi-instance operations. The Hummingbot Deploy helper can install Condor and optionally Hummingbot API.

Official sources:

- https://hummingbot.org/installation/
- https://hummingbot.org/hummingbot-api/installation/
- https://condor.hummingbot.org/getting-started/installing
- https://github.com/hummingbot/deploy
- https://github.com/hummingbot/condor
- https://github.com/hummingbot/hummingbot-api
- https://hummingbot.org/gateway/installation/

## Safety precondition

Do not run the installer until the read-only workstation preflight has been reviewed. Use a new empty parent directory and confirm the intended Compose project, ports, volumes and repository paths do not collide with existing installations.

The helper script is mutable on its upstream branch. For a reproducible production installation, first download and inspect the script, record its commit SHA, and run a reviewed copy. Do not blindly pipe a moving branch into a privileged shell in a production environment.

## Official Condor installer

After preflight approval, the upstream quickstart command is:

```bash
curl -fsSL https://raw.githubusercontent.com/hummingbot/deploy/main/setup.sh | bash
```

The installer prompts for Telegram or local mode, and can optionally deploy Hummingbot API. Local mode is login-less and must remain loopback-only; do not expose it to LAN or public networks.

## API-only installer

For a separately hosted API:

```bash
curl -fsSL https://raw.githubusercontent.com/hummingbot/deploy/main/setup.sh | bash -s -- --hummingbot-api
```

The official API Docker deployment starts the API, PostgreSQL and EMQX. It prompts for API authentication, a config encryption password, and optional Tailscale configuration.

If setup completes but services are not running, the upstream README documents:

```bash
cd hummingbot-api
make setup
make deploy
make doctor
```

Do not run `docker compose down -v` as a generic troubleshooting step. It deletes persistent volumes and is not part of the clean-install or recovery procedure.

## Network and security defaults

- API port 8000 binds to loopback by default.
- PostgreSQL port 5432 and EMQX broker port 1883 are loopback-bound by default.
- EMQX Dashboard is loopback-only and uses a distinct admin password.
- Remote access should use Tailscale/MagicDNS, not a public API port.
- Do not expose unauthenticated Condor local mode.
- Use strong, unique API and config passwords; rotate any defaults.
- Never commit .env files, exchange keys, wallet seed phrases, private keys, or Tailscale auth keys.

## Gateway

When using the Condor/API quickstart, Gateway can be managed through Hummingbot API in supported releases. The API documentation describes a secured Gateway lifecycle with HTTPS and mutual TLS. Verify the pinned API/Gateway compatibility before enabling DEX execution.

Do not deploy a second standalone Gateway unless the chosen architecture or compatibility matrix requires it.

## Version pinning and reproducibility

Before production deployment, record:

- deploy repository commit SHA and setup script SHA-256
- Condor commit/tag and Python dependency lock
- Hummingbot API commit/tag and container image digests
- PostgreSQL and EMQX image digests
- Gateway package version and image digest
- Docker Engine and Compose versions
- Tailscale client/sidecar version

Do not treat `latest` as a production version pin. Verify release compatibility and rollback path before upgrading.

## Validation

Run the upstream `make doctor` and record its output with secrets redacted. Verify:

- API authenticated health check
- PostgreSQL health and persistence
- EMQX authentication and scoped topic ACL
- Condor process and dashboard bind address
- Tailscale peer and Serve status, if configured
- Gateway TLS/mTLS health, if enabled
- restart and reboot persistence

Current C2 status: NOT RUN — workstation access is not available in this execution context.
