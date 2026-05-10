# Task contracts — how non-trivial work ends

A **contract** is a per-task file that says exactly what must be true before the task is allowed to terminate. It's how an agent (or a user) knows the task is done — instead of guessing.

## When to create one

For any non-trivial task: more than one file changed, more than ~30 minutes of work, anything user-visible, anything that ships in a PR. If in doubt, create one.

## How

1. Copy `.claude/contracts/_template.md` to `.claude/contracts/<short-task-slug>_CONTRACT.md`.
2. Fill in every section — don't leave placeholder text.
3. Confirm the contract with the user before coding starts.
4. Reference the contract path in the PR description.

## The contract is binding

- The task is **not done** until every checkbox is satisfied.
- **Do not edit the contract to make termination easier.** That defeats the purpose. If a requirement turns out to be wrong, talk to the user first, then update the contract as a deliberate change with a note explaining why.
- If a test or screenshot the contract requires can't be produced, the task is **blocked**, not done. Report the blocker.

## What goes in a contract

- **Outcome** — one sentence describing what the user will be able to do that they couldn't before.
- **Tests that must pass** — specific test names or files. New tests get added here.
- **Screenshots / visual verification** — which screens, which simulators (iOS 18 + iOS 26 for any visual change, see `liquid-glass.md`), what to look for.
- **Files that must NOT change** — e.g., legacy PWA at repo root, unrelated features.
- **ADRs honored / referenced** — list them.
- **Acceptance criteria** — additional checks that aren't tests (e.g., "Reduce Motion turns confetti into a static check").

## Why this rule exists

Agents are good at starting tasks and bad at ending them. Without an explicit termination signal, they ship stubs and call it done. A contract converts "is this done?" from a vibes question into a checklist.

## Cleanup

Contracts for shipped tasks can be left in `.claude/contracts/` as a record, or deleted after the PR merges — your call. Don't recycle a slug for a different task; create a new file.
