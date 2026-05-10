# Legacy PWA — read-only

Files at the repo root:

- `index.html`
- `sw.js`
- `manifest.json`
- `icon-*.png`

These are the **legacy PWA** that the native iOS app is replacing. They are **read-only reference**. Consult them only for parity:

- Copy strings (mirror in `Services/CopyBank.swift` and `design-system/Copy bank.md`).
- Color values (only as a sanity check — `design-system/Tokens.md` is the actual source of truth, see `design-system.md`).
- Behavior (animation timing, interaction flow) — only as input to the native implementation, not as a spec.

## Hard rule

**Never edit them as part of native work.** If a user says "fix the layout" and you find yourself in `index.html`, you're in the wrong file — the native app is in `XCode Project/DoneList/`.

## Past mistake

Editing `index.html` when asked to "fix the Today screen layout." Cost a session and a confused user. Always check the file path before editing — if it ends in `.html`, `.js`, `manifest.json`, or `icon-*.png` at repo root, stop.
