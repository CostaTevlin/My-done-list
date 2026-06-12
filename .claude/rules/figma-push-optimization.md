# Figma push — performance rules

These apply any time you're pushing designs to Figma via the official Figma MCP connector (`use_figma`). Validated in flo-design-hackathon; claimed ~50% wall-clock + token reduction.

## Three hard rules

1. **Parallel fan-out, never sequential.** Build + verify the **base** frame once, then emit all variant clone calls as **N `use_figma` calls in a single assistant message** so they run concurrently. Never clone one-by-one across turns. Never loop `setCurrentPageAsync` inside one script — split per page/frame and fan out.

2. **≤10 logical ops per `use_figma` call.** A logical op = create a node + set its props + parent it. Build top-down: skeleton with `placeholder=true` first, then fill each section in its own call. `use_figma` is **atomic** — a failed script re-runs in full, so big scripts are expensive on every retry.

3. **Screenshot the base ONCE, not every clone.** `get_screenshot` is the most expensive rate-limited read. Validate the base visually once; use `get_metadata` (cheaper, indexed) for structural checks on clones. Reserve per-frame screenshots for genuinely new layouts only.

## Discovery

- Prefer hardcoded component/token keys over re-running `search_design_system` / `get_libraries` / `get_variable_defs` — those are **rate-limited reads**.
- `use_figma` **writes are exempt from rate limits** — lean on them instead of reads.

## Efficient API patterns

- `node.query()` / `node.set()` / `figma.createAutoLayout()` — cut round trips.
- `figma.skipInvisibleInstanceChildren = true` + `findAllWithCriteria` / `getNodeByIdAsync` — indexed, hundreds of times faster than `findAll` predicate scans.
- **20 KB output cap per `use_figma` call** — return only node IDs/counts, never full node blobs.
