# D3 — Composites (Phase R3) — contract

> **Status:** Draft — confirm with Konstantin before coding starts (per `.claude/rules/contracts.md`).
> **Branch:** `D3-phase`
> **Anchors:** `engineering/redesign-migration-plan.md` §Phase R3, `DesignSystem/CLAUDE.md`, `Slowly+*.swift` token files, D2 primitives (`DS*.swift`).
> **Duration:** 4 days.

---

## Outcome

The DesignSystem package gains 9 new Slowly-token composite components covering rows, navigation chrome, the hero block, the week chart, voice capture, confirmation UI, and the sheet surface. Two Figma-sourced image assets (`NavBarHero`, `EmptyStateArrow`) are dropped into the asset catalog with a new ADR documenting the deferral of their native-SwiftUI rebuild. All new composites use `Slowly.*` tokens exclusively. The package builds clean on the macOS host and on both iOS 18 and iOS 26.

---

## Pre-flight

- [ ] Confirm clean branch: `git branch --show-current` → `D3-phase`, `git status` → clean.
- [ ] Re-read `DesignSystem/CLAUDE.md` source-of-truth chain before editing any token file.
- [ ] Confirm D2 test suite still green: `swift test` in `DesignSystem/` exits 0.

---

## Day 1 — Figma assets + ADR

### NavBarHero & EmptyStateArrow image assets

**Prerequisite (manual — Konstantin exports these):**

- Export `NavBarHero` from Figma at @2x (PNG) and @3x (PNG).
- Export `EmptyStateArrow` from Figma at @2x (PNG) and @3x (PNG).
- Drop into `DesignSystem/Sources/DesignSystem/Resources/Assets.xcassets/` as `navBarHero.imageset` and `emptyStateArrow.imageset`.
- Verify `Contents.json` references `filename@2x.png` and `filename@3x.png` correctly.

- [ ] `navBarHero.imageset` present in asset catalog with @2x + @3x entries.
- [ ] `emptyStateArrow.imageset` present in asset catalog with @2x + @3x entries.
- [ ] `swift build` still exits 0 after asset drop.

### ADR: redesign-techdebt-001

- [ ] **New file** `decisions/redesign-techdebt-001 — Deferred native-SwiftUI rebuild of NavBarHero and EmptyStateArrow.md`:
  - **Context:** NavBarHero and EmptyStateArrow require complex layered gradients / illustrated detail that would take ~3 days each to rebuild in native SwiftUI. Phase R3 timeline is 4 days total.
  - **Decision:** Import as static PNG image assets at @2x/@3x for Phase R3. Native rebuild deferred to a later redesign phase (R6 or v2.0).
  - **Consequences:** Asset is not responsive to Dynamic Type or color scheme overrides. Acceptable for Phase R3 scope. Must revisit before App Store submission if marketing requires vector fidelity.
  - **Alternatives considered:** Native SwiftUI rebuild (rejected — timeline), SF Symbols substitute (rejected — doesn't match Figma design).

---

## Days 1–2 — Row composites + nav chrome

### New files (DesignSystem/Sources/DesignSystem/Components/)

- [ ] **`EntryRow.swift`** — Single done-item row.
  - Props: `text: String`, `timestamp: String`, `isFirst: Bool`, `isLast: Bool`.
  - Layout: leading text body in `Slowly.Color.textPrimary` / `Slowly.Font.bodyRegular`, trailing timestamp in `Slowly.Color.textSecondary` / `Slowly.Font.captionRegular`.
  - Separator: `DSDivider` below unless `isLast == true`.
  - 44pt minimum touch target height.
  - Accessibility: element reads `"\(text), \(timestamp)"`.
  - `#Preview` with filled state, empty state, first/last variants.

- [ ] **`TimeOfDaySectionHeader.swift`** — Morning / Afternoon / Evening section label.
  - Props: `label: String` (e.g. `"Morning"`), `count: Int`.
  - Layout: `Slowly.Font.captionBold` label + `Slowly.Color.textSecondary`, `Slowly.Font.captionRegular` count badge.
  - No background — floats above list content.
  - `#Preview` for each time-of-day variant.

- [ ] **`NavBarPlain.swift`** — Minimal top navigation bar (no hero, no image).
  - Props: `title: String`, `trailingAction: (() -> Void)?`, `trailingIcon: String?`.
  - Layout: `Slowly.Font.headlineRegular` title centered; optional SF Symbol button trailing.
  - Background: `Slowly.Color.surfaceApp` (opaque, not glass — glass is the iOS 26 upgrade path, not in scope here).
  - `#Preview` with and without trailing action.

- [ ] **`TabBarMain.swift`** — Main floating tab bar.
  - Replaces `BrandTabBar.swift`'s role in D3 screens. Does NOT delete `BrandTabBar.swift` (still used in the app target; see Out of scope).
  - Props: `selection: Binding<Tab>`, `onLog: () -> Void`. `Tab` enum: `.today`, `.reflect`, `.more`.
  - Uses `Slowly.Color.*`, `Slowly.Spacing.*`, `Slowly.Radius.*` exclusively. No `Color.*` flat extension calls.
  - Active pill: `Slowly.Color.textPrimary`-fill capsule, icon + label `Slowly.Color.textPrimaryWhite`.
  - Inactive: icon + label `Slowly.Color.textSecondary`.
  - Log FAB: 60pt `Slowly.Color.textPrimary`-fill circle, `plus` SF Symbol `Slowly.Color.textPrimaryWhite`.
  - Reduce Motion: tab-switch animation removed.
  - `#Preview` light + dark, all three selection states.

---

## Day 3 — Screen-level composites

### New files (DesignSystem/Sources/DesignSystem/Components/)

- [ ] **`AdaptiveHero.swift`** — Multi-state animated hero (replaces earlier `HeroBigNumeral` plan).
  - States: `.today(date: String, count: Int, headline: String, subtitle: String)` · `.reflect(headline: String, subtitle: String)` · `.empty`.
  - Shared structure (VERTICAL, `Slowly.Spacing.sm` 12pt item spacing, fixed 345pt effective width):
    - Date label — `Slowly.Font.footnoteRegular`-equivalent (16pt SF Pro Medium), `Slowly.Color.textSecondary`.
    - Big numeral — `Slowly.Font.bigNumeral` (130pt Light), `Slowly.Color.textPrimary`. Uses `.contentTransition(.numericText)`. Hidden in `.reflect` and `.empty`.
    - Headline — `Slowly.Font.title1Light` (40pt Light, 125% LH), `Slowly.Color.textPrimary`. Text differs per state.
    - Subtitle — `Slowly.Font.bodyRegular`-equivalent (18pt Regular, 24pt LH), `Slowly.Color.textSecondary`. Hidden in `.empty`.
  - Botanical illustration (`navBarHero.imageset`) floats above content: 501×425 raster, FILL, masked + `.blur(radius: 27)` behind hero content. Exported from Figma (see ADR `redesign-techdebt-001`).
  - Empty state extras: plant illustration image (separate asset) + `EmptyStateArrow` below subtitle area.
  - Height is AUTO (SwiftUI auto-layout) — expands naturally as state changes.
  - State transitions: `withAnimation(.spring(duration: 0.4))` wrapping state changes. Reduce Motion: instant swap (no spring).
  - Accessibility group per state: today → `"\(count) things today. \(headline). \(subtitle)"`; reflect → `"Reflect. \(headline). \(subtitle)"`; empty → `"No wins yet."`.
  - This is a Slowly-token clean-room build; `HeroBlock.swift` and `Hero.swift` stay untouched.
  - `#Preview` for all three states.

- [ ] **`WeekBarChart.swift`** — 7-column weekly bar chart composite.
  - Decision: **hand-built** — composes 7 `ChartBar` instances in an `HStack`. No Charts framework dependency (saves an ADR + no new dep).
  - Props: `days: [WeekDay]` where `WeekDay = (label: String, count: Int, isToday: Bool)`.
  - Normalises bar fractions from `max(days.map(\.count), 1)` so all bars share the same scale.
  - Accessibility: `accessibilityElement(children: .combine)` wrapping the HStack; each bar gets its existing `ChartBar` accessibility label.
  - `#Preview` with 7-day sample data (varies across 0–8 count range).

- [ ] **`ConfirmationBlock.swift`** — Post-log confirmation / success state.
  - Props: `headline: String`, `subtext: String`, `onDismiss: () -> Void`.
  - Layout: centered `DSIcon("checkmark.circle.fill", size: .xl)` in `Slowly.Color.accentPrimary`, headline in `Slowly.Font.headlineRegular`, subtext in `Slowly.Font.footnoteRegular`, dismiss button using `DSButtonStyle(.secondary)`.
  - Reduce Motion: appears without scale-in animation.
  - `#Preview` light.

- [ ] **`VoiceCaptureButton.swift`** — FAB-scale voice capture trigger (not the full LogSheet — just the button surface).
  - Props: `isRecording: Bool`, `onTap: () -> Void`.
  - Layout: 60pt circle, `Slowly.Color.textPrimary` fill, `mic.fill` SF Symbol `Slowly.Color.textPrimaryWhite`.
  - Recording state: pulse ring wraps the circle using `PulseRing` from the existing component.
  - Accessibility label: `"Log something you did"`, hint: `"Opens voice capture"`.
  - `#Preview` idle + recording states.

- [ ] **`DSSheet.swift`** — Bottom sheet surface (glass-ready wrapper).
  - Props: `content: () -> Content` (generic), `detents: [PresentationDetent]` defaulting to `[.large]`.
  - iOS 26: applies glass material via `#available(iOS 26.0, *)` + `.presentationBackground(.thinMaterial)`.
  - iOS 18: `.presentationBackground(Slowly.Color.surfaceApp)`.
  - Handle: 4×36pt capsule `Slowly.Color.borderDefault`, centered above content.
  - This is a view-modifier wrapper, not a standalone view — callers use `.sheet { DSSheet { ... } }` pattern.
  - `#Preview` with placeholder content.

---

## Day 4 — Visual verification + phase-gate review

- [ ] `swift build` in `DesignSystem/` exits 0 (macOS host).
- [ ] `swift test` in `DesignSystem/` exits 0 — all existing 31 tests pass + new tests pass.
- [ ] `xcodebuild` iPhone 17 / iOS 26.4 exits 0 — BUILD SUCCEEDED.
- [ ] Phase-gate review: TokenPreviewView updated with a "D3 Composites" section covering all 9 new components.

---

## Token names to use (Slowly.* namespace only)

**Color:** `Slowly.Color.textPrimary`, `.textSecondary`, `.textPrimaryWhite`, `.textSecondaryWhite`, `.surfaceApp`, `.surfaceGhost`, `.borderDefault`, `.accentPrimary`, `.actionDestructive`

**Font:** `Slowly.Font.bigNumeral`, `.titleDisplay`, `.title1Light`, `.title2Light`, `.headlineRegular`, `.bodyRegular`, `.bodyMedium`, `.footnoteRegular`, `.footnoteMedium`, `.captionRegular`, `.captionBold`

**Spacing:** `Slowly.Spacing.xs` (8) `.sm` (12) `.md` (16) `.lg` (20) `.xl` (24) `.xxl` (32) `.xxxl` (40)

**Radius:** `Slowly.Radius.card` (20) `.button` (32) `.sheet` (40) `.fab` (capsule)

---

## Tests that must pass

- [ ] **New** `DesignSystemTests/D3CompositeTests.swift`:
  - `testEntryRowRendersText` — compile + basic prop passthrough.
  - `testTimeOfDaySectionHeaderAllVariants` — morning / afternoon / evening.
  - `testTabBarMainAllSelections` — today / reflect / more binding.
  - `testWeekBarChartNormalizesCorrectly` — max day gets fraction ≈ 1.0; zero days get fraction = 0.
  - `testWeekBarChartMaxZeroDoesNotDivideByZero` — all-zero days → no crash.
  - `testAdaptiveHeroTodayAccessibilityLabel` — label includes count + headline + subtitle.
  - `testAdaptiveHeroReflectLabel` — label reads "Reflect. \(headline)…".
  - `testAdaptiveHeroEmptyLabel` — label reads "No wins yet.".
  - `testVoiceCaptureButtonAccessibilityLabel` — label reads `"Log something you did"`.
- [ ] **Existing** `DesignSystemTests/DSComponentTests.swift` — all 18 tests still pass.
- [ ] **Existing** `DesignSystemTests/DesignSystemTests.swift` — all 13 tests still pass.
- [ ] `swift test` exits 0 — 31 + N new tests passing.

---

## Visual verification (Day 4 phase gate)

- [ ] TokenPreviewView "D3 Composites" section renders all 9 new components — screenshot on iOS 26.4 simulator.
- [ ] `EntryRow` in list: separator shows correctly on non-last rows, hidden on last row.
- [ ] `TabBarMain` active state pill animates under Reduce Motion OFF; snaps under Reduce Motion ON.
- [ ] `WeekBarChart` with all-zero data: no crash, all bars show minimum nub.
- [ ] `WeekBarChart` with one spike day: that bar fills to ~100%; others scale proportionally.
- [ ] `HeroBigNumeral` insight line wraps to 2 lines on longest string; does not overflow.
- [ ] `VoiceCaptureButton` recording state: `PulseRing` visible around mic circle.
- [ ] `DSSheet` on iOS 26: glass material visible behind handle + content.
- [ ] `DSSheet` on iOS 18: `surfaceApp` opaque background.
- [ ] Dynamic Type xxxLarge: `EntryRow` text grows without clipping; `TabBarMain` labels grow; chart day labels may truncate (acceptable — chart columns have fixed width).
- [ ] VoiceOver: `EntryRow` reads text + timestamp as one element; `TabBarMain` tabs each have label + selected trait; `VoiceCaptureButton` reads correct label + hint.
- [ ] NavBarHero + EmptyStateArrow images appear in `navBarHero.imageset` / `emptyStateArrow.imageset` without distortion at standard viewport.

---

## Files that must NOT change

- [ ] `index.html`, `sw.js`, `manifest.json`, `icon-*.png` (legacy PWA).
- [ ] `BrandTabBar.swift` — stays as-is; app target uses it. `TabBarMain` is a D3 parallel, not a replacement at this phase.
- [ ] `Hero.swift`, `HeroBlock.swift` — app target uses them. `HeroBigNumeral` is a parallel Slowly-clean build.
- [ ] `ChartBar.swift` — `WeekBarChart` wraps it; do not modify internals.
- [ ] Any file in `XCode Project/DoneList/DoneList/Features/` — D3 is DesignSystem-only.
- [ ] `DoneListWidget/` — no widget changes.
- [ ] `Slowly+*.swift` token files — additive only; no value changes without updating `Tokens.md` first.

---

## ADRs honored / referenced

- ADR-0005 — Liquid Glass with `#available` fallback (`DSSheet` iOS 26 path).
- ADR-0006 — Confetti via TimelineView+Canvas (`VoiceCaptureButton` PulseRing reuse).
- ADR-0011 — ADHD-first repositioning (`HeroBigNumeral` is the Slowly-clean implementation of the ADHD hero).
- **New: `redesign-techdebt-001`** — Deferred native-SwiftUI rebuild of botanical illustration PNG (created in Day 1). EmptyStateArrow is built natively; scope narrowed from original plan.

---

## Acceptance criteria

- [ ] Zero `Color.*`, `Font.*`, `Spacing.*`, `Radius.*` flat-extension calls in any new D3 file — `Slowly.*` only. Verify: `grep -r "Color\.\|Font\.\|Spacing\.\|Radius\." DesignSystem/Sources/DesignSystem/Components/DS*.swift EntryRow.swift TimeOfDaySectionHeader.swift NavBarPlain.swift TabBarMain.swift HeroBigNumeral.swift WeekBarChart.swift ConfirmationBlock.swift VoiceCaptureButton.swift DSSheet.swift`.
- [ ] No raw hex or `Color(red:green:blue:)` in new files.
- [ ] No `import UIKit` in new files.
- [ ] Each new public type has a one-line doc comment with Figma source or purpose.
- [ ] Every new component has a `#Preview { … }` block covering key states.
- [ ] TokenPreviewView updated with "D3 Composites" section.
- [ ] ADR `redesign-techdebt-001` written and present in `decisions/`.
- [ ] No new build warnings on macOS host build or iOS 26 destination.

---

## Out of scope

- **Wiring D3 components into app screens** — that is R4 (screen composition). D3 components live in DesignSystem only.
- **Deleting Phase 5 intermediates** (`BrandTabBar.swift`, `Hero.swift`, `HeroBlock.swift`, `Color+Tokens.swift`, etc.) — that is R8 per the migration plan.
- **DSProgressRing** — explicitly parked (2026-05-22 user decision).
- **Charts framework** — hand-built WeekBarChart is the D3 decision. If Charts framework is desired later, that needs its own ADR.
- **Dark mode** — Phase 9. Slowly.Color.* tokens have light-mode-only colorsets by design.
- **Snapshot tests** — deferred to R3+ per D2 contract. Add at R3 visual-gate review (Day 4) if stable reference frames are available.
- **Native-SwiftUI rebuild of NavBarHero and EmptyStateArrow** — explicitly deferred, documented in `redesign-techdebt-001`.

---

## Open questions (resolve before Day 1)

1. **Figma export timing:** Are the `NavBarHero` and `EmptyStateArrow` PNGs ready to export today, or does that block Day 1? (If blocked, Day 1 starts with ADR + row composites and assets drop in when ready.)
2. **`EntryRow` swipe actions:** Should `EntryRow` include swipe-to-delete affordance (per ADR-0007), or is gesture handling wired only at the app feature layer in R4? Recommendation: keep D3 primitive — no swipe logic. Wired in R4.
3. **`DSSheet` naming:** `DSSheet` follows D2 DS-prefix convention. Confirm this is the right namespace, or drop to just `Sheet`.

---

**Done means every box above is ticked.** If a box can't be ticked, this task is blocked, not done. Report the blocker; do not edit this contract to make termination easier.
