# Coding rules — read before writing or editing Swift

## Hard rules

- **NEVER hardcode colors, spacing, type, or radii** in feature code. Always import from the `DesignSystem` package. See `design-system.md` for the full token rule.
- **ALWAYS read a file before editing it.** No exceptions.
- **Files stay under ~500 lines.** Split features into multiple files under `Features/<Feature>/` when they grow.
- **NEVER commit secrets** — `.env`, signing certs, provisioning profiles, API keys, `*.p8`, `*.p12`. If you see one, stop and tell the user.

## Conventions (these are decisions — deviation needs an ADR; see `adrs.md`)

- **State.** Prefer `@Observable` stores (e.g., `DoneStore`) over per-view `ViewModel` classes. Add a ViewModel only when the view has logic that genuinely doesn't belong on the store.
- **Persistence.** SwiftData + CloudKit (private DB). See ADR-0003 and ADR-0009. Schema migrations need a new ADR.
- **Animations / confetti.** `TimelineView` + `Canvas` only (ADR-0006). No third-party particle libs.
- **Swipes.** Native `swipeActions` only (ADR-0007). Don't build custom touch tracking.
- **Fonts.** Outfit (OFL 1.1, ADR-0004). Registered in `Info.plist > UIAppFonts`. Don't add other custom fonts without an ADR.
- **Copy.** Pull all user-facing strings from `Services/CopyBank.swift`, mirroring `design-system/Copy bank.md` verbatim. If a string is missing from CopyBank, add it there first.
- **Haptics.** Route through `Services/HapticEngine.swift` — it respects the Settings toggle. Don't call `UIImpactFeedbackGenerator` directly.
- **Accessibility.** Every interactive element gets a label. Test with VoiceOver, Dynamic Type xxxLarge, and Reduce Motion. Confetti must respect Reduce Motion.

## Scope (v1)

- **iPhone-only.** No iPad-specific layouts, no Watch, no Mac Catalyst until v1.1+ (see Roadmap).
- **Light mode only by default.** Dark mode is Phase 9 — don't ship half-finished dark styling earlier.

## When uncertain

- If the convention isn't covered above and isn't in an ADR → check `decisions/` in the vault, then propose a new ADR if nothing fits. See `adrs.md`.
- If you're about to add a dependency or a new pattern → that's an ADR-shaped decision. Stop coding, see `adrs.md`.
