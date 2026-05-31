# Regenerate navBarHero backdrop — contract

## Outcome

The `AdaptiveHero` backdrop matches Figma node `111:8965` (and stays consistent with the existing `112:9933` empty-state spec) by replacing the placeholder PNG with a new watercolour asset and adding the layered composition natively in SwiftUI: a concave arc mask (Rectangle − Ellipse), a blurred dark glow ellipse behind the photo for depth, and an inner shadow on the arc edge. The arc, glow, and inner shadow now apply to **all three states** (`.today`, `.reflect`, `.empty`) — a deliberate visual change for the populated Today and Reflect screens. Photo opacity is constant `1.0`. The watercolour itself stays raster (one source PNG), so ADR `redesign-techdebt-001` remains honored — only composition chrome is native, not the illustration.

## Approach summary

- **Raster:** one `navBarHero` imageset (existing path reused), three new PNGs (@1x / @2x / @3x).
- **Native SwiftUI additions inside `AdaptiveHero.botanicalLayer`, applied to every state:**
  - Concave arc shape: `Rectangle − Ellipse` (Figma 111:8965 / 112:9933). Same curve geometry for all states; the shape adapts naturally because it sizes from its frame. Arc depth is **height-relative** (`rect.height * 22/300 ≈ 7.3%`), matching the existing 22pt depth at the 300pt empty-state height while reducing proportionally to ~14.7pt at the 200pt today/reflect height.
  - Dark glow layer behind the photo: large ellipse filled with `Slowly.Color.textPrimary`, `.blur(radius: 54)`, `.opacity(0.10)`.
  - Inner shadow on the arc edge: `rgba(0,0,0,0.25)`, offset `(0, -5)`, radius `4`. Rendered over the photo via the arc shape.
- **Opacity:** photo at constant `1.0` for all states.
- **API:** no change to `AdaptiveHero`'s public surface (`HeroState`, `init`, call sites stay identical).
- **External consumer cleanup:** the existing `ConcaveArcBottomShape` private struct and the `.mask { ConcaveArcBottomShape() }` call in `EmptyTodayScreen.swift` become redundant — they get removed in the same change.

## Preconditions (must be true before any code changes)

- [ ] User replaces the three PNGs in `DesignSystem/Sources/DesignSystem/Resources/Assets.xcassets/navBarHero.imageset/`:
  - `navBarHero-imageset.png` (@1x)
  - `navBarHero-imageset 1.png` (@2x)
  - `navBarHero-imageset-3x.png` (@3x)
- [ ] `Contents.json` is left unchanged. No second imageset is created.

Until the PNG drop is confirmed (different mtimes / byte sizes from the May 24 placeholders), this task is **blocked**. No `.swift` edits are made.

## Implementation steps (only after preconditions are satisfied)

- [ ] In `AdaptiveHero.swift`, add a `private struct ConcaveArc: Shape` with a height-relative arc depth (default ratio `22 / 300`). The shape mirrors the path approach already proven in `EmptyTodayScreen.ConcaveArcBottomShape`: rect top + sides, quadratic-curve bottom dipping `arcDepth` above the bottom edge.
- [ ] Rewrite `AdaptiveHero.botanicalLayer` as a `ZStack` with three sub-layers, bottom-to-top:
  1. Dark glow ellipse: `Ellipse().fill(Slowly.Color.textPrimary).blur(radius: 54).opacity(0.10)`, sized large enough to spread behind the photo per Figma `111:8965`.
  2. `Image("navBarHero", bundle: .module).resizable().scaledToFill().opacity(1.0)` clipped by the `ConcaveArc` shape.
  3. Inner-shadow overlay: rendered via `ConcaveArc` stroke / fill technique that puts the shadow only inside the arc edge (final SwiftUI pattern decided at code time — strokeBorder + offset + blur + mask, or `ShapeStyle.shadow(.inner(...))`). Color: `Color.black.opacity(0.25)`, offset `(0, -5)`, radius `4`.
- [ ] Preserve the existing height behaviour (200pt for `.today` / `.reflect`, 300pt for `.empty`) and the `.allowsHitTesting(false) + .accessibilityHidden(true)` modifiers.
- [ ] In `EmptyTodayScreen.swift`:
  - Remove the `.mask { ConcaveArcBottomShape() }` modifier on the `AdaptiveHero(state: .empty)` instance.
  - Delete the now-unused `private struct ConcaveArcBottomShape: Shape` declaration at the bottom of the file.
  - Update the top-of-file comment block (lines 4–10) to reflect that the arc is now produced inside `AdaptiveHero`, not externally.
- [ ] Update the file-header comment block at `AdaptiveHero.swift:4-10` to reflect: hybrid composition (raster photo + native arc + native glow + native inner shadow), Figma `111:8965` / `112:9933` parity, applied to all states, ADR `redesign-techdebt-001` still satisfied.

## Tests that must pass

- [ ] `swift test` from `DesignSystem/` exits 0 — package builds, all existing tests stay green.
- [ ] `xcodebuild ... -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=18.x' build` — iOS 18 baseline compiles clean (no new warnings).
- [ ] `xcodebuild ... -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=26.x' build` — iOS 26 path compiles clean (no new warnings).
- [ ] `xcodebuild ... test` on the `DoneList` scheme exits 0 — full suite green, including `D3CompositeTests.swift` AdaptiveHero tests.

## Visual verification

Required on both iOS 18 and iOS 26 per `liquid-glass.md`. Both code paths must work because `r4TodayEnabled` (default `false`) gates the R4 screens and the legacy path also uses `AdaptiveHero`.

- [ ] Screenshot — Today populated (count > 0) on iPhone 15 Pro / iOS 18: backdrop has the concave arc at the bottom (~14.7pt dip at 200pt height), glow visible behind photo, inner shadow visible along arc edge, photo at full opacity. **This is a deliberate visual change vs current behavior** — flag this for design review.
- [ ] Screenshot — Today populated on iPhone 16 Pro / iOS 26: same as above, no Liquid Glass regression.
- [ ] Screenshot — Reflect (if reachable) on both simulators: same arc + glow + shadow at the 200pt height.
- [ ] Screenshot — Empty state on iPhone 15 Pro / iOS 18: backdrop has the concave arc (~22pt dip at 300pt height — matches what the screen looked like before this change, since the external mask was already doing this).
- [ ] Screenshot — Empty state on iPhone 16 Pro / iOS 26: same.
- [ ] Side-by-side comparison vs Figma `111:8965` (today/reflect) and `112:9933` (empty) — no visible delta in arc shape, glow extent, inner shadow direction, or photo opacity.
- [ ] VoiceOver: backdrop remains `accessibilityHidden(true)`. Hero a11y label unchanged.
- [ ] Dynamic Type xxxLarge: hero text doesn't collide with the backdrop or the arc.
- [ ] Reduce Motion: no impact — backdrop is not animated.

## Files that must NOT change

- [ ] `index.html`, `sw.js`, `manifest.json`, `icon-*.png` at repo root (legacy PWA — `legacy-pwa.md`).
- [ ] `Hero.swift`, `HeroBlock.swift` (deprecated, out of scope).
- [ ] `AdaptiveHero` public API — `HeroState` enum, init signature, call sites stay identical.
- [ ] `Contents.json` inside `navBarHero.imageset/`.
- [ ] Any `Slowly.*` token files. This task only *consumes* `Slowly.Color.textPrimary`.
- [ ] `TodayScreen.swift`, `TodayScreen_New.swift`, `AddEntrySheet_New.swift`, `RootTabView`, `BrandTabBar`, FAB nav shell — none of these change. The AdaptiveHero call site signatures stay identical.

## Files that DO change

- `DesignSystem/Sources/DesignSystem/Components/AdaptiveHero.swift` — add `ConcaveArc` shape, rewrite `botanicalLayer`, update header comment.
- `DesignSystem/Sources/DesignSystem/Resources/Assets.xcassets/navBarHero.imageset/` — three PNG replacements (user-driven precondition).
- `XCode Project/DoneList/DoneList/Features/Today/EmptyTodayScreen.swift` — remove `.mask` call, delete `ConcaveArcBottomShape` struct, update header comment.

## ADRs honored / referenced

- `redesign-techdebt-001 — Deferred native-SwiftUI rebuild of botanical illustration` (Accepted 2026-05-23). Status preserved: the watercolour itself stays raster. The ADR defers vector-rebuilding the *illustration*; composition chrome (arc / glow / shadow) is not the illustration. No new ADR required. If implementation drifts toward replacing the raster, stop and write an amendment first.
- ADR-0010 (referenced by `EmptyTodayScreen.swift`). Not changed by this work.

## Acceptance criteria

- [ ] No new build warnings on either simulator.
- [ ] No hardcoded colour / spacing / radius values introduced (per `design-system.md`). The dark glow uses `Slowly.Color.textPrimary`; arc geometry and glow blur radius are composition primitives local to the component (not promoted to design tokens).
- [ ] Both `r4TodayEnabled = false` and `r4TodayEnabled = true` paths render the new backdrop correctly.
- [ ] `EmptyTodayScreen` empty-state visual is preserved (since the arc that used to live externally now lives internally — the user-facing result on `.empty` should be visually equivalent or improved).
- [ ] PR description links to this contract and references ADR `redesign-techdebt-001`. Calls out the populated-Today / Reflect arc as a deliberate design change.
- [ ] Phase R4 noted in PR description (per `git-pr.md`).
- [ ] Old placeholder PNGs fully replaced; imageset folder still contains exactly three PNGs + `Contents.json`.

## Out of scope

- Full native SwiftUI rebuild of the watercolour itself (still deferred per ADR `redesign-techdebt-001`).
- Per-state opacity variants. One value (1.0) across all states.
- Per-state arc depth tuning beyond the height-relative ratio. If design wants different arc *shapes* per state, that's a follow-up.
- Dark mode tuning of the backdrop (Phase 9).
- Any change to `Hero.swift` or `HeroBlock.swift`.
- Widget-target validation — `AdaptiveHero` is app-only.

---

**Done means every box above is ticked.** If a box can't be ticked, this task is blocked, not done. Report the blocker; do not edit this contract to make termination easier.
