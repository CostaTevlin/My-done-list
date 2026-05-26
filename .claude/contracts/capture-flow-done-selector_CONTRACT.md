# Fix CaptureFlowUITest "Done" selector ambiguity on iOS 26 — contract

> The UI test `CaptureFlowUITest.testCaptureFlow_textMode_addsRowToList()` fails on iOS 26.4 simulator because `app.buttons["Done"]` matches **two** elements: the LogSheet's submit pill (label "Done") AND the iOS 26 keyboard's return key (which gained `identifier: "Done"` in this SDK). The harness reports the failure as `Failed to tap "Done" Button: Find single matching element. Multiple matching elements found …`.
> Confirmed pre-existing on `main` (no code change needed to reproduce).

## Outcome

`testCaptureFlow_textMode_addsRowToList()` passes deterministically on iPhone 17 Pro / iOS 26.4 by querying the submit button with a **case-sensitive NSPredicate on `label`** (the sheet's button has `label: "Done"` capital D; the keyboard's return key has `label: "done"` lowercase). The `isEnabled == YES` clause is a belt-and-braces guard.

## Strategy choice (deviation from brief — recorded)

The brief recommended **Option 3** (add `.accessibilityIdentifier("submitDoneEntry")` to the submit Button). I implemented Option 3 first and verified via the test runner's exported `App UI hierarchy` attachment that the identifier was **not propagating** to the rendered Button element in iOS 26.4 (the AX node still showed `label: 'Done'` with no identifier field). Re-positioning the modifier before vs after `.buttonStyle(DSButtonStyle(.primary))` made no difference.

Rather than continue debugging a SwiftUI/iOS 26 quirk, I switched to **Option 1 / "test-side fix"**: scope the query with a case-sensitive predicate. This keeps production code untouched and unblocks the test without risking unrelated accessibility behavior changes. If the identifier-propagation issue reappears elsewhere, a more centralized investigation is warranted then.

## API change

None — production code is unchanged.

## Files touched

- `XCode Project/DoneList/DoneListUITests/CaptureFlowUITest.swift` — replace `app.buttons["Done"]` (line 67) with a case-sensitive predicate match: `app.buttons.matching(NSPredicate(format: "label == %@ AND isEnabled == YES", "Done")).firstMatch`.

## Files that must NOT change

- [x] `XCode Project/DoneList/DoneList/Features/Log/AddEntrySheet_New.swift` — production code untouched after strategy switch
- [x] `XCode Project/DoneList/DoneList/Features/Log/LogSheet.swift` — older sheet still consumed by `SearchView`. Not on the failing test's path. If a future test hits it, fix then.
- [x] `index.html`, `sw.js`, `manifest.json`, `icon-*.png` (legacy PWA)
- [x] Anything in `DesignSystem/` — purely test fix, no DS impact.

## Tests that must pass

- [x] `DoneListUITests/CaptureFlowUITest::testCaptureFlow_textMode_addsRowToList` — passes on iPhone 17 Pro / iOS 26.4 (19s isolated; 30s in suite)
- [x] `DoneListUITests/CaptureFlowUITest::testFAB_isAccessibleOnLaunch` — passes
- [x] `DoneListUITests/CaptureFlowUITest::testFAB_opensLogSheet` — passes
- [x] `DoneListUITests/CaptureFlowUITest::testGhostInputRow_opensTextMode` — skipped (its own `XCTSkip` branch fires because populated state has no ghost row) — unchanged behaviour
- [x] `DoneListUITests/CaptureFlowUITest::testTopControls_glyphsAreAccessible` — passes
- [x] `DoneListUITests/AccountButtonUITest::*` — pass (no shared selectors)
- [x] Full app test suite green: 104 passed · 1 skipped · 0 failed (the skip is the pre-existing intentional `XCTSkip` above)

## Visual verification

No user-visible change — production code unchanged.

- [x] `xcodebuild test` exits 0 on iPhone 17 Pro / iOS 26.4
- [x] VoiceOver pass unchanged — accessibility **label** still "Done" / "Save" (and "done" for the keyboard return key)

## ADRs honored / referenced

- ADR-0010 (capture flow / FAB nav shell) — no behavioural change to the flow, only test stability.
- Conventions in `.claude/rules/coding.md` — accessibility identifiers are not currently namespaced in this codebase; `"submitDoneEntry"` is the first one. If we add more, consider a `UITestID` enum (out of scope for this fix).

## Acceptance criteria

- [x] `grep -rn 'buttons\["Done"\]' "XCode Project/DoneList/DoneListUITests"` returns nothing
- [x] No new build warnings
- [x] No hardcoded tokens introduced
- [ ] PR description references this contract path and notes the iOS 26 SDK keyboard accessibility change (deferred to PR-open time)

## Out of scope

- Adding identifiers to `LogSheet.swift` (older sheet) — no test currently queries its submit button, and the failing test doesn't touch it.
- Introducing a centralized `UITestID` namespace — fine to do later if more identifiers appear; one identifier doesn't justify the abstraction.
- Filing an Apple Feedback about the iOS 26 keyboard's `identifier: "Done"` exposure — defer.

---

**Done means every box above is ticked.** If a box can't be ticked, this task is blocked, not done.
