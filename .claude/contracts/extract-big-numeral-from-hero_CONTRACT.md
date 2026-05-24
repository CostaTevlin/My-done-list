# Extract BigNumeral from AdaptiveHero — contract

> Aligns Swift with Figma node `111:8965` (hero component set, Type=Compact | Expanded). In Figma the BigNumeral lives *outside* the published Hero component; the consuming screen composes `BigNumeral + Hero` itself. Today's Swift renders the numeral inline inside `AdaptiveHero.numeralRow`, which is a parity bug.

## Outcome

Consuming screens (`TodayScreen`) compose the day's count via `BigNumeral` placed above `AdaptiveHero`, matching Figma's "Hero excludes BigNumeral" composition. `HeroState.today` no longer carries `count`.

## API change

- `HeroState.today(date:count:headline:subtitle:)` → `HeroState.today(date:headline:subtitle:)`
- `AdaptiveHero.numeralRow` removed; `AdaptiveHero` body no longer renders the numeral.
- `AdaptiveHero`'s accessibility label for `.today` drops the count prefix (the composed `BigNumeral` carries its own a11y label "X thing(s) logged today").

## Files touched

- `DesignSystem/Sources/DesignSystem/Components/AdaptiveHero.swift` — remove `count`, drop numeral render, update previews & a11y label.
- `DesignSystem/Sources/DesignSystem/TokenPreviewView.swift` — D3 gallery preview updated to compose `BigNumeral + AdaptiveHero`.
- `DesignSystem/Tests/DesignSystemTests/D3CompositeTests.swift` — update `.today` constructor & a11y-label assertion to match new API.
- `XCode Project/DoneList/DoneList/Features/Today/TodayScreen.swift` — `heroState` drops `count`; populated list inserts a `BigNumeral` row above `AdaptiveHero`.

## Files that must NOT change

- [ ] `Hero.swift`, `HeroBlock.swift` (deprecated D2 hero components — out of scope)
- [ ] `BigNumeral.swift` (already correct — composed by callers)
- [ ] `EmptyTodayScreen.swift` (uses `.empty` state, which never had `count`)
- [ ] `index.html`, `sw.js`, `manifest.json`, `icon-*.png` (legacy PWA)

## Tests that must pass

- [ ] `DesignSystemTests/D3CompositeTests::test_adaptiveHero_todayStateCompiles` — updated, still passes
- [ ] `DesignSystemTests/D3CompositeTests::test_adaptiveHeroTodayAccessibilityLabel` — updated to reflect new label shape (no count prefix)
- [ ] `DesignSystemTests/D3CompositeTests::test_heroStateEquality` — `.today(...)` cases use new signature
- [ ] `DoneListTests/TodayScreenSnapshotTests::testSnapshot_todayScreen_populated_iOS18` — populated screen still renders without crashing, snapshot attached
- [ ] Full DesignSystem package test (`swift test`) green
- [ ] Full Xcode test suite (`xcodebuild ... test`) green

## Visual verification

- [ ] `xcodebuild build` clean on iOS 18 simulator (iPhone 15 Pro)
- [ ] `xcodebuild build` clean on iOS 26 simulator (iPhone 16 Pro)
- [ ] Today screen populated path: BigNumeral renders above the date+headline block — same visual order the inline numeral occupied before
- [ ] Today screen empty path: no regression (uses `.empty` state — untouched)
- [ ] Reduce Motion: `.numericText()` transition still respected by BigNumeral (it owns the transition modifier)

## ADRs honored / referenced

- ADR-0010 — Nav shell (Today/RootTabView untouched)
- ADR-0005 — Liquid Glass gating (no iOS 26 APIs added)
- Component is unchanged in token usage — `design-system.md` no-hardcoding rule observed throughout

## Acceptance criteria

- [ ] `git grep -n "count:" DesignSystem/Sources/DesignSystem/Components/AdaptiveHero.swift` returns nothing (no `count` parameter survives in the file)
- [ ] No new build warnings
- [ ] No hardcoded tokens introduced
- [ ] PR description references this contract path and Figma node `111:8965`

## Out of scope

- Migrating `BigNumeral` to the `Slowly.*` namespace (`Font.bigNumeral` → `Slowly.Font.bigNumeral`). The flat extension is the documented Phase 5 intermediate; R8 cleanup will remove it. Leaving as-is per CLAUDE.md.
- Editing `Hero.swift` / `HeroBlock.swift` (deprecated D2 — separate cleanup pass).
- Updating `Components.md` in the vault (the "Implementation deltas" note in `AdaptiveHero.swift` header should be updated, but the vault doc is owned by a separate doc-export contract).

---

**Done means every box above is ticked.** If a box can't be ticked, this task is blocked, not done.
