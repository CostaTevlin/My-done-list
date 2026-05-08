# Build & test commands — quick reference

Open `XCode Project/DoneList/DoneList.xcodeproj` in Xcode 26.

## Xcode shortcuts

- ⌘B — build
- ⌘U — run tests
- ⌘R — run on simulator

## CLI (from repo root)

```bash
cd "XCode Project/DoneList"

# Build app target (Debug, iPhone 15 Pro simulator, iOS 18 baseline)
xcodebuild -project DoneList.xcodeproj -scheme DoneList \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build

# Run tests
xcodebuild -project DoneList.xcodeproj -scheme DoneList \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' test
```

## For visual changes — test both OS versions

Per `liquid-glass.md`, anything visual must compile and render correctly on both iOS 18 and iOS 26. Use two destinations:

```bash
# iOS 18 baseline
xcodebuild ... -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=18.4' build

# iOS 26 (Liquid Glass path)
xcodebuild ... -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=26.0' build
```

## Real-device deployment & TestFlight

- Per-device preview setup: `engineering/Setup — iPhone preview.md` in the vault.
- Archive → TestFlight → submission: `engineering/Build & ship runbook.md`.
- Submission checklist: `appstore/Submission checklist.md`.

## Always

- Run tests after every code change.
- Confirm a clean build with no new warnings before committing.
