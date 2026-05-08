# Design system — token rules

## The single source of truth

`design-system/Tokens.md` in the Obsidian vault is **canonical**. Swift mirrors the vault, never the other way around. If the vault and Swift disagree, the vault wins and Swift is wrong.

The legacy PWA's `index.html` / CSS is **not** a source of truth. If `Tokens.md` and `index.html` disagree, follow `Tokens.md`.

## Hard rules

- **NEVER hardcode** `Color(red:green:blue:)`, hex values, raw spacing numbers, type sizes, or corner radii in feature code. Import from the `DesignSystem` Swift package.
- **NEVER inline component styles** that duplicate `PillButton`, `BigNumeral`, `ItemRow`, `ChartBar`, or `BrandTabBar`. If you need a variant, extend the component (add a parameter, a modifier, or a sibling component in `DesignSystem/Sources/DesignSystem/Components/`).
- **When tokens change**, update `design-system/Tokens.md` first, then `DesignSystem/Sources/DesignSystem/Tokens/` to match. Never the reverse — that creates drift.

## When you can't find a token

- Check `design-system/Tokens.md` first.
- Then check `design-system/Screen specs.md` for screen-specific values that haven't been promoted to tokens yet.
- Then check the Figma node referenced in the task.
- If still missing — **ask the user**. Do not invent a value.

## Liquid Glass

Glass materials and iOS-26-only design APIs have their own gating rules. See `liquid-glass.md`.
