# C2 Initial Architecture

**Status:** Proposed baseline; subject to compatibility verification against pinned upstream releases.

## Component boundaries

| Component | Responsibility | Boundary |
|---|---|---|
| Hummingbot Core / workers | Connector operation, strategy execution, orders and executors | No LLM in the execution hot path |
| Hummingbot API | Authenticated control plane, bot lifecycle, persistence and event access | Private network only |
| Gateway | Blockchain and DEX protocol middleware | Wallet secrets remain inside protected runtime |
| Condor | Agent supervision, routines, Telegram and operator dashboard | Agent actions are proposals until deterministic authorization |
| C2 risk service | Route validation, limits, authorization decisions and durable policy | Cannot be overridden by agent or UI |
| C2 market registry | Venue/instrument identity, normalized metadata and market-data quality | Only verified executable markets qualify |
| C2 opportunity scanner | Depth-aware route simulation and cost calculation | Read-only until separately authorized |
| Treasury ledger | Inventory, reservations, realized/unrealized P&L and approvals | Trading agents cannot set withdrawal destinations |
| Operations | Monitoring, backups, release controls and recovery | No unsupervised destructive repairs |

## Deployment topology

Initial single-operator topology:

- Condor and Hummingbot API deployed using the official deploy workflow.
- API, PostgreSQL and EMQX remain loopback-bound or privately networked.
- Tailscale is used for remote operator access where hosts differ.
- Gateway is managed through the API where supported by the pinned release.
- C2-specific services are added only when a documented gap exists.
- Coolify and a VPS are optional later stages, not prerequisites for local validation.

## Strategy design

All six requested arbitrage families share common services:

1. Venue and instrument registry.
2. Market-data freshness and sequence validation.
3. Executable quote and depth/VWAP calculation.
4. Directed conversion graph.
5. Fee, gas, slippage and settlement-cost model.
6. Independent risk authorization.
7. Durable execution journal and reconciliation.
8. Treasury accounting.

A graph node represents an asset held in a specific venue, account, network and settlement domain. A cross-venue transfer is not an instantaneous or atomic conversion edge.

## Execution invariants

- No order without a valid, authorized connector and instrument.
- No order using stale or sequence-invalid market data.
- No order without available, reserved inventory.
- No approval based only on last-traded prices or headline spread.
- No agent can override a risk rejection.
- No duplicate submission after uncertain API outcomes; reconcile before retry.
- Non-atomic legs require explicit partial-fill and hedge/recovery policy.
- Live trading remains disabled until a separate readiness approval.

## Cost and credit controls

- Prefer upstream functionality over custom services.
- Share market-data subscriptions and route calculations.
- Use deterministic code for repetitive arithmetic and validation.
- Use LLM calls for bounded research, diagnosis, summaries and supervised proposals.
- Apply bounded queues, caching TTLs, polling intervals and concurrency.
- Add Redis only after measuring a shared-state requirement.
- Keep paper trading and replay separate from production credentials.

## Decisions still open

- Exact compatible Condor, API, Core and Gateway releases.
- Local versus VPS deployment and actual VPS resource budget.
- Which exchanges, accounts, chains and instruments are legally and operationally eligible.
- Supported connector/order-type coverage for each strategy family.
- Whether any additional C2 dashboard is necessary beyond Condor.
- Which current MCP interface is maintained and supported.
