# {Task slug} — contract

> Copy this file to `<short-task-slug>_CONTRACT.md` in this same directory. Fill in every section. Confirm with the user before starting work. The task is not done until every checkbox is satisfied.

## Outcome

One sentence: what will the user be able to do that they couldn't before?

## Tests that must pass

- [ ] `DoneListTests/<file>::<testName>` — describe what it covers
- [ ] (add new tests here if the behavior is new)
- [ ] Full suite green: `xcodebuild ... test` exits 0

## Visual verification

For any user-visible change, capture and verify on **both** iOS 18 and iOS 26 (per `liquid-glass.md`).

- [ ] Screenshot: `<screen>` on iPhone 15 Pro / iOS 18.x — looks like Figma node `<node-id>`
- [ ] Screenshot: `<screen>` on iPhone 16 Pro / iOS 26.x — Liquid Glass renders correctly
- [ ] VoiceOver pass: every interactive element has a label
- [ ] Dynamic Type xxxLarge: layout doesn't break
- [ ] Reduce Motion: animations degrade gracefully (e.g., confetti → static check)

## Files that must NOT change

- [ ] `index.html`, `sw.js`, `manifest.json`, `icon-*.png` (legacy PWA — see `legacy-pwa.md`)
- [ ] (anything else this task should not touch)

## ADRs honored / referenced

- ADR-XXXX — <title>
- (new ADR if the task creates one)

## Acceptance criteria

- [ ] (non-test checks unique to this task)
- [ ] No new build warnings
- [ ] No hardcoded tokens introduced (per `design-system.md`)
- [ ] PR description references this contract path and the ADR(s) above

## Out of scope

(things the user might expect to be in this task but explicitly aren't — call them out)

---

**Done means every box above is ticked.** If a box can't be ticked, this task is blocked, not done. Report the blocker; do not edit this contract to make termination easier.
