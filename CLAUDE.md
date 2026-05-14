# My Done List

Native iOS port of the My Done List PWA. SwiftUI + Liquid Glass, iPhone-only v1, App Store target. iOS 18+ deployment, built with the Xcode 26 SDK.

> **This file is an INDEX, not a rulebook.** It tells you where to find context for whatever you're about to do. Don't read every linked file — read only the ones that match the current task. Loading rules you don't need is context bloat. Loading rules you do need is the job.

---

## Read first — every session, and after every compaction

1. **`.claude/rules/00-context-grab.md`** — how to grab context without making assumptions. **Mandatory** on session start and after every compaction. Skipping this is the most common cause of bad output in this repo.
2. The **Current state** block below.

## Current state (keep this fresh — update when phase changes)

- **Phase:** 4.5 in progress — Voice-first input + FAB navigation (ADR-0010). Phases 0–4 done.
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
- **IF preparing a commit, branch, or PR** → `.claude/rules/git-pr.md`
- **IF you need build / test / run commands** → `.claude/rules/build-commands.md`
- **IF you find yourself near `index.html`, `sw.js`, `manifest.json`, `icon-*.png`** at repo root → `.claude/rules/legacy-pwa.md`
- **IF the user asks you to "find bugs / issues / problems"** or any framing that biases toward a finding → `.claude/rules/neutral-prompting.md`
- **IF rules feel contradictory, or you're loading >5 rule files for one task** → `.claude/rules/spa-day.md`
- **IF you feel uncertain about a design call** → `.claude/rules/past-mistakes.md`

---

## Knowledge base — Obsidian vault is the source of truth for product, design, decisions

Vault root: `~/Documents/Obsidian/my-startups/My Done List/`. Code is the source of truth for code. The vault is the source of truth for everything else.

- `00 — Index.md` — Phase tracker is authoritative. Read this when current state above feels stale.
- `product/PRD.md`, `product/Roadmap.md`
- `engineering/Architecture.md`, `engineering/Build & ship runbook.md`, `engineering/Testing strategy.md`, `engineering/Setup — iPhone preview.md`
- `design-system/Tokens.md` — **canonical** tokens. Single source of truth.
- `design-system/Components.md`, `design-system/Screen specs.md`, `design-system/Copy bank.md`, `design-system/Liquid Glass mapping.md`
- `decisions/` — ADRs 0001–0010. Read the relevant ADR before touching that area.
- `appstore/Submission checklist.md`, `appstore/Review notes draft.md`

**Figma:** https://www.figma.com/design/sxbudH3RoGY1uMBcPDWvxq/My-startups?node-id=28-84

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
