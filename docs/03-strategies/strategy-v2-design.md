# Strategy V2 Implementation Approach

**Status:** Design baseline; code implementation awaits a populated C2 runtime and pinned Hummingbot Core version.

Official references:

- https://hummingbot.org/strategies/v2-strategies/
- https://hummingbot.org/strategies/v2-strategies/controllers/
- https://hummingbot.org/strategies/v2-strategies/executors/
- https://hummingbot.org/strategies/scripts/
- https://hummingbot.org/strategies/v2-strategies/walkthrough-controller/

## Correct component roles

- **Executors** perform bounded order workflows with their own lifecycle.
- **Scripts** are StrategyV2Base entry points for simple experiments and prototypes.
- **Controllers** are reusable, configurable, production-oriented strategy modules.
- **v2_with_controllers.py** is the launcher that loads one or more controller configurations.
- **MarketDataProvider** supplies order book, trades and candle data.

New production strategy families should normally be implemented as controllers orchestrating official executors, not as six independent trading engines.

## Shared C2 services

All six requested arbitrage families should reuse:

1. Instrument and venue registry.
2. Market-data quality and freshness service.
3. Depth-adjusted quote/VWAP calculator.
4. Directed conversion graph with venue/account/network identity.
5. Fee, gas, slippage and settlement-cost estimator.
6. Independent risk authorization.
7. Execution journal, idempotency and reconciliation.
8. Treasury ledger and allocation policy.

## Requested strategy families

| Family | Required execution model | Main constraint |
|---|---|---|
| Global fiat/base asset | Verified sequence of actual tradable markets | Fiat reference prices are not executable edges |
| CEX–CEX | Pre-funded inventory and coordinated orders | Not atomic; transfer is separate rebalancing |
| DEX–DEX | Gateway quotes and supported on-chain execution | Gas, MEV, price impact, confirmations |
| CEX–DEX | Pre-funded exchange and wallet inventories | Settlement and leg mismatch |
| Triangular | Three or more executable markets returning to start asset | Fees, depth and precision on every leg |
| Multi-venue/multi-hop | Bounded graph search and coordinated executors | Hop count, stale quotes, recovery complexity |

## Gateway boundary

Gateway is the official DEX middleware and should be the preferred interface for supported networks, protocols, swaps and liquidity operations. It does not make cross-venue settlement atomic. Atomicity is possible only within a single transaction on a chain when the router/contract path supports it.

## Risk authorization

Before executor creation or order submission, require:

- instrument and connector allowlist match
- account and network authorization
- fresh market data and valid order-book sequence
- executable depth for intended size
- minimum order and precision checks
- fee/gas/slippage-inclusive expected net return
- reserved inventory and exposure limits
- route expiry and venue/RPC health
- loss limits and emergency-stop state

A positive estimate is not a guarantee of positive realized P&L. Risk rejection is final and cannot be overridden by an LLM, Telegram, dashboard, or MCP action.

## Implementation sequence

1. Confirm Core version and inspect existing V2 examples/controllers/executors.
2. Define typed instrument, route, quote, cost and authorization models.
3. Write unit/property tests for graph validity, precision, fee math and risk invariants.
4. Implement read-only scanner and replay fixtures.
5. Add one controller family at a time, reusing executors where supported.
6. Add paper/replay and failure-injection tests.
7. Add execution journal and reconciliation before live-order workflows.
8. Require independent live-readiness approval.

Do not assume a documented path exists unchanged in every release. Inspect the pinned source tree before coding against it.
