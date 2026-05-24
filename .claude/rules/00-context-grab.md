# 00 — Context grab (read first, every time)

Run this list **on session start**, **after every compaction**, and **whenever you feel uncertain** about what's going on. Most bad output in this repo comes from skipping it and filling gaps with assumptions instead.

## The list

1. **Re-read the active task plan / TodoList.** If a contract exists for the current task (`.claude/contracts/<task>_CONTRACT.md`), re-read it in full.
2. **Re-read the files you were last editing.** Don't trust your memory of their contents — the file is the truth, your memory of it is not.
3. **Run `git status` and `git branch --show-current`.** Don't assume the branch or working state. The user may have switched branches, stashed, or pulled in changes.
4. **Open `/Users/konstantinnaumenko/Obsidian/my-startups/My Done List/00 — Index.md`** if the Phase in CLAUDE.md feels stale or if the task spans phases. The vault is authoritative for product/design/decision context.
5. **Identify which routing rules in CLAUDE.md fire for this task.** Read those, and only those. If you're tempted to read more "just in case," stop — that's context bloat.

## What "don't fill in gaps" means in practice

- If the user said "fix the bug in the chart," and you don't know which chart they mean — **ask**. Do not guess based on recent commits, file recency, or vibes.
- If a design value isn't in `Tokens.md` and isn't in the Figma node — **ask** or check `design-system/Screen specs.md`. Do not invent a value because it "looks right."
- If an API behavior is unclear from the docs — **read the docs again, or run a tiny experiment in a scratch file**. Do not assume.
- If you can't find an ADR that covers a decision — **say so plainly** and propose writing one. Do not pretend the decision is already made.

A good agent says "I don't know — here's what I'd need to find out." A bad agent invents the answer and moves on.

## Why this rule exists

Compaction strips out context. The agent that comes back is missing things the previous one knew. Without an explicit re-grounding step, it will silently substitute its own assumptions and produce output that drifts from intent. Re-grabbing context is cheap; un-doing wrong assumptions is expensive.
