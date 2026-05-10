# Testing — read when writing or running tests

## The end-of-task signal

A task is **not done** until:

- The full test suite passes (no failures, no skips you introduced).
- The build is clean — no new warnings.
- Any contract-mandated screenshots have been captured and visually verified (see `contracts.md`).

If any of these aren't true, the task is in progress, not done. Don't claim completion until they are.

## Hard rules

- **DO NOT edit tests to make them pass.** If a test fails, the code is wrong (or the test was wrong before — check git blame). Editing the test to silence a failure is a sycophancy bug, not progress.
- If a test genuinely needs updating because the spec changed → **say so to the user, propose the change, and update the contract** before editing the test. Then update the test as a deliberate decision, not a fix-the-symptom move.
- New behavior gets new tests. If the contract says "X must work," add a test that fails until X works, then make it pass.

## Running tests

See `build-commands.md` for the canonical xcodebuild incantations. From Xcode: ⌘U.

After **every** code change, run the suite. Don't batch up failures — each change should be evaluated against a green baseline.

## Test layers (per `engineering/Testing strategy.md` in the vault)

- **Unit** — `DoneListTests/`. Logic, store reducers, services. Fast.
- **Snapshot** — `DoneListTests/Snapshots/`. Visual regression on components. Re-record only after a deliberate visual change, never to chase a failure.
- **Accessibility** — VoiceOver labels, Dynamic Type xxxLarge, Reduce Motion. Every interactive element needs a label.
- **UI** — `DoneListUITests/`. End-to-end flows. Slowest, smallest set.

## When asked to "fix a flaky test"

That's a `neutral-prompting.md` situation — investigate, don't presume the test or the code is at fault. Report findings.
