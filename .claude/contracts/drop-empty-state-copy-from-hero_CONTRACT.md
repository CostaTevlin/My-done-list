# drop-empty-state-copy-from-hero — contract

Branch: `feat/drop-old-today-account-navbar` (current). Tucks in alongside the navbar work — small, scoped follow-up.

## Outcome

`AdaptiveHero` in its `.empty` state renders backdrop only (no eyebrow, no headline, no subtitle), matching Figma node `111:8965` variant `Type=Expanded` with title hidden. The empty Today screen still guides the user via `EmptyStateArrow` and the FAB; no copy is rendered inside the hero.

## Scope decisions (already agreed with the user)

- **Hero `.empty` becomes backdrop-only.** Both "No wins yet" and "Every small step counts." are removed from `AdaptiveHero`.
- **`EmptyTodayScreen` adds no replacement copy block.** The existing `EmptyStateArrow` ("Add your first 'Done'") already serves as the empty-state hint and matches the Figma intent. (Confirmed via search: only `AdaptiveHero(state: .empty)` + `EmptyStateArrow` are composed; no other consumer of those strings exists.)
- **`CopyBank.swift` not edited.** Those two strings are not defined in CopyBank — they were hardcoded inside `AdaptiveHero`. No CopyBank entries to remove or move.
- **Hero `.empty` becomes accessibility-decorative.** Backdrop image is already `.accessibilityHidden(true)`; with no text content, the whole hero in `.empty` state is hidden from VoiceOver. Empty-state guidance comes from `EmptyStateArrow`, which already has its own a11y label.
- **Feature flag note.** `r4TodayEnabled` was already removed on this branch (per `EmptyTodayScreen.swift` header: "canonical, flag removed"). Single canonical path; no dual-path testing needed.
- **Comment hygiene.** Stale doc comments in `EmptyStateArrow.swift` and `AdaptiveHero.swift` that reference the removed copy are updated in the same change.

## Tests that must pass

- [ ] `DesignSystemTests/D3CompositeTests.test_adaptiveHero_emptyStateCompiles` — still compiles
- [ ] `DesignSystemTests/D3CompositeTests.test_adaptiveHeroEmptyLabel` — **updated** to reflect new spec (empty state is decorative, no "No wins yet" text). Rename to `test_adaptiveHeroEmptyIsDecorative` and assert the empty case carries no headline/subtitle text. This is a deliberate spec change recorded here per `testing.md`, not a test edit to silence a failure.
- [ ] `DesignSystemTests/D3CompositeTests.test_heroStateEquality` — still passes (no enum shape change)
- [ ] Full DesignSystem package test suite green: `swift test` exits 0
- [ ] Full app suite green: `xcodebuild -project DoneList.xcodeproj -scheme DoneList -destination 'platform=iOS Simulator,name=iPhone 15 Pro' test` exits 0
- [ ] If any snapshot test exists for `EmptyTodayScreen` and it fails because the hero content shrank — **report as blocker**, do not re-record. Per task instructions and `testing.md`.

## Visual verification (both OS versions — per `liquid-glass.md`)

- [ ] Build clean: `xcodebuild ... -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=18.x' build`
- [ ] Build clean: `xcodebuild ... -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=26.x' build`
- [ ] Visual: `EmptyTodayScreen` on iPhone 15 Pro / iOS 18.x — botanical backdrop fills 300pt; no text in hero region; `EmptyStateArrow` + FAB still visible at bottom-right.
- [ ] Visual: `EmptyTodayScreen` on iPhone 16 Pro / iOS 26.x — same as above; Liquid Glass elsewhere unaffected.
- [ ] Visual: `AdaptiveHero` preview `Empty` in Xcode shows backdrop only.
- [ ] VoiceOver pass: swiping into empty Today reaches `EmptyStateArrow` and FAB; the hero region itself is silent (no orphan "No wins yet" announcement).
- [ ] Dynamic Type xxxLarge: hero height stays 300pt; no layout breakage from removed text.

## Files expected to change

- `DesignSystem/Sources/DesignSystem/Components/AdaptiveHero.swift` — `.empty` case: hide title block (headline + subtitle); update header doc comment to drop the now-resolved delta; mark `.empty` decorative for a11y.
- `DesignSystem/Tests/DesignSystemTests/D3CompositeTests.swift` — update `test_adaptiveHeroEmptyLabel` per scope decision above.
- `DesignSystem/Sources/DesignSystem/Components/EmptyStateArrow.swift` — update stale comments referencing "No wins yet".
- `XCode Project/DoneList/DoneList/Features/Today/EmptyTodayScreen.swift` — update stale inline comment.

## Files that must NOT change

- [ ] `index.html`, `sw.js`, `manifest.json`, `icon-*.png` (legacy PWA — `legacy-pwa.md`)
- [ ] `Hero.swift` and `HeroBlock.swift` (deprecated, out of scope per task)
- [ ] `Services/CopyBank.swift` (strings not present there)
- [ ] Any unrelated component or screen

## ADRs honored / referenced

- ADR redesign-techdebt-001 — backdrop remains the raster PNG `navBarHero` (no change)
- ADR-0010 — nav shell (RootTabView + BrandTabBar) unchanged

(No new ADR required — this is Figma-parity tightening, not an architectural change.)

## Acceptance criteria

- [ ] No hardcoded user-facing strings remain in `AdaptiveHero.swift` for `.empty`
- [ ] No new build warnings
- [ ] No hardcoded tokens introduced (per `design-system.md`)
- [ ] `Hero.swift` and `HeroBlock.swift` untouched
- [ ] PR description references this contract path and Figma node `111:8965`

## Out of scope

- Replacing the raster `navBarHero` backdrop with the Figma concave-arc photo composition (separate techdebt item).
- Refactoring `AdaptiveHero` content stack into per-state subviews.
- Reviewing or changing `EmptyStateArrow` copy or position.
- Touching the `.today` or `.reflect` hero states.

---

**Done means every box above is ticked.** If a box can't be ticked, this task is blocked, not done. Report the blocker; do not edit this contract to make termination easier.
