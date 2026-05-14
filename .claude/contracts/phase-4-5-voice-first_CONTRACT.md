# Phase 4.5 — Voice-first capture + FAB navigation shell — contract

> **Status:** Draft — confirm with Konstantin before coding starts (per `.claude/rules/contracts.md`).
> **Owner model:** Sonnet 4.6 executes. Plan was set by Opus 4.7 (planning conversation 2026-05-14).
> **Anchors:** [[ADR-0010 — Voice-first input + FAB navigation]], [[Opportunity tree]] §O2 CAPTURE, `design-system/Tokens.md`, `design-system/Liquid Glass mapping.md`, `Redesign/References/voice-input/` + `Redesign/References/navigation/`.

## Outcome

Opening the app → tapping the charcoal FAB → speaking → tapping ✓ logs a single new DoneItem in ≈3 seconds, with no keyboard. The bottom tab bar is gone; navigation collapses to one screen with a top-right glyph cluster for search · reflect · more. Text capture remains available via the ghost input row above the list and via a "Type instead" pill on the LogSheet. Tap-to-edit on an existing row reopens the LogSheet in text mode pre-populated with that item.

This contract closes the load-bearing capture path described in O2 (CAPTURE) of the Opportunity Tree. It is the gate that releases the rest of the tree.

## Release gate

Per the planning conversation 2026-05-14, **Phase 4.5 builds and merges to main, but the user-facing release of voice-mode-on-first-launch is gated on Phase 7 onboarding shipping** (the permission rationale screen for `NSSpeechRecognitionUsageDescription` + `NSMicrophoneUsageDescription`). Until Phase 7 ships:

- The LogSheet in `.voice` mode is reachable only via the FAB.
- First-launch users land in a state where the FAB exists but onboarding has not yet primed mic/speech permission rationale.
- **Do not submit to TestFlight or App Store on Phase 4.5 alone.** Update `00 — Index.md` so a future session does not interpret "4.5 done" as "ready to ship."

## Pre-flight checks (do these first)

- [ ] Run `git status` and `git branch --show-current`. Confirm clean working tree. Branch from `main` to `adr-0010-voice-first` (per `.claude/rules/git-pr.md`).
- [ ] Re-read [[ADR-0010]] and the Opportunity Tree §O2 in full.
- [ ] Read existing `Features/Log/SpeechRecognizer.swift`, `Features/Log/LogSheet.swift`, `Features/Log/FloatingLogButton.swift`, `RootTabView.swift`, `DesignSystem/Sources/DesignSystem/Components/BrandTabBar.swift` end-to-end — don't trust memory.
- [ ] Read `Services/CopyBank.swift` for existing voice-mode strings; if missing, add them per `design-system/Copy bank.md` first.
- [ ] Confirm the planning-conversation answers are still locked:
  1. One item per LogSheet session — no ramble mode.
  2. One static "Try saying…" example (not rotating), pulled from CopyBank.
  3. "Type instead" appears as a top-right pill on the LogSheet.
  4. Phase 4.5 release gates on Phase 7 onboarding.
  5. No in-session editing of voice-captured text; edit happens post-add via tap-to-edit on the row.

## Scope of changes

### Shell collapse — ADR-0010 steps 1, 7, 13

- [ ] **New file** `RootView.swift` replacing `RootTabView.swift`:
  - Hosts `TodayView` directly. No tab bar.
  - `safeAreaInset(edge: .bottom)` for `FloatingLogButton`.
  - `safeAreaInset(edge: .top, alignment: .trailing)` for `TopControls`.
  - State for `presentedSheet: SheetKind?` driving `.sheet(item:)` — kinds: `.log(initialMode:)`, `.reflect`, `.search`, `.settings`.
- [ ] Delete `RootTabView.swift` once `RootView.swift` is wired.
- [ ] Delete `DesignSystem/Sources/DesignSystem/Components/BrandTabBar.swift` and its snapshot tests in the same PR.
- [ ] Update `@main App` (likely `DoneListApp.swift`) to host `RootView` instead of `RootTabView`.

### TopControls pill — ADR-0010 step 3

- [ ] **New file** `Features/Today/TopControls.swift`:
  - Single horizontal pill carrying 3 SF Symbols: `magnifyingglass` · `chart.bar` · `ellipsis` (verify glyph against Figma node 28-84).
  - iOS 26: `.glassEffect(.regular)` per `.claude/rules/liquid-glass.md`.
  - iOS 18: `.background(.thinMaterial.shadow(.drop(...)))` with a charcoal-tinted overlay at ~12% opacity.
  - Tap each glyph → bind to `presentedSheet` on `RootView`.
  - Tokens only; no inline hex.
  - 44pt minimum hit-target per glyph for VoiceOver / Switch Control.

### FloatingLogButton — ADR-0010 step 2

- [ ] Existing `Features/Log/FloatingLogButton.swift` may already exist as scaffolding. Audit and update:
  - 56pt charcoal circle (`tokenCharcoal`).
  - SF Symbol `mic.fill`, white tint.
  - `.shadow(color: .black.opacity(0.12), radius: 12, y: 4)`.
  - Tap → `presentedSheet = .log(initialMode: .voice)`.
  - On iOS 26, optionally inset `.glassEffect()` *behind* the charcoal fill for a subtle bloom — verify against Figma; otherwise leave flat.
  - VoiceOver label: `"Log something you did"`, hint: `"Opens voice capture"`.
  - **Reject Todoist red** — charcoal is mandatory (Tokens.md).

### GhostInputRow — ADR-0010 steps 4, 8

- [ ] **New file** `Features/Today/GhostInputRow.swift`:
  - Dashed/ghost styling matching Tiimo "Anytime today works" reference (`17-18-05`).
  - Copy: `"Type something you did…"` (add to CopyBank, mirror in `Copy bank.md`).
  - Tap → `presentedSheet = .log(initialMode: .text)`.
  - When list is empty, this **replaces** the existing "Log something" pill empty-state CTA. Update `TodayView.swift` accordingly.
  - Tokens only.

### LogSheet — voice + text modes — ADR-0010 step 5

- [ ] Extend `Features/Log/LogSheet.swift`:
  - Add `init(initialMode: Mode, editingItem: DoneItem? = nil)` where `Mode = .voice | .text`.
  - Sheet header: X close (top-left, circular `tokenWhite` with `tokenCharcoal` glyph), title `"Add a done"` (verify CopyBank canonical), **"Type instead" capsule top-right when in `.voice`** / **"Use voice" capsule top-right when in `.text`**. Mode toggle is mutually exclusive. When `editingItem != nil`, the toggle is hidden entirely.
  - Voice mode:
    - On appear, after 400ms settle, request mic permission if `.notDetermined`. If `.denied`, switch to `.text` mode immediately (do not block the sheet).
    - If `.authorized`, call `SpeechRecognizer.start()` and show the listening surface.
    - Listening surface bottom dock: left = restart button (circular gray, SF `arrow.counterclockwise`), center = `PulseRing` around mic glyph, right = confirm checkmark — **disabled (gray) until at least one transcript token has been recognized**.
    - Caption under PulseRing, two lines: bold `"Listening…"` + bodySub `"Say what you just did."` (from CopyBank).
    - Above the listening surface in the center: idle prompt `"Try saying"` label + a **single static example** from CopyBank (e.g., `"Finished the deck for tomorrow's review"`). Hides once any transcript is recognized.
    - When the user taps ✓, commit the current transcript as one `DoneItem` via `DoneStore.add(...)`, dismiss the sheet, return to Today.
  - Text mode:
    - Standard `TextField` + "Done" submit. Existing behavior. Audit autofocus + 2-char min + submit (already shipped per CLAUDE.md "Phase 4 done"); verify and leave intact.
    - Submit commits one `DoneItem` and dismisses.
  - **One item per session** — sheet dismisses on confirm. Do not add multi-item / ramble behavior.
  - When `editingItem != nil`, commit updates the item rather than inserts a new one. Voice mode is not offered.

### SpeechRecognizer audit — supporting ADR-0010

- [ ] Re-read existing `SpeechRecognizer.swift`. Confirm:
  - `@Observable`, wraps `SFSpeechRecognizer` + `AVAudioEngine`.
  - Exposes `transcript: String`, `isRecording: Bool`, `isAvailable: Bool`, `authorizationStatus`.
  - `start()` / `stop()` / `reset()` methods.
  - Cleans up `AVAudioEngine` on `deinit` and on `stop()`.
  - On-device-only flag set (`requiresOnDeviceRecognition = true`) — flagged as **open question** below.
  - Emits a published "no speech detected after 3s" state so the UI can soften the prompt.
- [ ] Add unit tests for `SpeechRecognizer` that don't require mic hardware (state machine transitions only — see Testing section).

### PulseRing — supporting ADR-0010

- [ ] **New file** `DesignSystem/Sources/DesignSystem/Components/PulseRing.swift`:
  - Concentric ring animating around a mic glyph. Single state input: `isPulsing: Bool`.
  - Implemented with `TimelineView(.animation)` + `Canvas` per [[ADR-0006]] (no third-party particle libs).
  - **Reduce Motion**: when `accessibilityReduceMotion == true`, replace pulse with a static double-ring + filled-circle. Mic glyph stays.
  - Tokens only; ring color = `tokenCharcoal.opacity(0.15)`.

### Tap-to-edit existing row — ADR-0010 step 10

- [ ] Update `Features/Today/ItemRow.swift`:
  - Tap-anywhere-on-row (excluding swipe area) opens `LogSheet(initialMode: .text, editingItem: item)`.
  - Long-press still selects (preserve existing).
- [ ] Update `TodayView.swift` to plumb selected item into the sheet.

### Permission rationale — ADR-0010 step 14

- [ ] Verify `Info.plist`:
  - `NSSpeechRecognitionUsageDescription` — short, plain copy from CopyBank.
  - `NSMicrophoneUsageDescription` — same.
- [ ] **Do not** ship a Phase 4.5 standalone pre-permission rationale screen (per planning answer #4 — onboarding owns that, Phase 7).
- [ ] If permission is `.notDetermined` when LogSheet `.voice` opens, the system dialog appears cold. Acceptable per release gate above.

### Reflect / Settings as sheets — ADR-0010 step 7

- [ ] Wire TopControls glyphs to present their respective screens as `.sheet`, not as navigation pushes:
  - 📊 reflect → `ReflectView` sheet (`.presentationDetents([.large])`).
  - ⋯ more → `SettingsView` sheet.
  - 🔍 search → wired but lands on a placeholder `Text("Coming soon")` (real implementation in a separate contract — see Out of scope).

## Files that must NOT change

- [ ] `index.html`, `sw.js`, `manifest.json`, `icon-*.png` (legacy PWA — see `legacy-pwa.md`).
- [ ] `DesignSystem/Sources/DesignSystem/Components/BigNumeral.swift` — hero block work belongs to a separate contract (today-hero-adhd).
- [ ] `Features/Reflect/*` — Phase 5 owns this.
- [ ] `DoneListWidget/*` — widget work is Phase 8.
- [ ] `DoneStore.swift` — additive only (no schema changes; per [[ADR-0009]] schema changes need their own ADR).
- [ ] `Services/HapticEngine.swift` — call existing API; no internal changes.
- [ ] Tokens — no token additions needed. If you find yourself wanting one, stop and ask.

## Tests that must pass

- [ ] **New** `DoneListTests/SpeechRecognizerStateTests.swift`:
  - `testInitialStateIsIdle`
  - `testAuthorizationDeniedReportsCorrectStatus`
  - `testStartWithoutPermissionTransitionsToDenied`
  - `testResetClearsTranscript`
  - (no mic hardware — use protocol-shimmed `SFSpeechRecognizer` or test only the state machine wrapper.)
- [ ] **New** `DoneListTests/LogSheetModeTests.swift`:
  - `testInitialModeVoiceStartsRecognizerOnAppear` (using a fake recognizer).
  - `testInitialModeTextDoesNotStartRecognizer`.
  - `testConfirmDisabledUntilTranscriptNonEmpty`.
  - `testEditingItemHidesVoiceToggle`.
  - `testEditingItemUpdatesNotInserts`.
- [ ] **New** `DoneListTests/Snapshots/LogSheetSnapshotTests.swift`:
  - Voice idle (no transcript yet) — iOS 18 + iOS 26.
  - Voice listening (with sample transcript) — iOS 18 + iOS 26.
  - Text mode — iOS 18.
- [ ] **New** `DoneListTests/Snapshots/RootViewSnapshotTests.swift`:
  - Empty Today + FAB + TopControls — iOS 18 + iOS 26.
  - Populated Today + FAB + TopControls + GhostInputRow — iOS 18 + iOS 26.
- [ ] **New** `DoneListTests/Snapshots/PulseRingSnapshotTests.swift`:
  - Pulsing frame mid-animation (timeline-pinned).
  - Reduce Motion fallback static state.
- [ ] **Updated** `DoneListUITests/CaptureFlowUITest.swift` (or new file):
  - End-to-end: launch → tap FAB → grant mic permission (via launchEnvironment override) → inject transcript via mock recognizer → tap ✓ → assert new row appears on Today.
- [ ] **Full suite green:** `xcodebuild ... test` on iPhone 15 Pro / iOS 18 destination exits 0. Same on iPhone 16 Pro / iOS 26. No new warnings.

## Visual verification

For any user-visible change, capture on **both** iOS 18 and iOS 26 (per `liquid-glass.md`).

- [ ] **Screenshot:** RootView populated state on iPhone 15 Pro / iOS 18.4 — FAB bottom-right, TopControls pill top-right, GhostInputRow above list. Charcoal stays crisp.
- [ ] **Screenshot:** RootView on iPhone 16 Pro / iOS 26.0 — TopControls Liquid Glass renders correctly; FAB stays charcoal (no glass on the FAB itself).
- [ ] **Screenshot:** LogSheet voice idle (Try saying…) on iOS 18 + iOS 26.
- [ ] **Screenshot:** LogSheet voice listening with sample transcript on iOS 18 + iOS 26.
- [ ] **Screenshot:** LogSheet text mode on iOS 18.
- [ ] **Screenshot:** LogSheet in edit-existing mode (voice toggle hidden) on iOS 18.
- [ ] **VoiceOver pass:**
  - FAB reads as `"Log something you did"`.
  - TopControls glyphs each have a label: `"Search"`, `"Reflect"`, `"More"`.
  - LogSheet voice mode: PulseRing has accessibility label `"Listening for your voice"`. Confirm/restart/close each labeled.
  - LogSheet "Type instead" / "Use voice" pill labeled with current state + action.
  - Editing an existing row: VoiceOver announces `"Editing: <item text>"` on sheet open.
- [ ] **Dynamic Type xxxLarge:** TopControls glyphs do not grow; FAB does not grow. Sheet caption and "Try saying" example scale; PulseRing diameter does not.
- [ ] **Reduce Motion ON:** PulseRing renders static. LogSheet appears with default sheet animation (system-handled, RM-safe).
- [ ] **Reduce Motion OFF:** PulseRing pulses at ~1Hz. Sheet animations default.
- [ ] **Permission denial path:** Manually deny mic in Settings, relaunch, tap FAB. Sheet opens directly in `.text` mode. No crash. No broken layout.

## ADRs honored / referenced

- ADR-0010 — Voice-first input + FAB navigation (anchor — this contract implements it).
- ADR-0011 — ADHD-first repositioning (capture friction is the #1 ADHD-tier UX metric).
- ADR-0005 — Liquid Glass with #available fallback (TopControls + LogSheet must work on both OS versions).
- ADR-0006 — Confetti via TimelineView+Canvas (PulseRing reuses this animation discipline).
- ADR-0008 — Notifications + widget + AppIntent. Compounding, not superseded — `LogDoneIntent`, Lock Screen widget, and notification work remain in their respective phases. ADR-0008's Log-pill-on-iOS-26-tab-search is the only piece superseded here.
- ADR-0007 — Native swipeActions (tap-to-edit must not interfere with swipe-to-delete; verify gesture priority).
- ADR-0009 — iCloud sync schema (no schema changes; voice-captured items are plain `DoneItem`s — no `source: .voice` enum unless we add an ADR).

## Acceptance criteria

- [ ] No hardcoded colors, spacing, type sizes, or radii introduced (per `design-system.md`).
- [ ] No new build warnings on iOS 18 or iOS 26 destinations.
- [ ] No iOS-26-only API used without `#available(iOS 26.0, *)` guard. Spot-check with `grep -r "glassEffect\|tabViewBottomAccessory\|Tab(role:" XCode\ Project/DoneList/DoneList`.
- [ ] `RootTabView.swift` and `BrandTabBar.swift` are deleted in the same PR — not stranded.
- [ ] `00 — Index.md` updated to reflect Phase 4.5 status + the Phase-7 release gate. Update CLAUDE.md "Current state" block too.
- [ ] All new strings in `Services/CopyBank.swift` mirror `design-system/Copy bank.md` verbatim — vault updated first per `design-system.md`.
- [ ] PR description references this contract path, ADR-0010, ADR-0011, and the Opportunity Tree O2 anchor.
- [ ] PR title: `feat(capture): voice-first LogSheet + FAB navigation shell` (per `git-pr.md`).
- [ ] Branch name: `adr-0010-voice-first`.
- [ ] `git status` shows only intended changes; no `.DS_Store`, no stray edits, no contract edits made to ease termination.

## Out of scope (explicit — separate contracts to follow)

- **Monthly Reflect banner** (ADR-0010 step 9). Independent surface; can ship in Phase 5 alongside Reflect work.
- **Undo-delete toast** (ADR-0010 step 11). Touches `DoneStore` undo state + a new DS component. Separate contract.
- **Search screen + browse-by-date** (ADR-0010 step 12). Significant — full SwiftData `searchable`, dedicated `SearchView`, date browse. Own contract. Search glyph wired but lands on a placeholder.
- **Highlight-most-recent-item ~3s decay** (Phase 5 / O4 recovery solution). Separate.
- **Phase 7 onboarding permission rationale.** Owned by Phase 7 contract. This contract sets up the technical readiness (Info.plist keys, graceful denied-fallback), not the rationale UI.
- **Source-tagging items as `.voice` vs `.text`** in the data model. Would need a schema migration ADR per [[ADR-0009]]. Out of scope unless Konstantin wants the telemetry.
- **Multi-item ramble mode.** Explicitly rejected per planning answer #1.
- **In-session edit during voice.** Explicitly rejected per planning answer #5.

## Open questions

Five planning questions resolved 2026-05-14:

1. ✅ One item per LogSheet session.
2. ✅ Single static "Try saying" example.
3. ✅ "Type instead" as top-right pill.
4. ✅ Release gate on Phase 7 onboarding.
5. ✅ No in-session edit; tap-to-edit on row instead.

One emergent question — surface before SpeechRecognizer audit:

- **Should `SpeechRecognizer.requiresOnDeviceRecognition` be `true` always?** ADR-0011 favors strict privacy (no network); on-device is slower and less accurate for short utterances. Recommendation: `true` always, accept the accuracy tradeoff, document it. Alternative: feature-flag and let TestFlight users opt in to cloud recognition for accuracy. **Decision needed before SpeechRecognizer audit step.**

---

**Done means every box above is ticked.** If a box can't be ticked, this task is blocked, not done. Report the blocker; do not edit this contract to make termination easier.
