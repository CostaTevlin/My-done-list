# drop-old-today + account-navbar — contract

Branch: `feat/drop-old-today-account-navbar` (cut from `D3-phase` 2026-05-27 after a fresh redo — the original feat branch was reset away before commit).

## Outcome

The Today tab ships only the R4 D3-composite screen (no `r4TodayEnabled` flag, no legacy `TodayView`). A persistent native top nav bar appears on Today with a circular `AccountButton` at the top-right that opens the existing Settings sheet. Behavior matches Figma node `111:8622` from the Slowly MVP file on both iOS 18 and iOS 26.

## Scope decisions (agreed with the user)

- **Flag handling:** Removed `r4TodayEnabled` entirely. Renamed `TodayScreen_New` → `TodayScreen` and `EmptyTodayScreen_New` → `EmptyTodayScreen` (files + structs).
- **Account action:** Opens the existing `SettingsView` as a sheet (no new screen).
- **Navbar scope:** Today tab only for now.
- **`LogSheet.swift` stays** — `SearchView` still depends on it. `RootTabView`'s sheet collapses to `AddEntrySheet_New` as the only path.
- **`AddEntrySheet_New` not renamed** — out of scope.
- **Xcode project:** Uses `PBXFileSystemSynchronizedRootGroup`, so file adds/renames/deletes in `XCode Project/DoneList/DoneList/**` and `DesignSystem/**` need no `project.pbxproj` edits.
- **Icon glyph:** User specified literal SF Symbol glyph 􀉭 (U+10026D). Final implementation will use `Image(systemName: "<name>")` once the user provides the canonical SF Symbol name (verified empirically that `Text(verbatim: "\u{10026D}")` renders as the missing-glyph placeholder on iOS 26.4, because iOS's system font doesn't carry the SF Symbol PUA range — only `Image(systemName:)` resolves it).

## Critical learnings from the first attempt (now baked into the implementation)

1. **`.toolbar(.visible, for: .navigationBar)` is mandatory.** On iOS 26 inside a `Tab`, the combination of `.toolbarBackground(.hidden)` + empty title + `.navigationBarTitleDisplayMode(.inline)` would otherwise collapse the entire nav bar, dropping the `ToolbarItem(.topBarTrailing)` from the view hierarchy. Verified empirically — the first attempt produced a UI hierarchy missing the Account button entirely. Fix is baked into `TodayScreen.swift`.
2. **SF Symbol PUA glyphs need `Image(systemName:)`, not `Text`.** See above.

## Tests that must pass

- [ ] `DoneListTests/Snapshots/TodayScreenSnapshotTests.swift::testSnapshot_todayScreen_empty_iOS18`
- [ ] `DoneListTests/Snapshots/TodayScreenSnapshotTests.swift::testSnapshot_todayScreen_populated_iOS18`
- [ ] `DoneListTests/Snapshots/TodayScreenSnapshotTests.swift::testSnapshot_addEntrySheetNew_textMode_iOS18` (kept as-is — AddEntrySheet_New name unchanged)
- [ ] `DoneListUITests/AccountButtonUITest::testAccountButton_isVisibleOnTodayTab`
- [ ] `DoneListUITests/AccountButtonUITest::testAccountButton_opensSettingsSheet`
- [ ] `DoneListUITests/AccountButtonUITest::testAccountButton_settingsSheet_dismissesOnSwipeDown`
- [ ] Existing test suite stays green; `feedback_uitest-tabs` selectors unchanged.
- [ ] `xcodebuild -project DoneList.xcodeproj -scheme DoneList -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test` exits 0. (iPhone 15 Pro destination auto-promotes since the local Mac has only iOS 26.4 runtime installed.)

## Visual verification

- [ ] Screenshot: Today (empty) on iPhone 17 Pro / iOS 26.4 — Account button visible at top-right (verified at coords (338, 62, 44×44) via `snapshot_ui` once the icon renders).
- [ ] Screenshot: Today (populated) on iPhone 17 Pro / iOS 26.4 — Account button visible above the hero/list, doesn't overlap.
- [ ] Tap Account → Settings sheet presents; swipe-down dismisses.
- [ ] Account button icon renders the glyph the user picked (currently 􀉭 U+10026D, pending the user supplying the SF Symbol name).
- [ ] **iOS 18 runtime not available locally**, so iOS 18 visual check is deferred (the linker target is `ios18.6-simulator` so the iOS 18 code path compiles, just can't be rendered without the iOS 18 sim runtime).
- [ ] Dynamic Type xxxLarge: navbar doesn't overlap hero; Account button stays 44×44 hit target.

## Files that change

- `XCode Project/DoneList/DoneList/Features/Today/TodayScreen.swift` (renamed from `_New`, struct renamed, navbar/toolbar/sheet wired, `.toolbar(.visible)` fix baked in).
- `XCode Project/DoneList/DoneList/Features/Today/EmptyTodayScreen.swift` (renamed from `_New`, struct renamed).
- `XCode Project/DoneList/DoneList/Features/Today/TodayView.swift` — **deleted**.
- `XCode Project/DoneList/DoneList/RootTabView.swift` — flag removed, both shells use `TodayScreen` directly, sheet uses `AddEntrySheet_New` only, header comment updated.
- `DesignSystem/Sources/DesignSystem/Components/AccountButton.swift` — **new** component, 44pt circular, iOS 18/26 split.
- `XCode Project/DoneList/DoneListTests/Snapshots/TodayScreenSnapshotTests.swift` (renamed from `TodayScreenNewSnapshotTests`, type refs and snapshot names updated).
- `XCode Project/DoneList/DoneListUITests/AccountButtonUITest.swift` — **new** UI test.
- `XCode Project/DoneList/DoneList/Features/Log/LogFABOverlay.swift` — stale `TodayView` comment fixed.
- `CLAUDE.md` Current state block — flag/screen-name info refreshed.

## Files that must NOT change

- [ ] `index.html`, `sw.js`, `manifest.json`, `icon-*.png` (legacy PWA — `legacy-pwa.md`).
- [ ] `XCode Project/DoneList/DoneList/Features/Log/LogSheet.swift` — Search depends on it.
- [ ] `XCode Project/DoneList/DoneList/Features/Log/AddEntrySheet_New.swift` — name unchanged in this task.
- [ ] `Features/Reflect/*`, `Features/Search/*`, `Features/Settings/*`.
- [ ] `DesignSystem/Sources/DesignSystem/Components/NavBarPlain.swift` — leave alone.

## ADRs honored / referenced

- **ADR-0005** (Liquid Glass gating) — `AccountButton` wraps iOS 26 `.glassEffect(.regular, in: .circle)` in `#available(iOS 26.0, *)` with a working iOS 18 white-circle fallback.
- **ADR-0010** (nav shell — tab bar must stay) — tab bar untouched; new top nav is additive, Today only.
- **`design-system.md`** — `AccountButton` lives in DesignSystem and uses `Slowly.*` tokens only.
- **`feedback_uitest-tabs` memory** — tab-bar selectors unchanged.

## Acceptance criteria

- [ ] No remaining references to `r4TodayEnabled`, `TodayScreen_New`, `EmptyTodayScreen_New`, or bare `TodayView`. Verification:
      `grep -rn 'r4TodayEnabled\|TodayScreen_New\|EmptyTodayScreen_New\|\\bTodayView\\b' XCode\\ Project DesignSystem CLAUDE.md .claude/rules`
      returns nothing (except this contract and intentional "the flag has been removed" comment in `RootTabView`).
- [ ] No new build warnings.
- [ ] No hardcoded color/spacing/type in `AccountButton` — only `Slowly.*` tokens.
- [ ] Account button accessibility label is `"Account"`; identifier is `"Account"`; UI tests find it via `app.buttons["Account"]`.
- [ ] Icon visually renders (not the missing-glyph placeholder).
- [ ] PR description references this contract + ADR-0005 / ADR-0010.

## Out of scope (capture as follow-ups)

- Renaming `AddEntrySheet_New` → `AddEntrySheet` and folding `LogSheet` into it.
- Extending the persistent navbar to Reflect / More tabs.
- Distinct Account screen separate from Settings.
- Removing the tracked `DesignSystem/.build/` artifacts from git (flagged: `.gitignore` doesn't ignore them).

---

**Done means every box above is ticked.** If a box can't be ticked, the task is blocked, not done.
