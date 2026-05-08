# Spa day — periodic rule consolidation

Rules and skills accumulate. Over time they:

- Contradict each other.
- Cover scenarios that don't fire anymore.
- Bloat context every time CLAUDE.md is read.

Spa day is a deliberate cleanup pass. Run it when the user invokes it explicitly, OR when you notice any of:

- Two rule files give conflicting guidance for the same scenario.
- You're loading >5 rule files for a single task.
- A rule references files, ADRs, or phases that no longer exist.
- You've found yourself ignoring a rule because it's clearly outdated.

## How to run it

1. **List all rule files** in `.claude/rules/` and all routing entries in `CLAUDE.md`.
2. **For each rule, ask:**
   - Has it fired in the last few sessions? (Best signal: does its trigger still match real tasks?)
   - Does it still match how the project actually works?
   - Does it contradict any other rule?
   - Is it a duplicate of another rule with a slightly different framing?
3. **Surface findings to the user as a short list:**
   - Rules to merge (and into what)
   - Rules to delete
   - Rules where the user's preference seems to have changed and we should update
   - Contradictions that need a decision
4. **Wait for the user's decision before editing rule files.** Spa day is collaborative — agents have a bias toward keeping rules they can see; the user knows what's actually load-bearing.
5. **Make the edits.** Update CLAUDE.md routing entries to match.

## Hard rules

- **Don't auto-delete or auto-rewrite rules without confirmation.** A rule you don't understand the value of might be the rule that prevented a past mistake.
- **Past mistakes (`past-mistakes.md`) are sacred-ish.** Deletion needs an explicit "yes, this no longer applies" from the user.
- **Don't grow CLAUDE.md during spa day.** The whole point is to shrink the surface area, not move complexity around.

## Why this rule exists

The agentic engineering principle: as you add rules and skills, performance gets better — until you cross a threshold where context bloat and contradictions degrade it again. Spa day is the maintenance pass that keeps the system on the good side of that threshold.
