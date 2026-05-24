# drop-old-today + account-navbar — contract

Branch: `D3-phase` (or a new `feat/drop-old-today-account-navbar` cut from it — Sonnet to confirm at start).

## Outcome

The Today tab ships only the R4 D3-composite screen (no flag, no legacy `TodayView`). A persistent native top nav bar appears on Today with a circular Account button at the top-right that opens the existing Settings sheet. Behavior matches Figma node `111:8622` from the Slowly MVP file on both iOS 18 and iOS 26.

## Scope decisions (already agreed with the user)

- **Flag handling:** Remove `r4TodayEnabled` entirely. Rename `TodayScreen_New` → `TodayScreen` and `EmptyTodayScreen_New` → `EmptyTodayScreen` (files + structs).
- **Account action:** Opens the existing `SettingsView` as a sheet (no new screen).
- **Navbar scope:** Today tab only for now. Reflect/More keep their current chrome until a future task.
- **LogSheet:** Stays in the codebase — `SearchView` still uses it for edit. RootTabView's sheet picks `AddEntrySheet_New` as the only path. (Renaming `AddEntrySheet_New` → `AddEntrySheet` and consolidating with `LogSheet` is **out of scope**; capture as a follow-up.)
- **Xcode project file:** Uses `PBXFileSystemSynchronizedRootGroup`, so renames/deletes/adds in `XCode Project/DoneList/DoneList/**` and `DesignSystem/**` need no `project.pbxproj` edits.

## Tests that must pass

- [ ] `DoneListTests/Snapshots/TodayScreenSnapshotTests.swift::testSnapshot_todayScreen_empty_iOS18` (renamed from `TodayScreenNewSnapshotTests`)
- [ ] `DoneListTests/Snapshots/TodayScreenSnapshotTests.swift::testSnapshot_todayScreen_populated_iOS18`
- [ ] `DoneListTests/Snapshots/TodayScreenSnapshotTests.swift::testSnapshot_addEntrySheet_textMode_iOS18` (kept as-is structurally, type-ref updated if AddEntrySheet name changes — but in this contract it doesn't)
- [ ] New unit / integration test: tap the trailing Account button on `TodayScreen` → assert the Settings sheet presentation state flips (e.g. via injected callback or `@Binding` in a unit test, OR a UITest that asserts `app.staticTexts["Settings"]` appears after tapping `app.buttons["Account"]`).
- [ ] Existing UI tests still pass — in particular `app.buttons["Today tab"]` (iOS 18) / `app.tabBars.buttons["Today"]` (iOS 26) behavior is unchanged (per `feedback_uitest-tabs` memory).
- [ ] Full suite green:
      `xcodebuild -project DoneList.xcodeproj -scheme DoneList -destination 'platform=iOS Simulator,name=iPhone 15 Pro' test` exits 0.

## Visual verification (both OS versions — per `liquid-glass.md`)

- [ ] Screenshot: Today (populated) on iPhone 15 Pro / iOS 18.x — circular white Account button at top-right with soft drop shadow, matches Figma `111:8622`.
- [ ] Screenshot: Today (populated) on iPhone 16 Pro / iOS 26.x — Liquid Glass capsule on the Account button (via `.glassEffect(.regular, in: .circle)`), no double-chrome.
- [ ] Screenshot: Today (empty) on both simulators — Account button still visible above `EmptyTodayScreen` content, doesn't fight the empty-state arrow.
- [ ] Tap Account → Settings sheet presents on both simulators; swipe-down dismisses.
- [ ] VoiceOver: Account button reads "Account, Button". Settings sheet trap is correct (no orphan focus).
- [ ] Dynamic Type xxxLarge: navbar doesn't overlap hero; Account button stays 44×44 hit target.
- [ ] Reduce Motion: sheet present animation respects system setting (default SwiftUI sheet does this).

## Files that must change

- `XCode Project/DoneList/DoneList/Features/Today/TodayScreen_New.swift` → renamed to `TodayScreen.swift`; struct renamed; navbar/toolbar/sheet added.
- `XCode Project/DoneList/DoneList/Features/Today/EmptyTodayScreen_New.swift` → renamed to `EmptyTodayScreen.swift`; struct renamed.
- `XCode Project/DoneList/DoneList/Features/Today/TodayView.swift` → **deleted**.
- `XCode Project/DoneList/DoneList/RootTabView.swift` — drop `r4TodayEnabled`; both shell branches collapse to the new screen; sheet branch collapses to `AddEntrySheet_New`; update header comment.
- `DesignSystem/Sources/DesignSystem/Components/AccountButton.swift` — **new** component, 44pt circular, person icon, iOS 18/26 split.
- `XCode Project/DoneList/DoneListTests/Snapshots/TodayScreenNewSnapshotTests.swift` → renamed to `TodayScreenSnapshotTests.swift`; type refs and snapshot names updated.
- `XCode Project/DoneList/DoneListUITests/...` — add UI test for Account → Settings.
- `CLAUDE.md` Current state block — bump "Next" to Phase 5 stays, but Phase line should record that the flag is now removed and `TodayScreen` is the canonical name. (Small edit; Sonnet to confirm wording.)

## Files that must NOT change

- [ ] `index.html`, `sw.js`, `manifest.json`, `icon-*.png` (legacy PWA — `legacy-pwa.md`).
- [ ] `XCode Project/DoneList/DoneList/Features/Log/LogSheet.swift` — Search still depends on it. The R8 cleanup will fold it into AddEntrySheet.
- [ ] `XCode Project/DoneList/DoneList/Features/Log/AddEntrySheet_New.swift` — file name and struct name unchanged in this task.
- [ ] `XCode Project/DoneList/DoneList/Features/Reflect/*`, `Features/Search/*`, `Features/Settings/*` — no edits beyond what the rename forces (`SettingsView()` is consumed, not modified).
- [ ] `DesignSystem/Sources/DesignSystem/Components/NavBarPlain.swift` — not the right shape for Today (no avatar, no glass); leave alone, do not extend with avatar variant in this task.

## ADRs honored / referenced

- **ADR-0005** (Liquid Glass gating) — `AccountButton` uses `#available(iOS 26.0, *)` with a working iOS 18 fallback. Liquid Glass parameters come from `Slowly.Material` constants; no hardcoded values.
- **ADR-0010** (nav shell — FAB-only nav broke the UI; tab bar + RootTabView must stay) — this task does NOT remove the tab bar. The new top nav is additive, on the Today tab only.
- **`feedback_uitest-tabs` memory** — UI tests for tab bar continue to use the iOS-version-split selectors.
- **`design-system.md`** — `AccountButton` lives in DesignSystem, uses `Slowly.*` tokens only. No `Color(red:green:blue:)` or hardcoded spacing in feature code.

## Acceptance criteria

- [ ] No remaining references to `r4TodayEnabled`, `TodayScreen_New`, `EmptyTodayScreen_New`, or `TodayView(` anywhere in the repo.
      Verification: `grep -rn 'r4TodayEnabled\|TodayScreen_New\|EmptyTodayScreen_New\|\\bTodayView\\b' .` returns only this contract and the renamed snapshot fixtures (if any).
- [ ] No new build warnings.
- [ ] No hardcoded color/spacing/type in `AccountButton` — only `Slowly.*` tokens.
- [ ] `AccountButton` uses `person.fill` SF Symbol (matches Figma silhouette — single circular surround). If the design review prefers `person.crop.circle.fill`, swap inside the component only.
- [ ] `AccountButton` accessibility label is `"Account"`; UI tests can find it via `app.buttons["Account"]`.
- [ ] PR description references this contract path and ADR-0005 / ADR-0010.

## Out of scope (capture as follow-ups)

- Renaming `AddEntrySheet_New` → `AddEntrySheet`, deleting `LogSheet.swift`, migrating `SearchView` to `AddEntrySheet`. (Real cleanup but a different blast radius — separate task.)
- Adding the persistent navbar to Reflect / More tabs.
- Dark-mode polish on the Account button beyond what falls out of `Slowly.Color.surfaceApp` and the asset catalog.
- Account screen distinct from Settings (user picked "open existing Settings sheet").

---

**Done means every box above is ticked.** If a box can't be ticked, this task is blocked, not done. Report the blocker; do not edit this contract to make termination easier.
