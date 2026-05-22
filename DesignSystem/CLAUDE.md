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
design-system/Tokens.md          ← canonical (Markdown, in Obsidian vault)
        │
        ▼
Tokens/Slowly/Slowly+*.swift     ← Slowly.* namespace (D1, the active design system)
Tokens/Color+Tokens.swift        ← Color.* extension (Phase 4/5 intermediate — will be deleted at R8)
        │
        ▼
Resources/Assets.xcassets/slowly*.colorset   ← Slowly.Color.* values live here
        │
        ▼
Components/*.swift               ← consume via Slowly.Color.* / Slowly.Font.* / Slowly.Spacing.*
        │
        ▼
app + widget feature code        ← consume only via Components or Slowly.* token APIs
```

**Active token namespace is `Slowly.*`.** For any new component or D2/D3 work, use `Slowly.Color.textPrimary`, `Slowly.Font.bodyText`, `Slowly.Spacing.md`, etc. The `Color.textPrimary` / `Font.bodyText` flat extensions in `Color+Tokens.swift` / `Font+System.swift` are the Phase 5 intermediate that will be removed at R8 — do not add new call sites to them.

If you need a token that doesn't exist: **update `Tokens.md` first**, then add to the appropriate `Slowly+*.swift` file and add a matching `slowly*.colorset`.

---

## Layout

```
DesignSystem/
├── Package.swift           swift-tools 6.0 · iOS 18+ · macOS 14+ (host-build only)
├── Sources/DesignSystem/
│   ├── Tokens/
│   │   ├── Slowly/                   ← ACTIVE namespace (D1, use these for all new work)
│   │   │   ├── Slowly+Color.swift    Slowly.Color.textPrimary, .surfaceApp, .accentPrimary, …
│   │   │   ├── Slowly+Font.swift     Slowly.Font.bigNumeral (130pt), .display (40pt), .bodyText, …
│   │   │   ├── Slowly+Spacing.swift  Slowly.Spacing.xs … .xxxl + .screenTop / .screenBottom
│   │   │   ├── Slowly+Radii.swift    Slowly.Radius.card (20pt), .button (32pt), .sheet (40pt), .fab
│   │   │   └── Slowly+Material.swift Slowly.Material.fallback + iOS 26 glass params
│   │   ├── Color+Tokens.swift        Color.textPrimary, .accentPrimary, … (Phase 5 intermediate — delete at R8)
│   │   ├── Color+Palette.swift       internal palette primitives (paletteNeutral900, paletteSage600, …)
│   │   ├── Font+System.swift         Font.display, .bigNumeral, … (Phase 5 intermediate — delete at R8)
│   │   ├── Spacing.swift             old Spacing.xs … .bottomSafe (Phase 4 — delete at R8)
│   │   ├── Radius.swift              old Radius.card, .pill, .chip (Phase 4 — delete at R8)
│   │   └── Motion.swift
│   ├── Components/
│   │   ├── PillButton.swift     PillButtonStyle + .pillButton() (auto-upgrades to .glassProminent on iOS 26)
│   │   ├── BigNumeral.swift     hero counter on Today
│   │   ├── ChartBar.swift       Reflect weekly bars
│   │   ├── BrandTabBar.swift    fallback tab bar for iOS 18-25
│   │   └── PulseRing.swift      voice-mode concentric pulsing ring (Phase 4.5)
│   └── Resources/Assets.xcassets/
│       ├── slowly*.colorset     Slowly.Color.* backing assets (11 tokens, slowly prefix)
│       ├── palette*.colorset    internal palette backing assets
│       └── tokenPreviewView.swift   gallery — renders every Slowly.* token
└── Tests/DesignSystemTests/      snapshot + token parity tests
```

---

## Hard rules (package-specific)

The repo-wide no-hardcoding rule is in `.claude/rules/design-system.md`. The rules below are specific to this Swift Package.

- **`Slowly.Color.*` tokens are backed by asset catalog entries — bundle is already correct.** The `Slowly+Color.swift` file passes `bundle: .module` internally; do not pass a bundle when calling `Slowly.Color.*` from feature code. If you add a new `Slowly.Color` token, use `SwiftUI.Color("slowlyXxx", bundle: .module)` inside `Slowly+Color.swift` and add a matching `slowlyXxx.colorset` to `Resources/Assets.xcassets/`.
- **SF Pro tokens (`Slowly.Font.*`) are system fonts — no custom bundle or `relativeTo:` needed.** They scale with Dynamic Type automatically. For the editorial scale (bigNumeral 130pt, display 40pt), add AX5 snapshots before merging any component that uses them.
- **No `import UIKit`.** Keep sources SwiftUI-only so `swift build` works on the macOS host (used in CI / Xcode Previews on Apple Silicon). UIKit interop belongs in the app target.
- **Liquid Glass upgrades live inside the component**, not the call site. Example: `PillButton` ships one public `.pillButton()` modifier that internally chooses `.buttonStyle(.glassProminent)` on iOS 26 and `PillButtonStyle()` on iOS 18-25. Feature code never branches on iOS version. (See `.claude/rules/liquid-glass.md` for the gating rule.)
- **`public` is a contract.** Anything `public` here gets reused by the app and widget — renaming it later means a coordinated change across targets. Default to `internal`; promote to `public` only when a consumer needs it.
- **New dependencies need an ADR** (per `.claude/rules/adrs.md`). No SwiftLint, swift-snapshot-testing add-ons, or animation libs without one.

---

## Conventions

- One component per file, named after the type (`PillButton.swift` exports `PillButtonStyle` + `.pillButton()`).
- Every public symbol gets a doc comment with the matching pixel/hex value and a `See:` line pointing back to `design-system/Tokens.md` or `Components.md`.
- Phase tag in the file header (`// Phase: 1`) so it's easy to grep what landed when.
- Color asset names in the catalog match the `Slowly.Color` property name with a `slowly` prefix (`Slowly.Color.textPrimary` ↔ `slowlyTextPrimary.colorset`). Both Light and Dark appearances are required even if Dark is provisional — Phase 9 finalizes them.
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

- A new `Slowly.Color` token requires three matching changes: a `public static let` in `Tokens/Slowly/Slowly+Color.swift`, a `slowlyXxx.colorset` folder under `Resources/Assets.xcassets/` with both Light and Dark JSON, and (often) an updated snapshot. Easy to forget one. Update `Tokens.md` first.
- iOS 26 glass styles (`.glass`, `.glassProminent`, `.buttonStyle(.glass)`) are NOT available on the macOS host — every use must compile-out via `#if os(iOS)` + `#available(iOS 26.0, *)` or the package fails to build.
- The widget target reuses everything here, so any breaking change is doubly breaking. Run the widget preview after touching `Color+Tokens` or `Spacing`.
- Snapshot tests live in `Tests/DesignSystemTests/` and currently include a stub — when you add a Component, add a Light + Dark snapshot pair before merging.
