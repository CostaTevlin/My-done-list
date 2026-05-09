# Today hero ADHD refactor — contract

> **Status:** Draft — confirm with Konstantin before coding starts (per `.claude/rules/contracts.md`).
> **Owner model:** Sonnet 4.6 executes. Plan was set by Opus 4.7 (this conversation).
> **Anchors:** [[ADR-0011 — ADHD-first repositioning]], existing PRD §Today screen, Screen specs §1, Copy bank §v2 ADHD momentum tier.

## Outcome

Today screen leads with a 3-line hero block — count + supporting label + ADHD-tier insight line — drawn from the new Copy bank momentum tier, replacing the isolated big numeral. Insight rotates correctly by `count × hour`, animates softly on change, and falls back gracefully under Reduce Motion.

This is the first user-visible piece of the v2 ADHD-first repositioning. It does **not** include the Reflect insight cards engine — that's a separate, downstream contract under the same ADR.

## Pre-flight checks (do these first)

- [ ] Run `git status` and `git branch --show-current`. Confirm branch is `main` or branch from `main` to `feat/today-hero-adhd`.
- [ ] Read the latest [[ADR-0011]] and [[Copy bank]] §v2 ADHD momentum tier in full.
- [ ] Read existing `Features/Today/TodayView.swift` and `Services/CopyBank.swift` end-to-end before editing — don't trust memory of their contents.
- [ ] Confirm the Copy bank version header in `Services/CopyBank.swift` is current; bump it as part of this work.
- [ ] Confirm Phase 4.5 (ADR-0010 voice-first + FAB) work-in-progress is **not** in conflict — coordinate with Konstantin if it's mid-merge.

## Scope of changes

**Files expected to change:**

- [ ] `Services/CopyBank.swift` — add the ADHD momentum tier:
  - `func todayHeroInsight(count: Int, date: Date) -> String` — selects from the new pool, same `(count * 7 + hour) % poolSize` rotation pattern as existing motivational copy.
  - `func todayHeroSupportingLabel(count: Int) -> String` — returns `wins today` (default) or other tense per Copy bank `Static UI strings` block when added.
  - Bump the file's version comment per Copy bank §Update protocol step 3.
- [ ] `Features/Today/TodayView.swift` — replace the existing big-numeral block with a new `HeroBlock` view:
  - Count (existing `BigNumeral` style, animated `.contentTransition(.numericText)`)
  - Supporting label directly below (`.font(.bodySub).foregroundStyle(.tokenMid)`)
  - Insight line below that (`.font(.motivational)`, max 2 lines, `.transition(.opacity)` on change, soft fade only when Reduce Motion is OFF).
- [ ] **New file** `DesignSystem/Sources/DesignSystem/Components/HeroBlock.swift` — encapsulates the 3-line block; takes `count: Int`, `supportingLabel: String`, `insight: String` as props. No business logic — pure presentation, like other DS components.
- [ ] **New tests:**
  - `DoneListTests/CopyBankADHDPoolTests.swift` — verify selection determinism, every count tier returns a non-empty string, insight rotates by hour.
  - `DoneListTests/Snapshots/TodayHeroSnapshotTests.swift` — snapshots for count 0, 1, 3, 7+ on iPhone 15 Pro.

**Files that must NOT change:**

- [ ] `index.html`, `sw.js`, `manifest.json`, `icon-*.png` (legacy PWA — see `legacy-pwa.md`)
- [ ] `DesignSystem/Sources/DesignSystem/Components/BigNumeral.swift` — wrap it inside `HeroBlock`, don't modify it. Other surfaces (widget, etc.) still depend on the existing BigNumeral API.
- [ ] Reflect screen, Log sheet, Settings, Onboarding — all out of scope for this contract.
- [ ] Existing PWA-port motivational copy in `CopyBank.swift` — leave the legacy pool intact (it's still the v1.0 launch pool until Phase 9 migration).
- [ ] Tokens — no token additions needed for this work. If you find yourself wanting one, stop and ask.

## Tests that must pass

- [ ] `DoneListTests/CopyBankADHDPoolTests/testHeroInsightForEveryCountTierReturnsNonEmpty` — covers count 0, 1, 2, 3, 4, 6, 7, 12.
- [ ] `DoneListTests/CopyBankADHDPoolTests/testHeroInsightRotatesByHour` — same count, two different hours → two different strings (or asserts pool size > 1).
- [ ] `DoneListTests/CopyBankADHDPoolTests/testSupportingLabelDefault` — `count == 1 → "win today"`, `count != 1 → "wins today"` (verify singular/plural decision with Konstantin if `things done today` is preferred — currently spec'd as `wins today`).
- [ ] `DoneListTests/Snapshots/TodayHeroSnapshotTests` — record snapshots at count 0, 1, 3, 7. Re-recording allowed only on first run; failures after that are real regressions, not test fixes (see `testing.md`).
- [ ] **Full suite green:** `xcodebuild ... test` exits 0. No new warnings.

## Visual verification

For any user-visible change, capture and verify on **both** iOS 18 and iOS 26 (per `liquid-glass.md`).

- [ ] Screenshot: Today screen on iPhone 15 Pro / iOS 18.4 — hero block renders 3 lines, no clipping at small Pro Max sizes, charcoal numeral remains crisp at 120pt 200 weight.
- [ ] Screenshot: Today screen on iPhone 16 Pro / iOS 26.0 — Liquid Glass elsewhere on screen still renders correctly; hero block itself does **not** apply glass (it's flat typography per Screen specs §1).
- [ ] Insight line wraps gracefully at 2 lines max — verify with the longest entries in the new pool (e.g., "Your brain may forget this. The list won't.").
- [ ] **VoiceOver** pass: hero block reads as a single accessible group: `"7 wins today. Momentum builds through small actions."` — not three separate elements.
- [ ] **Dynamic Type xxxLarge:** hero block remains readable; insight line allowed to grow to 3 lines under xxxLarge.
- [ ] **Reduce Motion ON:** insight line changes are instant (no fade), count change uses default contentTransition (already RM-safe).
- [ ] **Reduce Motion OFF:** insight line crossfades over ~250ms when count tier × hour changes.

## ADRs honored / referenced

- ADR-0011 — ADHD-first repositioning (this is the anchor)
- ADR-0001 — Migration to native SwiftUI (architectural baseline)
- ADR-0006 — Confetti via TimelineView+Canvas (not directly modified, but ensure HeroBlock doesn't fight confetti animation when log lands)
- ADR-0010 — Voice-first + FAB nav (HeroBlock must compose cleanly with the FAB shell; verify no z-index or layout collision)

## Acceptance criteria

- [ ] No hardcoded colors, spacing, type sizes, or radii introduced (per `design-system.md`).
- [ ] No new build warnings.
- [ ] `HeroBlock.swift` is self-contained in DesignSystem and has no SwiftData dependency.
- [ ] `Services/CopyBank.swift` version header bumped; mirrors [[Copy bank]] file in the vault verbatim.
- [ ] PR description references this contract path and ADR-0011.
- [ ] PR title: `feat(today): ADHD-first hero block + momentum copy pool` (per `git-pr.md`).
- [ ] Branch name: `feat/today-hero-adhd` (per `git-pr.md`).
- [ ] `git status` shows only intended changes; no `.DS_Store`, no stray edits, no contract edits made to ease termination.

## Out of scope (explicitly NOT in this contract)

- **Reflect insight cards engine.** Separate contract under ADR-0011 — depends on the InsightCard DS component, the SwiftData query layer for time-clustering, and the templates from Copy bank §Reflect insight cards. That's larger; do not start it from this branch.
- **Time-section dividers on Today** (Morning/Afternoon/Evening). Separate, smaller contract — likely after the hero ships and we know how the list redesign feels.
- **Highlight-most-recent-item accent** (3-second decay). Separate; can ride alongside the dividers contract.
- **ADHD migration of the legacy PWA-port pool.** That's Phase 9 polish per ADR-0011. Do not touch the legacy pool in this work.
- **Watch / HealthKit / Focus mode** — explicitly v1.1+ or v2.0, not this contract.

## Open questions for Konstantin (resolve before coding)

1. **Supporting label tense:** `wins today` (current spec) vs `things done today` (matches existing `things_done_today` stringsdict). Lean toward `wins today` per ADR-0011 brand voice.
2. **First time the hero crossfades on first launch:** does the insight line render with copy on first paint, or fade in from blank? Recommend: render with copy immediately, no first-paint fade (less janky).
3. **Onboarding screen 5.1 Welcome copy:** does it stay on the legacy pool ("A quiet place for the things you actually got done.") or migrate now? Recommend: stay on legacy until Phase 9, but if you want to swap to ADHD voice now it's a 1-line change in `Copy bank.md` + Welcome view.

---

**Done means every box above is ticked.** If a box can't be ticked, this task is blocked, not done. Report the blocker; do not edit this contract to make termination easier.
