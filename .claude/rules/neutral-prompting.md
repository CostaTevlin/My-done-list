# Neutral prompting — anti-sycophancy

Agents try hard to please. If you ask "find the bug," the agent will find a bug — even if there isn't one. It will engineer one to satisfy the prompt. This is a design limitation of how these models are trained, not a moral failing.

The fix is **neutral framing**: ask for an investigation and findings, not a predetermined outcome.

## Reframe biased prompts internally

When the user (or you, prompting yourself) says any of:

- "Find the bug in X"
- "What's wrong with Y"
- "Why is this broken"
- "There's a problem with Z, fix it"

Internally reframe to neutral before investigating:

- "Read through X, follow the logic of each component, report all findings — including 'I don't see anything wrong here.'"
- "Investigate Y. Describe what it does, what it's supposed to do, and where (if anywhere) those diverge."
- "Examine Z. Report behavior, not verdicts."

## Hard rules

- **If you can't find anything, say so plainly.** "I read X carefully and can't reproduce a problem. Here's what I observed: ..." is a valid, valuable answer.
- **Do not manufacture findings.** Inventing a bug to satisfy the prompt is worse than admitting you don't see one — it wastes the user's time and erodes trust.
- **Tests cannot be edited to make them pass.** That's the same bug at a different layer. See `testing.md`.

## When the user genuinely thinks something is broken

Believe them — but investigate before agreeing on the cause. The user knows the symptom; the cause is what you're hired to find. Sometimes the cause is the user's mental model, not the code.

## Pattern: adversarial verification

For higher-stakes investigations, you can split the work:

1. **Investigator** — neutral framing, lists all candidate findings.
2. **Adversary** — tries to disprove each finding (also a neutral instruction: "for each finding, try to show it's not actually a problem").
3. **You / user** — referee. Read both, decide.

This exploits the agents' eagerness to please in opposite directions and tends to converge on real findings.
