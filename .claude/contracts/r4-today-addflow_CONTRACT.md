# r4-today-addflow — contract

> Phase R4: Today + add-flow. Migrate highest-traffic surfaces to D3 composites.
> Confirm all sections before coding starts.

---

## Outcome

The Today screen and add-entry sheet are rebuilt on top of R3 (D3) composite components — `AdaptiveHero`, `EntryRow`, `TimeOfDaySectionHeader`, `EmptyStateArrow`, `DSSheet`, `VoiceCaptureButton` — and toggled live via `AppStorage("r4TodayEnabled")`. Existing `TodayView` / `LogSheet` remain untouched behind the flag.

---

## Deliverables

| File | Notes |
|---|---|
| `DoneList/Features/Today/TodayScreen_New.swift` | Populated Today, uses R3 composites, time-of-day sectioning |
| `DoneList/Features/Today/EmptyTodayScreen_New.swift` | Empty state, `AdaptiveHero(.empty)` + `EmptyStateArrow` |
| `DoneList/Features/Log/AddEntrySheet_New.swift` | Replaces LogSheet API — three internal states: listening / captured / text-mode |
| `DoneList/Data/DoneItem.swift` | Add `source: EntrySource` enum (`.voice` / `.text`); existing rows default to `.text` |
| `DoneList/Data/DoneStore.swift` | `add(text:source:)` signature extension; existing `add(text:)` calls preserved |
| `DoneList/RootTabView.swift` | Wire `r4TodayEnabled` toggle; move `ConfettiView` from `DoneListApp` to here |
| `DoneList/DoneListApp.swift` | Remove `ConfettiView` overlay + `showConfetti` state |

---

## Tests that must pass

- [ ] `DoneListTests/DoneStoreTests::testAddWithSource` — verifies `source` persists correctly
- [ ] `DoneListTests/DoneStoreTests::testLegacyAddDefaultsToText` — verifies `add(text:)` without source still works and produces `.text`
- [ ] Full suite: `xcodebuild -project DoneList.xcodeproj -scheme DoneList -destination 'platform=iOS Simulator,name=iPhone 15 Pro' test` exits 0

---

## Visual verification

Both OS versions required for every user-visible change (per `liquid-glass.md`).

- [ ] `TodayScreen_New` — populated — iPhone 15 Pro / iOS 18: time-of-day sections render, EntryRow shows mic icon on voice items
- [ ] `TodayScreen_New` — populated — iPhone 16 Pro / iOS 26: same + glass tab bar below
- [ ] `EmptyTodayScreen_New` — iPhone 15 Pro / iOS 18: AdaptiveHero(.empty) + EmptyStateArrow visible at 50% opacity
- [ ] `EmptyTodayScreen_New` — iPhone 16 Pro / iOS 26: same
- [ ] `AddEntrySheet_New` — listening state — pulse ring animating, "Try saying" prompt
- [ ] `AddEntrySheet_New` — captured state — transcript text visible, checkmark enabled
- [ ] `AddEntrySheet_New` — text-mode state — DSTextField focused, Done button active
- [ ] VoiceOver: "7 done today" announced on hero (not literal "7"); each EntryRow reads text + timestamp
- [ ] Dynamic Type xxxLarge: Today list rows don't clip; hero numeral truncates gracefully
- [ ] Reduce Motion: no pulse animation on VoiceCaptureButton; row transitions instant

---

## SwiftData migration decisions

**EntrySource enum** (additive, safe):
```swift
enum EntrySource: String, Codable { case voice, text }
```
- New property on `DoneItem`: `var source: EntrySource = .text`
- SwiftData handles additive columns without a manual migration version — existing rows get the default `.text` automatically.
- `DoneStore.add(text:source:)` takes the source parameter; the old `add(text:)` calls remain and pass `.text`.
- Fetch descriptors are unchanged — source is not used in any predicate.

> **Note:** This is the architectural item flagged as "Claude Opus session." Sonnet 4.6 handling it because the migration is additive-only (no schema version bump, no lightweight migration needed beyond SwiftData's default). If we needed a migration between schema versions, that would need Opus + a full ADR.

---

## Feature flag

`AppStorage("r4TodayEnabled")` — `Bool`, default `false`.

In `RootTabView`:
- When `false`: existing `TodayView` + `LogSheet` (current behaviour)
- When `true`: `TodayScreen_New` + `AddEntrySheet_New`

The flag is toggled in Settings (or via developer gesture) for A/B verification before promotion.

---

## ConfettiOverlay migration

Moves from `DoneListApp.WindowGroup` → `RootTabView`. Both iOS 18 and iOS 26 shells share the same confetti wire-up via the store's `confettiFireCount` counter. `DoneListApp` loses `@State private var showConfetti` and the `.overlay { ConfettiView }`.

---

## Files that must NOT change

- [ ] `index.html`, `sw.js`, `manifest.json`, `icon-*.png` (legacy PWA — read-only)
- [ ] `TodayView.swift` — must remain untouched; flag-off path still uses it
- [ ] `LogSheet.swift` — must remain untouched; flag-off path still uses it
- [ ] `DesignSystem/` token files — no token changes in this phase

---

## ADRs honored / referenced

- ADR-0003 — SwiftData persistence (additive column, no version bump)
- ADR-0005 — Liquid Glass with `#available` fallback strategy
- ADR-0006 — Confetti via TimelineView+Canvas (implementation unchanged, location moves)
- ADR-0007 — Native swipeActions (EntryRow swipe-to-delete wired at feature layer)
- ADR-0010 — Voice-first input + FAB navigation (AddEntrySheet_New three-state)

---

## Acceptance criteria

- [ ] `r4TodayEnabled = false` → app behaves identically to today's main branch
- [ ] `r4TodayEnabled = true` → Today screen, empty state, and add sheet all use D3 components
- [ ] Voice-captured items show mic icon in EntryRow when `source == .voice`
- [ ] Time-of-day sectioning: Morning (before 12:00), Afternoon (12:00–18:00), Evening (after 18:00)
- [ ] VoiceOver on hero: announced as "{n} done today. {insight}" not raw numeral
- [ ] No hardcoded colors, spacing, or fonts in any new file (all via `Slowly.*` tokens)
- [ ] No new build warnings
- [ ] PR description references this contract and ADR-0003, ADR-0010

---

## Out of scope

- Dark mode polish (Phase 9)
- Widget extension updates (Phase 8)
- Onboarding wiring for the new screens (Phase 7)
- Reflect screen R4 equivalent (separate task)
- Removal of old `TodayView` / `LogSheet` / flag cleanup (Phase R8)

---

**Done means every box above is ticked.** If a box can't be ticked, the task is blocked, not done. Do not edit this contract to make termination easier.
