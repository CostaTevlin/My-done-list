# Past mistakes — read once, internalize

Each entry below is a real mistake that happened in this codebase. Read this file when you feel uncertain about a design call, or when a task is in an area listed below.

## Treating the PWA as the design source of truth

**What happened:** Used colors / spacing from `index.html` and CSS instead of `design-system/Tokens.md`.
**Rule:** `Tokens.md` is canonical, even when it disagrees with `index.html`. See `design-system.md`.

## Adding iOS-26-only modifiers without an `#available` guard

**What happened:** Used `glassEffect`, `tabViewBottomAccessory`, or `Tab(role: .search)` directly. Compiled fine on iOS 26, crashed or rendered nothing on iOS 18.
**Rule:** Every iOS-26-only API must be `#available(iOS 26.0, *)` with a working iOS 18 fallback. See `liquid-glass.md`. Test both simulators.

## Hardcoding `Color(red:green:blue:)`

**What happened:** Inlined RGB values in feature code instead of importing from the `DesignSystem` package. Drift from Figma the moment tokens change.
**Rule:** No raw color/spacing/type/radius values in feature code. Ever. See `design-system.md`.

## Editing `index.html` when asked to "fix the layout"

**What happened:** User said "the Today layout looks wrong, fix it." Edited the legacy PWA `index.html` instead of the SwiftUI `TodayView`. Lost a session.
**Rule:** Always check the file path before editing. If it ends in `.html`, `.js`, `manifest.json`, or `icon-*.png` at repo root, you're in the wrong file. See `legacy-pwa.md`.

## Implementing a major change without checking for an existing ADR

**What happened:** Started building a feature using a pattern that contradicted ADR-0006 (animation strategy). Got 80% done before noticing.
**Rule:** Before any non-trivial architectural choice, search `decisions/` for a matching ADR. If found, follow it. If not found and the choice is real, write a new ADR first. See `adrs.md`.

## Manufacturing a bug to satisfy a prompt

**What happened:** User said "find the bug in the data store." There was no bug. The agent invented one and "fixed" it, breaking working code.
**Rule:** Use neutral framing for any investigation. If there's no bug, say so. See `neutral-prompting.md`.

## Editing a test to make it pass

**What happened:** A snapshot test failed after a layout change. The agent re-recorded the snapshot to silence the failure, hiding a real visual regression.
**Rule:** Tests cannot be edited to make them pass. If a test needs updating because the spec changed, that's a deliberate decision that goes through the contract. See `testing.md`.

## Adding a SwiftData enum property without String backing

**What happened:** Added `var source: EntrySource = .text` directly to a `@Model` class. Existing simulator rows had no column — SwiftData tried to cast `nil → EntrySource` and crashed on launch.
**Rule:** Always store enums as `var sourceRaw: String = "rawValue"` with a computed `var source: EntrySource { get/set }` accessor. SwiftData handles String column defaults correctly; enum defaults are not safe. See memory: `feedback_swiftdata-enum-migration`.

## Putting `nonisolated init(from:)` in the struct body

**What happened:** Added a `nonisolated init(from decoder: Decoder)` inside the struct body to suppress a Swift 6 actor-isolation warning. This silently suppressed the memberwise init, causing "extra arguments" build errors at every call site.
**Rule:** `nonisolated` Codable/Equatable conformances must go in same-file **extensions** (not the body). Extensions don't suppress memberwise inits. The extension can still access `private CodingKeys`. See memory: `feedback_nonisolated-codable`.

## When to add to this file

When a session ends with the user saying "you got X wrong" and X is the kind of thing future sessions will plausibly hit again. Keep entries short; the rule that prevents the mistake belongs in its own rule file, with this entry pointing at it.
