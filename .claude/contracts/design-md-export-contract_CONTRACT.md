# DESIGN.md export contract — contract

## Outcome

User gets a root-level `DESIGN.md` that accurately captures this app's visual system in valid design-md YAML tokens plus narrative guidance.

## Tests that must pass

- [ ] `npx @google/design.md lint DESIGN.md` exits 0

## Visual verification

- [ ] Compared token values and style language against app UI source composition in Today, Reflect, Log Sheet, Onboarding, and tab shell views
- [ ] Confirmed light/dark values for all core color tokens from color asset catalog
- [ ] Verified motion/reduce-motion intent is documented

## Files that must NOT change

- [ ] `index.html`, `sw.js`, `manifest.json`, `icon-*.png` (legacy PWA)
- [ ] Swift source files and app behavior

## ADRs honored / referenced

- ADR-0010 — Voice-first input + FAB navigation

## Acceptance criteria

- [ ] YAML frontmatter includes structured tokens for colors, typography, spacing, radii, elevation, motion, and shadows
- [ ] Markdown body describes design intent beyond raw token values
- [ ] `DESIGN.md` is self-contained (no codebase paths or variable references)
- [ ] No new lints introduced

## Out of scope

- Running iOS simulator screenshots in this task
- Editing existing design tokens or app UI implementation

---

**Done means every box above is ticked.** If a box can't be ticked, this task is blocked, not done.
