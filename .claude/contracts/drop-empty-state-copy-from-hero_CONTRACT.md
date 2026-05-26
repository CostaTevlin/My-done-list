# drop-empty-state-copy-from-hero — contract

Branch: `D3-phase` (current). Small Figma-parity follow-up tucked into the D3 line.

## Outcome

`AdaptiveHero` in its `.empty` state renders backdrop only (no eyebrow, no headline, no subtitle), matching Figma node `111:8965` variant `Type=Expanded` with title hidden. The empty Today screen still guides the user via `EmptyStateArrow` and the FAB; no copy is rendered inside the hero.

## Scope decisions (already agreed with the user)

- **Hero `.empty` becomes backdrop-only.** Both "No wins yet" and "Every small step counts." are removed from `AdaptiveHero`.
- **`EmptyTodayScreen_New` adds no replacement copy block.** The existing `EmptyStateArrow` ("Add your first 'Done'") already serves as the empty-state hint and matches the Figma intent. (Confirmed via grep: only `AdaptiveHero(state: .empty)` + `EmptyStateArrow` are composed; no other consumer of those strings exists.)
- **`CopyBank.swift` not edited.** Those two strings are not defined in CopyBank — they were hardcoded inside `AdaptiveHero`. No CopyBank entries to remove or move.
- **Hero `.empty` becomes accessibility-decorative.** Backdrop image is already `.accessibilityHidden(true)`; with no text content, the whole hero in `.empty` is hidden from VoiceOver. Screen-level guidance comes from `EmptyStateArrow`, which already has its own a11y label.
- **Feature flag note.** `r4TodayEnabled` (default `false`) is still live on this branch. Legacy `TodayView` uses the deprecated `Hero` component (out of scope per task), so removing copy from `AdaptiveHero.empty` only affects the R4 path. Both flag states therefore keep working.
- **Comment hygiene.** Stale doc comments in `EmptyStateArrow.swift`, `AdaptiveHero.swift`, and `EmptyTodayScreen_New.swift` that reference the removed copy are updated in the same change.

## Tests that must pass

- [x] `DesignSystemTests/D3CompositeTests.test_adaptiveHero_emptyStateCompiles` — still compiles · **passed**
- [x] `DesignSystemTests/D3CompositeTests.test_adaptiveHeroEmptyIsDecorative` (renamed from `test_adaptiveHeroEmptyLabel`) — asserts decorative empty hero · **passed** (50/50 DesignSystem tests green)
- [x] `DesignSystemTests/D3CompositeTests.test_heroStateEquality` — still passes · **passed**
- [x] Full DesignSystem package test suite green: `swift test` exits 0 · **passed**
- [x] `TodayScreenNewSnapshotTests.testSnapshot_todayScreenNew_empty_iOS18` — **passed** (note: this is a smoke-render not strict pixel diff)
- [x] `RootViewSnapshotTests.testSnapshot_emptyToday_iOS18` — **passed**
- [x] All other unit/snapshot tests — **passed**
- [x] **Pre-existing flake noted, not a blocker for this task:** `CaptureFlowUITest.testCaptureFlow_textMode_addsRowToList` failed on iOS 26. Verified pre-existing by stash-pop-test cycle — same failure on baseline `D3-phase` without my edits. Failing test exercises FAB→text→submit→row flow; does not touch empty-hero surface. Reported here for the next person to triage.

## Visual verification (both OS versions — per `liquid-glass.md`)

- [ ] **BLOCKED — iOS 18 runtime not installed on this machine.** `xcrun simctl list runtimes` shows only iOS 26.4 / 26.4.1. To unblock, install an iOS 18 simulator via Xcode → Settings → Components, then run `xcodebuild ... -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=18.x' build`. (Code path is the same on both — no iOS-26-only API was added; `#available` not required for this change.)
- [x] Build clean: `xcodebuild ... -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.4.1' build` — **BUILD SUCCEEDED**, no new warnings.
- [ ] Visual: `EmptyTodayScreen_New` on iPhone 15 Pro / iOS 18.x — **deferred until iOS 18 runtime installed.**
- [ ] Visual: `EmptyTodayScreen_New` on iPhone 17 Pro / iOS 26.4.1 — **needs manual eyeball in Xcode**: open `EmptyTodayScreen_New.swift` preview or `AdaptiveHero` "Empty" preview; confirm backdrop only, no text.
- [ ] Visual: `AdaptiveHero` preview `Empty` in Xcode shows backdrop only — **needs manual eyeball**.
- [ ] VoiceOver pass: swiping into empty Today reaches `EmptyStateArrow` and FAB; the hero region itself is silent — **needs manual verification on device/simulator**.
- [ ] Dynamic Type xxxLarge: hero height stays 300pt; no layout breakage from removed text — **needs manual verification**.

## Files expected to change

- `DesignSystem/Sources/DesignSystem/Components/AdaptiveHero.swift` — `.empty` case: hide title block (headline + subtitle); update `HeroState.empty` doc; mark `.empty` decorative for a11y.
- `DesignSystem/Tests/DesignSystemTests/D3CompositeTests.swift` — update `test_adaptiveHeroEmptyLabel` → `test_adaptiveHeroEmptyIsDecorative`.
- `DesignSystem/Sources/DesignSystem/Components/EmptyStateArrow.swift` — update stale comments referencing "No wins yet".
- `XCode Project/DoneList/DoneList/Features/Today/EmptyTodayScreen_New.swift` — update stale inline comment.

## Files that must NOT change

- [ ] `index.html`, `sw.js`, `manifest.json`, `icon-*.png` (legacy PWA — `legacy-pwa.md`)
- [ ] `Hero.swift` and `HeroBlock.swift` (deprecated, out of scope per task)
- [ ] `Services/CopyBank.swift` (strings not present there)
- [ ] `TodayView.swift` (legacy path uses `Hero`, not `AdaptiveHero` — unaffected)
- [ ] Any unrelated component or screen

## ADRs honored / referenced

- ADR redesign-techdebt-001 — backdrop remains the raster PNG `navBarHero` (no change)
- ADR-0010 — nav shell (RootTabView + BrandTabBar) unchanged

(No new ADR required — Figma-parity tightening, not architectural change.)

## Acceptance criteria

- [x] No hardcoded user-facing strings remain in `AdaptiveHero.swift` for `.empty` — verified via diff
- [x] No new build warnings — confirmed by clean iOS 26 build
- [x] No hardcoded tokens introduced (per `design-system.md`) — change removes content, adds none
- [x] `Hero.swift` and `HeroBlock.swift` untouched — confirmed via `git status`
- [ ] PR description references this contract path and Figma node `111:8965` — to be added when PR is opened

## Out of scope

- Replacing the raster `navBarHero` backdrop with the Figma concave-arc photo composition (separate techdebt item).
- Refactoring `AdaptiveHero` content stack into per-state subviews.
- Reviewing or changing `EmptyStateArrow` copy or position.
- Touching the `.today` or `.reflect` hero states.
- Renaming `_New`-suffixed files or removing `r4TodayEnabled` — that's the sibling `drop-old-today-add-account-navbar` contract.

---

**Done means every box above is ticked.** If a box can't be ticked, this task is blocked, not done. Report the blocker; do not edit this contract to make termination easier.
