# C2 — Hummingbot Unified Trading Platform

C2 is the integration, operations, risk-control, and documentation layer around the official Hummingbot ecosystem.

## Upstream source of truth

- [Hummingbot Core](https://github.com/hummingbot/hummingbot)
- [Hummingbot API](https://github.com/hummingbot/hummingbot-api)
- [Gateway](https://github.com/hummingbot/gateway)
- [Condor](https://github.com/hummingbot/condor)
- [Hummingbot Deploy](https://github.com/hummingbot/deploy)
- [Official documentation](https://hummingbot.org/installation/)

The legacy [hummingbot/mcp](https://github.com/hummingbot/mcp) repository is archived; MCP integration must be based on currently maintained upstream interfaces and verified API capabilities.

## Operating principles

1. Preserve existing workstation installations and data.
2. Create a clean, isolated deployment before any migration.
3. Pin compatible upstream releases and image digests before production.
4. Keep APIs, databases, brokers, dashboards, and administration private.
5. Use official Hummingbot connectors, Strategy V2 components, executors, and Gateway wherever suitable.
6. Keep LLM reasoning outside latency-critical execution.
7. Enforce deterministic risk authorization independently of agents and user interfaces.
8. Default to read-only discovery and paper trading. Live trading, withdrawals, paid infrastructure, and destructive operations require separate approval.
9. Report evidence honestly: PASS, FAIL, NOT RUN, or BLOCKED.

## Current status

- Repository initialized as the clean C2 integration workspace.
- Upstream source repositories identified.
- Local WSL installation inventory: NOT RUN (no workstation terminal session available).
- Clean Hummingbot installation: NOT RUN.
- Cloud provisioning: NOT AUTHORIZED.
- Live trading: DISABLED.

## Documentation

See [docs/](docs/) for architecture, preflight, installation, security, strategy, and acceptance records.

## First workstation action

Run the read-only inventory script in a WSL terminal before installing or changing anything:

```bash
bash scripts/preflight-wsl.sh
```

Review its output and redact hostnames, usernames, IP addresses, and any identifying details before sharing. The script deliberately avoids printing environment variables, credential files, wallet data, or secret values.
