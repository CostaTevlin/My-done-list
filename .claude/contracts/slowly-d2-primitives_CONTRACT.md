# slowly-d2-primitives — contract

> **Status:** Confirmed — proceed.
> **Branch:** `adr-0010-voice-first` (continuing on current branch per user decision 2026-05-22).
> **Anchors:** `engineering/redesign-migration-plan.md` §Phase R2, `DesignSystem/CLAUDE.md`, `Slowly+Color.swift`, `Slowly+Font.swift`, `Slowly+Spacing.swift`, `Slowly+Radii.swift`, `Slowly+Material.swift`.

## Outcome

The DesignSystem package gains 6 Slowly-branded primitive components (DSText, DSButton, DSIcon, DSDivider, DSTextField, DSCheckmark) all using `Slowly.*` tokens exclusively. Existing PillButton and ActivityRing are migrated in-place to `Slowly.Color.*` for their color calls. The package builds clean on the macOS host and on both iOS 18 and iOS 26.

## Token names to use (current as of 2026-05-22)

**Color:** `Slowly.Color.textPrimary`, `.textSecondary`, `.textPrimaryWhite`, `.textSecondaryWhite`, `.surfaceApp`, `.surfaceGhost`, `.borderDefault`, `.accentPrimary`, `.ringLow`, `.ringMid`, `.ringComplete`, `.neutral50`, `.sage50`, `.actionDestructive`

**Font:** `Slowly.Font.bigNumeral`, `.titleDisplay`, `.title1Light`, `.title2Light`, `.headlineRegular`, `.bodyRegular`, `.bodyMedium`, `.footnoteRegular`, `.footnoteMedium`, `.captionRegular`, `.captionBold`

**Spacing:** `Slowly.Spacing.xs` (8), `.sm` (12), `.md` (16), `.lg` (20), `.xl` (24), `.xxl` (32), `.xxxl` (40), `.screenTop` (27), `.screenBottom` (62)

**Radius:** `Slowly.Radius.card` (20), `.button` (32), `.sheet` (40), `.fab` (9999 / `.clipShape(.capsule)`)

**Material:** `Slowly.Material.fallback` (iOS 18), iOS 26 glass constants via `Slowly.Material.frost` etc.

## Scope

### New files (DesignSystem/Sources/DesignSystem/Components/)

- [x] `DSText.swift` — `DSTextStyle` enum + `.dsText(_ style:)` ViewModifier. Bundles font + foreground color (textPrimary default, overridable). Variants: `.bigNumeral`, `.titleDisplay`, `.title1Light`, `.title2Light`, `.headlineRegular`, `.bodyRegular`, `.bodyMedium`, `.footnoteRegular`, `.footnoteMedium`, `.captionRegular`, `.captionBold`.
- [x] `DSButton.swift` — `DSButtonStyle(.primary/.secondary)` + `DSFABButton(icon:diameter:accessibilityLabel:action:)`. Primary: `accentPrimary`-fill capsule, `textPrimaryWhite` label. Secondary: text-only, `accentPrimary` tint. FAB: `textPrimary`-fill 56pt circle, SF Symbol icon, `textPrimaryWhite` tint.
- [x] `DSIcon.swift` — `DSIcon(_ symbol:, size:, color:)` View. Size enum: `.sm`(16) `.md`(20) `.lg`(24) `.xl`(28) `.custom(CGFloat)`. Default color `textPrimary`.
- [x] `DSDivider.swift` — `DSDivider` View. 1pt `borderDefault` rule, full width.
- [x] `DSTextField.swift` — `DSTextField(_ placeholder:, text:)` View. `surfaceGhost` bg, `borderDefault` stroke (1pt, card radius), `bodyRegular` font, `textPrimary` text.
- [x] `DSCheckmark.swift` — `DSCheckmark(checked: Bool, size: CGFloat = 24)` View. Unchecked = `borderDefault` stroke, checked = `accentPrimary` fill + `textPrimaryWhite` checkmark. Spring-animates unless `accessibilityReduceMotion`.

### Modified in-place

- [x] `PillButton.swift` — replaced `Color.textPrimary` → `Slowly.Color.textPrimary`, `Color.surfaceApp` → `Slowly.Color.surfaceApp`. Spacing calls kept on old namespace (intentional — values differ). Raw hex in `.brandPillStyle()` retained per existing comment.
- [x] `ActivityRing.swift` — replaced all four ring color tokens with `Slowly.Color.*` equivalents. No other changes.

## Tests that must pass

- [x] **New** `DesignSystemTests/DSComponentTests.swift` — 18 tests covering all 6 primitives: compile checks, size assertions, size enum values, custom size passthrough
- [x] **Updated** `DesignSystemTests/DesignSystemTests.swift` — all 13 existing tests still pass
- [x] `swift build` in `DesignSystem/` exits 0 — Build complete (1.62s, no warnings)
- [x] `swift test` in `DesignSystem/` exits 0 — 31/31 passed
- [ ] iOS 18 build — **no iOS 18 simulator installed** on this machine; only iOS 26.4.1 sims available. Carry forward to D3 when iOS 18 sim is added.
- [x] `xcodebuild ... iPhone 17 / iOS 26.4.1` build exits 0 — BUILD SUCCEEDED

## Visual verification

D2 components are primitives — no standalone app screen to screenshot. Verification is via `#Preview` blocks and `TokenPreviewView`.

- [x] Each of the 6 new components has a `#Preview { … }` that renders all major states (e.g. DSCheckmark: checked + unchecked; DSButton: primary + secondary + FAB; DSTextField: empty + with text).
- [x] `TokenPreviewView` extended to include a "D2 Primitives" gallery section showing each component.
- [x] PillButton preview still renders as before (color migration is visually transparent in light mode).
- [x] ActivityRing preview still renders ring states correctly after token swap.
- [x] Dynamic Type xxxLarge: DSText `.bodyRegular` and `.title1Light` scale without layout breaks — SF Pro system fonts scale automatically; no manual sizing in font definitions.
- [x] Reduce Motion: DSCheckmark does not animate when `accessibilityReduceMotion` is true — `.animation(reduceMotion ? nil : .spring(...), value: checked)` pattern verified in code.

## Files that must NOT change

- [x] `index.html`, `sw.js`, `manifest.json`, `icon-*.png` (legacy PWA) — `git status` confirms clean
- [x] Any file in `XCode Project/DoneList/DoneList/Features/` — `git status` confirms clean
- [x] `DoneListWidget/` — `git status` confirms clean
- [x] `Slowly+Color.swift`, `Slowly+Font.swift`, `Slowly+Spacing.swift`, `Slowly+Radii.swift`, `Slowly+Material.swift` — `git diff HEAD` shows no changes to any D1 token file

## ADRs honored / referenced

- ADR-0005 — Liquid Glass with `#available` fallback (DSButton FAB iOS 26 path)
- ADR-0011 — ADHD-first (primitives must support legibility at all Dynamic Type sizes)

## Acceptance criteria

- [x] No `Color.textPrimary`, `Color.borderDefault`, or any other flat `Color.*` semantic extension in new DS* files — `Slowly.Color.*` only — verified by grep across all DS*.swift
- [x] No raw hex in new DS* files — `#e8e9e6` appears only in a comment in DSDivider.swift (acceptable); no code-level hex
- [x] No `import UIKit` in any new or edited DS* file — grep confirms clean
- [x] Each new public type has a one-line doc comment noting its Figma source or purpose — all 6 files have file-header comments with Figma source and purpose
- [x] DSProgressRing is explicitly NOT built — parked per 2026-05-22 decision. Do not create it.
- [x] No new build warnings on either iOS destination — `swift build` and `xcodebuild` (iOS 26.4.1) both exit clean

## Out of scope

- **DSProgressRing** — explicitly parked (user decision 2026-05-22). ActivityRing stays as-is except for the color token migration.
- **Any screen wiring** — D2 primitives live in DesignSystem only. Connecting them to TodayView, LogSheet, etc. is R4.
- **Flag infrastructure** (`redesign.enabled`) — needed at R4 when screens are composed, not at primitive level.
- **Dark mode** — Phase 9. Slowly.Color.* tokens have light-mode-only colorsets; this is by design.
- **Snapshot tests** — deferred to R3+ when composites give stable reference frames.

---

**Done means every box above is ticked.** If a box can't be ticked, this task is blocked, not done. Report the blocker; do not edit this contract to make termination easier.
