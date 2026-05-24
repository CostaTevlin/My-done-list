# ADR redesign-techdebt-001 — Deferred native-SwiftUI rebuild of botanical illustration

> **Status:** Accepted  
> **Date:** 2026-05-23  
> **Supersedes:** (none)  
> **Sync to vault:** Copy to `decisions/` in Obsidian before next PR.

---

## Context

The Slowly redesign (D3 Phase R3) introduces `AdaptiveHero` — a multi-state hero component used on the Today, Reflect, and Empty screens. Its visual centrepiece is a watercolour botanical illustration (`IMG_9961` in Figma, node 17:2491) that appears in the top portion of the screen behind the hero text content.

The illustration is a raster photograph/illustration asset in the Figma file. Reproducing it precisely in native SwiftUI would require either:

- Recreating the watercolour brush strokes as SwiftUI `Path`/`Canvas` vector shapes (~3–4 days), or  
- Sourcing or licensing an equivalent SVG botanical illustration and converting it to a SwiftUI `Shape` (~2 days + legal review).

D3 has a 4-day total budget. Spending half of it on one decorative illustration is not justified.

---

## Decision

Import the botanical illustration as a **static raster image asset** (`navBarHero.imageset`) at @2x and @3x PNG resolutions. `AdaptiveHero` loads it via `Image("navBarHero", bundle: .module)`.

The native-SwiftUI vector rebuild is **explicitly deferred** to a later phase (R6 or v2.0 scope, whichever comes first).

The `EmptyStateArrow` component (curved arrow + label in the empty state) was originally also flagged for asset import in the D3 plan. Upon Figma inspection it turned out to be simple enough (two SVG strokes + text) to build natively in SwiftUI via `Path`. It is therefore **not** deferred — it ships as native code in D3.

---

## Consequences

**Positive:**
- D3 ships on schedule.
- The asset can be swapped for a native rebuild in a future phase without any API change — `AdaptiveHero`'s public interface is state-driven, not image-driven.

**Negative:**
- The illustration does not respond to Dynamic Type, colour scheme overrides, or forced dark mode.
- Asset file size adds ~80–150 KB to the app bundle (acceptable for v1).
- If the illustration is updated in Figma, the asset must be manually re-exported.

**Mitigations:**
- The illustration is `.accessibilityHidden(true)` — purely decorative, no VoiceOver impact.
- The asset is marked `/* per ADR redesign-techdebt-001 */` at its call site so future engineers know a native rebuild is the long-term goal.

---

## Alternatives considered

| Option | Verdict |
|--------|---------|
| Native SwiftUI Path rebuild | Rejected — ~3d effort, not justified for a decorative element |
| SF Symbols botanical substitute | Rejected — no SF Symbol approximates a watercolour leaf cluster |
| Omit the illustration entirely for D3 | Rejected — it is the primary visual identity element of the screen header |
| SVG → SwiftUI Shape conversion tool | Rejected — tools exist but produce brittle code for organic shapes; legal review of source SVG needed |

---

## References

- Figma node: `17:2491` (hero component, Slowly-MVP file)  
- Contract: `.claude/contracts/d3-composites_CONTRACT.md`  
- Phase: D3 (R3 Composites)
