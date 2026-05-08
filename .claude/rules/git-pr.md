# Git, branches, commits, PRs

## Branches

- Always branch from `main`.
- Naming:
  - Features: `feat/<slug>` (e.g., `feat/today-fab`)
  - Fixes: `fix/<slug>` (e.g., `fix/confetti-reduce-motion`)
  - ADR-driven work: `adr-<n>-<slug>` (e.g., `adr-0010-voice-input`)
- Never assume which branch you're on. `git branch --show-current` first.

## Commits

Conventional-commit style:

- `feat(today): voice-first input for new entries`
- `fix(confetti): respect reduce-motion`
- `refactor(store): split DoneStore into per-feature stores`
- `chore(deps): bump SnapshotTesting to 1.18`
- `docs(adr): add ADR-0011 on schema migration approach`

The scope (in parens) is the feature or module touched. Keep it short.

## PRs

PR description must include:

- **What** changed in 1–2 sentences.
- **Why** — link the ADR(s) the PR implements (`Implements ADR-0010`).
- **Phase** — which Phase from `00 — Index.md` this advances.
- **Verification** — what was tested, what screenshots were taken, what simulators were used (iOS 18 + iOS 26 for visual changes).
- **Contract** — link to `.claude/contracts/<task>_CONTRACT.md` if one exists.

Squash-merge into `main`.

## Before opening the PR

- `git status` shows only intended changes — no stray edits, no committed secrets, no `.DS_Store`.
- Tests pass. Build is clean. (See `testing.md`.)
- Any ADR referenced in the PR is actually merged or in the same PR.
- The contract is fully satisfied (see `contracts.md`).
