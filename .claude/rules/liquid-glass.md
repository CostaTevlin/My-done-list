# Liquid Glass / iOS version gating

Deployment target is **iOS 18.0**. The app is built with the **Xcode 26 SDK**, which means iOS 26 APIs compile but will crash or silently break on iOS 18 devices unless guarded.

## Hard rules

- iOS 26 Liquid Glass APIs (`tabViewBottomAccessory`, `Tab(role: .search)`, glass materials, `glassEffect(...)`, etc.) **MUST** be wrapped in `#available(iOS 26.0, *)` with a working iOS 18 fallback. See ADR-0005.
- **A build that compiles on iOS 26 but renders broken or crashes on iOS 18 is broken.** Treat it as a failed task, not a partially-done one.
- **Test on both iOS 18.x and iOS 26.x simulators** before merging anything visual. The contract for visual changes (see `contracts.md`) should include both.

## What "working iOS 18 fallback" means

- The screen still functions on iOS 18 — no crashes, no missing controls, no broken layout.
- The fallback can be visually plainer (no glass, simpler material) but the user can still complete the task.
- See `design-system/Liquid Glass mapping.md` in the vault for the per-screen fallback strategy.

## Pattern reference

```swift
if #available(iOS 26.0, *) {
    SomeView()
        .glassEffect(.regular)
} else {
    SomeView()
        .background(Material.regular)
}
```

If you find yourself writing `if #available` more than three times in one view, that's a signal to pull the gated branch into a small wrapper component in `DesignSystem`.
