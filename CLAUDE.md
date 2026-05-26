# My Done List

Native iOS port of the My Done List PWA. SwiftUI + Liquid Glass, iPhone-only v1, App Store target. iOS 18+ deployment, built with the Xcode 26 SDK.

> **This file is an INDEX, not a rulebook.** It tells you where to find context for whatever you're about to do. Don't read every linked file — read only the ones that match the current task. Loading rules you don't need is context bloat. Loading rules you do need is the job.

---

## Read first — every session, and after every compaction

1. **`.claude/rules/00-context-grab.md`** — how to grab context without making assumptions. **Mandatory** on session start and after every compaction. Skipping this is the most common cause of bad output in this repo.
2. The **Current state** block below.

## Current state (keep this fresh — update when phase changes)

- **Phase:** R4 complete — D3 composite screens are canonical (`TodayScreen`, `AddEntrySheet_New`). `r4TodayEnabled` flag removed; legacy `TodayView` deleted. Persistent native navbar with trailing `AccountButton` (opens Settings sheet) lives on Today. Phases 0–4.5 done.
- **Next:** Phase 5 — Reflect + Charts.
- **Active branch:** run `git branch --show-current` — don't assume.
- **Bundle ID:** `com.konstantin.donelist` · **iCloud:** `iCloud.com.konstantin.donelist` · **App Group:** `group.com.konstantin.donelist`
- **Apple Developer enrollment:** deferred until Phase 8/10. Do not block on it earlier.

---

## Routing — IF you're doing X, THEN read Y

Read the rule file when its trigger fires. Don't read it speculatively.

- **IF starting any non-trivial task** (>1 file, >30 min, anything user-visible) → create a contract per `.claude/rules/contracts.md` before coding.
- **IF writing or editing Swift code** → `.claude/rules/coding.md`
- **IF touching tokens, components, or anything visual** → `.claude/rules/design-system.md`
- **IF asked design questions or to review / critique design** → `Redesign/References/` (organized by phase: voice-input, celebrations-animations, charts-metrics, navigation). Reference against Figma and vault.
- **IF using iOS 26 / Liquid Glass APIs** → `.claude/rules/liquid-glass.md`
- **IF making a non-trivial architectural choice** (new dep, new pattern, ADR deviation) → `.claude/rules/adrs.md`
- **IF writing or running tests** → `.claude/rules/testing.md`
- **IF writing UI tests that interact with the tab bar** → also check memory `feedback_uitest-tabs` (iOS 26 uses `app.tabBars.buttons["Label"]`; iOS 18 BrandTabBar uses `app.buttons["Label tab"]`)
- **IF writing UI tests that query buttons by label** (e.g. `app.buttons["Done"]`) → also check memory `feedback_uitest-button-ios26` (the iOS 26 keyboard return key exposes `identifier: "Done"`, collides with app buttons; use a case-sensitive predicate. `.accessibilityIdentifier` does NOT propagate through Buttons with custom `ButtonStyle` on iOS 26.)
- **IF preparing a commit, branch, or PR** → `.claude/rules/git-pr.md`
- **IF you need build / test / run commands** → `.claude/rules/build-commands.md`
- **IF you find yourself near `index.html`, `sw.js`, `manifest.json`, `icon-*.png`** at repo root → `.claude/rules/legacy-pwa.md`
- **IF the user asks you to "find bugs / issues / problems"** or any framing that biases toward a finding → `.claude/rules/neutral-prompting.md`
- **IF rules feel contradictory, or you're loading >5 rule files for one task** → `.claude/rules/spa-day.md`
- **IF you feel uncertain about a design call** → `.claude/rules/past-mistakes.md`
- **IF adding or changing a property on any `@Model` class** → `.claude/rules/past-mistakes.md` (SwiftData enum crash pattern)
- **IF suppressing a Swift 6 actor-isolation warning with `nonisolated`** → `.claude/rules/past-mistakes.md` (extensions, not struct body)

---

## Knowledge base — Obsidian vault is the source of truth for product, design, decisions

Vault root: `/Users/konstantinnaumenko/Obsidian/my-startups/My Done List/`. Code is the source of truth for code. The vault is the source of truth for everything else.

> Paths below are absolute so you can `Read` them directly without a `find` pass. **Only read what your current task actually needs** — loading the whole vault is context bloat. The right pattern is: check this index → identify 1–2 relevant docs → read those.

### Top of the funnel — read when current state feels stale

- `/Users/konstantinnaumenko/Obsidian/my-startups/My Done List/00 — Index.md` — **authoritative phase tracker**. Read first if Current state above looks out of date.
- `/Users/konstantinnaumenko/Obsidian/my-startups/My Done List/engineering/redesign-migration-plan.md` — **R0–R8 migration plan**. The "what's done / what's next" table for the redesign track. Read alongside the index.

### Product

- `/Users/konstantinnaumenko/Obsidian/my-startups/My Done List/product/PRD.md` — what we're building and why
- `/Users/konstantinnaumenko/Obsidian/my-startups/My Done List/product/Roadmap.md` — v1 → v1.1 → v1.2
- `/Users/konstantinnaumenko/Obsidian/my-startups/My Done List/product/User stories.md` — JTBD breakdown
- `/Users/konstantinnaumenko/Obsidian/my-startups/My Done List/product/Opportunity tree.md` — companion to the Canvas tree (RICE-table form)
- `/Users/konstantinnaumenko/Obsidian/my-startups/My Done List/product/Success metrics.md` — DAU, retention, log frequency
- `/Users/konstantinnaumenko/Obsidian/my-startups/My Done List/product/Research brief — ADHD domain validation.md` — domain research notes
- `/Users/konstantinnaumenko/Obsidian/my-startups/My Done List/product/Design discovery - improving ambience.md` — ambience research

### Engineering

- `/Users/konstantinnaumenko/Obsidian/my-startups/My Done List/engineering/Architecture.md` — module split, data flow, lifecycle
- `/Users/konstantinnaumenko/Obsidian/my-startups/My Done List/engineering/Phase 1 — project setup.md` — Xcode project + fonts + SwiftPM walkthrough
- `/Users/konstantinnaumenko/Obsidian/my-startups/My Done List/engineering/Phase 5 — Hero contract for Sonnet.md` — phase-specific spec
- `/Users/konstantinnaumenko/Obsidian/my-startups/My Done List/engineering/Testing strategy.md` — unit, snapshot, accessibility
- `/Users/konstantinnaumenko/Obsidian/my-startups/My Done List/engineering/Build & ship runbook.md` — archive, TestFlight, submission
- `/Users/konstantinnaumenko/Obsidian/my-startups/My Done List/engineering/Setup — Xcode preview.md` — Previews + Simulator
- `/Users/konstantinnaumenko/Obsidian/my-startups/My Done List/engineering/Setup — iPhone preview.md` — Personal Team deployment

### Design system (vault — canonical for tokens & component specs)

- `/Users/konstantinnaumenko/Obsidian/my-startups/My Done List/design-system/Tokens.md` — **canonical** tokens. Single source of truth.
- `/Users/konstantinnaumenko/Obsidian/my-startups/My Done List/design-system/Components.md` — PillButton, BigNumeral, ItemRow, ChartBar (specs, not code)
- `/Users/konstantinnaumenko/Obsidian/my-startups/My Done List/design-system/Screen specs.md` — Today / Reflect / Log / Settings / Onboarding
- `/Users/konstantinnaumenko/Obsidian/my-startups/My Done List/design-system/Copy bank.md` — greetings, motivational, reflection (verbatim source)
- `/Users/konstantinnaumenko/Obsidian/my-startups/My Done List/design-system/Iconography.md` — app icon variants, marketing icon
- `/Users/konstantinnaumenko/Obsidian/my-startups/My Done List/design-system/Liquid Glass mapping.md` — native containers per screen

### Decisions (ADRs — read the relevant one before touching its area)

- `/Users/konstantinnaumenko/Obsidian/my-startups/My Done List/decisions/_template — ADR.md` — copy this when writing a new ADR
- `/Users/konstantinnaumenko/Obsidian/my-startups/My Done List/decisions/0001 — Migrate from PWA to native SwiftUI.md`
- `/Users/konstantinnaumenko/Obsidian/my-startups/My Done List/decisions/0002 — iOS 18+ target with iOS 26 SDK fallback.md`
- `/Users/konstantinnaumenko/Obsidian/my-startups/My Done List/decisions/0003 — SwiftData over Core Data + AppStorage.md`
- `/Users/konstantinnaumenko/Obsidian/my-startups/My Done List/decisions/0004 — Outfit font embed under OFL 1.1.md`
- `/Users/konstantinnaumenko/Obsidian/my-startups/My Done List/decisions/0005 — Liquid Glass with #available fallback strategy.md`
- `/Users/konstantinnaumenko/Obsidian/my-startups/My Done List/decisions/0006 — Confetti via TimelineView+Canvas.md`
- `/Users/konstantinnaumenko/Obsidian/my-startups/My Done List/decisions/0007 — Native swipeActions over custom touch tracking.md`
- `/Users/konstantinnaumenko/Obsidian/my-startups/My Done List/decisions/0008 — Add notifications + widget + AppIntent for 4.2 risk mitigation.md`
- `/Users/konstantinnaumenko/Obsidian/my-startups/My Done List/decisions/0009 — iCloud sync via SwiftData + CloudKit.md`
- `/Users/konstantinnaumenko/Obsidian/my-startups/My Done List/decisions/0010 — Voice-first input + FAB navigation.md`
- `/Users/konstantinnaumenko/Obsidian/my-startups/My Done List/decisions/0011 — ADHD-first repositioning.md`
- `/Users/konstantinnaumenko/Obsidian/my-startups/My Done List/decisions/redesign-techdebt-001 — Deferred native-SwiftUI rebuild of botanical illustration.md`

### App Store

- `/Users/konstantinnaumenko/Obsidian/my-startups/My Done List/appstore/Submission checklist.md`
- `/Users/konstantinnaumenko/Obsidian/my-startups/My Done List/appstore/Marketing copy.md`
- `/Users/konstantinnaumenko/Obsidian/my-startups/My Done List/appstore/Privacy policy (source).md`
- `/Users/konstantinnaumenko/Obsidian/my-startups/My Done List/appstore/Support page (source).md`
- `/Users/konstantinnaumenko/Obsidian/my-startups/My Done List/appstore/Review notes draft.md`

### Figma

- File: https://www.figma.com/design/sxbudH3RoGY1uMBcPDWvxq/My-startups?node-id=28-84
- Redesign section root: node `141-1868`
- Hero (Adaptive) component set: node `111:8965`

---

## Repo at a glance

```
My done list/
├── XCode Project/DoneList/        ← the iOS app (DoneList.xcodeproj here)
│   ├── DoneList/                  @main app target — Features/, Data/, Services/, Resources/
│   ├── DoneListTests/             unit + snapshot
│   └── DoneListUITests/           UI tests
├── DesignSystem/                  ← Swift Package (separate target)
│   └── Sources/DesignSystem/{Components,Tokens,Resources}
├── DoneListWidget/                ← Widget extension
├── Redesign/
│   └── References/                ← organized reference screenshots by phase
│       ├── voice-input/           ← Phase 4.5 voice input patterns
│       ├── celebrations-animations/ ← completion feedback & motivational UX
│       ├── charts-metrics/        ← Phase 5 data visualization
│       └── navigation/            ← tab bars, modals, structure patterns
├── index.html, sw.js, manifest.json, icon-*.png  ← LEGACY PWA — read-only reference
└── .claude/
    ├── rules/                     ← rule files this CLAUDE.md routes to
    ├── contracts/                 ← per-task contracts (gitignored or kept; see contracts.md)
    ├── commands/, skills/         ← from prior harness setup; ignore unless explicitly invoked
    └── settings.json
```

---

## Working principles (these override anything else)

- **Be precise about implementation.** If you don't know which approach is right, do a research pass first, decide (or ask), then start a fresh plan to implement. Don't research and implement in the same context window.
- **Don't fill in gaps with assumptions.** If a fact is missing, look it up or ask. Hallucinated context is the #1 cause of bad output.
- **Sycophancy is a bug, not a feature.** Don't manufacture findings to please the prompt. If the answer is "no bug here," say so. Tests are not allowed to be edited to make them pass.
- **End the task explicitly.** A task isn't done until its contract is satisfied — tests pass, screenshots verified, etc. Don't ship stubs and call it done.
- **Less is more.** If a rule isn't firing, archive it. If two rules contradict, trigger spa-day.
