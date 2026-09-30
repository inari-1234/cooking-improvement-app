# 料理改善アプリ / Cooking Improvement App

## Current gate

This reconstruction is the first-IPA preparation gate.

- Pure Swift core: Linux Swift 6.2 tests pass in Debug and Release.
- iOS source: syntax-parsed on Linux.
- Xcode project: `plutil -lint` passes.
- SwiftData V1: 24 explicit `@Model` types, no core `Data`/transformable blob.
- First-device flow implemented: dish list → add dish → add recipe → start cooking → resume step → finish.
- Apple/Xcode compile and SwiftData runtime remain **unverified** until the macOS/iOS build gate runs.

## First Apple build

Open `iOS/CookingImprovementApp.xcodeproj` in Xcode or push the repository to GitHub and run **iOS Build Gate**.

The project intentionally uses a placeholder bundle identifier:

`com.example.CookingImprovementApp`

Set your Development Team and final bundle identifier before device signing / IPA export.

## First IPA gate

Current first-IPA preparation uses three layers of validation:

1. `Scripts/static-gate.sh` on any Swift-capable environment: project syntax, 24 explicit SwiftData model contract, Swift source parse, Debug/Release pure-Swift tests.
2. GitHub Actions on macOS/Xcode: iOS Simulator build plus SwiftData smoke tests, including an on-disk store reopen test.
3. Unsigned Release iPhone device build. The resulting `.app` is uploaded as `CookingImprovementApp-unsigned-device`. Signing/export to `.ipa` is intentionally a later gate and is not considered passed until valid Apple signing/provisioning is configured.

The first IPA UI remains intentionally minimal: dish list -> add dish -> register recipe -> start cooking -> move steps -> finish. Evaluation/Experiment/Backup UI is not exposed in this first installation smoke build.
