# ADRs — read before making a non-trivial architectural choice

ADRs (Architecture Decision Records) live in the vault at `~/Documents/Obsidian/my-startups/My Done List/decisions/`. ADRs 0001–0010 are already written.

## When to write a new ADR

Before implementing, write an ADR if you're doing any of:

- Adding a dependency (Swift package, framework, third-party lib).
- Introducing a new architectural pattern (e.g., a new state-management style, a new persistence layer).
- Deviating from an existing ADR.
- Changing the schema or migration strategy for SwiftData / CloudKit (always — see ADR-0009).
- Replacing a load-bearing service (HapticEngine, CopyBank, anything in `Services/`).

## How

1. Copy `decisions/_template — ADR.md` to `decisions/00NN — <slug>.md`.
2. Fill in: context, decision, consequences, alternatives considered.
3. **Confirm with the user** before implementing — ADRs are intent, not after-the-fact justification.
4. Reference the ADR number in:
   - The PR description.
   - Code comments where the decision is load-bearing (e.g., `// per ADR-0009: schema must stay additive`).

## When to consult an existing ADR

- Before touching tokens / design system → ADR-0001 (or whichever covers the relevant area).
- Before changing persistence behavior → ADR-0003, ADR-0009.
- Before adding animations → ADR-0006.
- Before building gesture handling → ADR-0007.
- Before adding Liquid Glass → ADR-0005.
- Before changing fonts → ADR-0004.

If you can't tell whether an ADR exists for the area you're touching, **search the `decisions/` folder before coding** — `git grep` and the vault's search both work.

## Past mistake

Implementing a major change without first checking whether an ADR already covers it. Tripped twice. Pre-flight check: "Is there an ADR for this?" before touching any architectural surface.
