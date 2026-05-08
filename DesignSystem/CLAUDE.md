# DesignSystem (Swift Package)

Local Swift package shared by the app target (`DoneList`) and the widget extension (`DoneListWidget`). Hosts the color asset catalog, the Outfit type scale, spacing/radius/motion tokens, and the brand components.

> Read the root `CLAUDE.md` first. This file adds **only rules specific to this package** — anything that applies repo-wide lives in `.claude/rules/*.md` at the repo root.

## Cross-refs to root rules

When working in this package, the following root rule files are also in scope:

- **Tokens, components, no-hardcoding** → `.claude/rules/design-system.md`
- **iOS 26 / Liquid Glass gating** → `.claude/rules/liquid-glass.md`
- **New deps / new patterns / ADRs** → `.claude/rules/adrs.md`
- **Tests / end-of-task signal** → `.claude/rules/testing.md`

Read the relevant ones — don't read all of them.

---

## Source-of-truth chain (do not invert)

```
design-system/Tokens.md   ← canonical (Markdown, in Obsidian vault)
        │
        ▼
Sources/DesignSystem/Tokens/*.swift   ← mirrors Tokens.md, never the other way
        │
        ▼
Resources/Assets.xcassets/token*.colorset   ← color values live here
        │
        ▼
Sources/DesignSystem/Components/*.swift   ← consume via Color.tokenX / Font.tokenX / Spacing.x
        │
        ▼
app + widget feature code   ← consume only via Components or token APIs
```

If you need a token that doesn't exist: **update `Tokens.md` first**, then mirror it into Swift here.

---

## Layout

```
DesignSystem/
├── Package.swift           swift-tools 6.0 · iOS 18+ · macOS 14+ (host-build only)
├── Sources/DesignSystem/
│   ├── Tokens/
│   │   ├── Color+Tokens.swift   public Color.tokenWhite, .tokenCharcoal, …
│   │   ├── Font+Outfit.swift    Font.outfit(size, weight, relativeTo:) + named tokens
│   │   ├── Spacing.swift        Spacing.xs … xxxl + bottomSafe
│   │   ├── Radius.swift
│   │   └── Motion.swift
│   ├── Components/
│   │   ├── PillButton.swift     PillButtonStyle + .pillButton() (auto-upgrades to .glassProminent on iOS 26)
│   │   ├── BigNumeral.swift     the 120pt counter on Today
│   │   ├── ChartBar.swift       Reflect weekly bars
│   │   └── BrandTabBar.swift    fallback tab bar for iOS 18-25
│   └── Resources/Assets.xcassets/
│       ├── tokenWhite.colorset       (every color token has a Light + Dark appearance)
│       ├── tokenCharcoal.colorset
│       └── … (one .colorset per Color+Tokens declaration)
└── Tests/DesignSystemTests/      snapshot + token parity tests
```

---

## Hard rules (package-specific)

The repo-wide no-hardcoding rule is in `.claude/rules/design-system.md`. The rules below are specific to this Swift Package.

- **Color references MUST use `Color("name", bundle: .module)`.** Default bundle resolves to the app, not this package — colors will silently fall back to black at runtime if `.module` is omitted. Add new colors to `Color+Tokens.swift` so consumers can't get this wrong.
- **Custom fonts MUST pass `relativeTo:`** in `Font.custom`. Without it, Outfit ignores Dynamic Type and the accessibility audit fails. Use the named tokens (`Font.tokenBody`, `.tokenBigNumeral`, etc.) — they already do this.
- **No `import UIKit`.** Keep sources SwiftUI-only so `swift build` works on the macOS host (used in CI / Xcode Previews on Apple Silicon). UIKit interop belongs in the app target.
- **Liquid Glass upgrades live inside the component**, not the call site. Example: `PillButton` ships one public `.pillButton()` modifier that internally chooses `.buttonStyle(.glassProminent)` on iOS 26 and `PillButtonStyle()` on iOS 18-25. Feature code never branches on iOS version. (See `.claude/rules/liquid-glass.md` for the gating rule.)
- **`public` is a contract.** Anything `public` here gets reused by the app and widget — renaming it later means a coordinated change across targets. Default to `internal`; promote to `public` only when a consumer needs it.
- **New dependencies need an ADR** (per `.claude/rules/adrs.md`). No SwiftLint, swift-snapshot-testing add-ons, or animation libs without one.

---

## Conventions

- One component per file, named after the type (`PillButton.swift` exports `PillButtonStyle` + `.pillButton()`).
- Every public symbol gets a doc comment with the matching pixel/hex value and a `See:` line pointing back to `design-system/Tokens.md` or `Components.md`.
- Phase tag in the file header (`// Phase: 1`) so it's easy to grep what landed when.
- Color asset names in the catalog match the Swift property name exactly (`tokenCharcoal` ↔ `tokenCharcoal.colorset`). Both Light and Dark appearances are required even if Dark is provisional — Phase 9 finalizes them.
- Component previews live in the same file inside `#Preview { … }`, with both Light and Dark variants.

---

## Build & test

```bash
# from this package directory
swift build              # host-build sanity check (macOS)
swift test               # runs DesignSystemTests on host

# inside Xcode the package is built as part of the DoneList scheme
# ⌘B builds the umbrella · ⌘U runs the package tests too
```

---

## Things to watch for

- A new color in `Tokens.md` requires three matching changes in this package: a `public static let` in `Color+Tokens.swift`, a `.colorset` folder under `Resources/Assets.xcassets/` with both Light and Dark JSON, and (often) an updated snapshot test. Easy to forget one.
- iOS 26 glass styles (`.glass`, `.glassProminent`, `.buttonStyle(.glass)`) are NOT available on the macOS host — every use must compile-out via `#if os(iOS)` + `#available(iOS 26.0, *)` or the package fails to build.
- The widget target reuses everything here, so any breaking change is doubly breaking. Run the widget preview after touching `Color+Tokens` or `Spacing`.
- Snapshot tests live in `Tests/DesignSystemTests/` and currently include a stub — when you add a Component, add a Light + Dark snapshot pair before merging.
