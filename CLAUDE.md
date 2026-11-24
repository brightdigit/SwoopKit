# CLAUDE.md

Guidance for Claude Code when working in this repository.

## What this is

SwoopKit is a Swift package of shared models for Apple release data: `SDKVersionRecord`, `SimulatorRuntimeRecord` (with `ReleaseLabel`), `XcodeVersionRecord`, `SwiftVersionRecord`, `RestoreImageRecord`, `DataSourceMetadata` and the two validation errors. It has one library product and one target, `SwoopKit`, and depends only on Foundation.

Its consumers rely on these types staying stable:

- **SwoopMistKit** writes them to a CloudKit public database.
- **SwoopCloudKit** maps `CKRecord`s back to them.
- **Bushel** and **Stewed** match installed software against them.

## Rules

- **Don't break the wire format.** Field names and the synthesized `Codable` output are persisted in CloudKit, JSON snapshots and disk caches. A new field must be optional and decode with `decodeIfPresent` (see `XcodeVersionRecord.prereleaseLabel`), with a test that old JSON still decodes.
- **`recordName` is a CloudKit record name.** Never change how one is built; existing records would be orphaned.
- **Foundation only.** No other dependencies, and nothing Apple-only: the package builds on Linux.
- **No swift-docc-plugin in `Package.swift`.** It would be resolved by every package that depends on SwoopKit. Build docs with `Scripts/docc.sh` instead.
- Swift 6.4 (swift-tools-version 6.4), Swift 6 language mode, complete strict concurrency, `ExistentialAny` and `InternalImportsByDefault`. Every public type is `Sendable`. Use typed throws for new throwing APIs.
- Keep the platform minimums in `Package.swift` unless a consumer needs them raised.
- Every public symbol has a doc comment (swift-format's `AllPublicDeclarationsHaveDocumentation`). Add new public types to a topic group in `Sources/SwoopKit/SwoopKit.docc/SwoopKit.md`.
- One type per file; extensions go in `Type+Feature.swift`. Each source file carries the MIT header (`make headers`).

## Commands

```bash
swift build
swift test             # XCTest
make lint              # Scripts/lint.sh (tools pinned in mise.toml; run `mise install` once)
make docs              # DocC with --warnings-as-errors; output in .build/docs
make docs-preview
```

`Scripts/lint.sh` formats in place outside CI, then runs swift-format and SwiftLint in strict mode, `swift build --build-tests` (locally), the header script and periphery (locally, if installed).

## CI

GitHub Actions workflows trigger on `pull_request` (plus `workflow_dispatch`, a weekly CodeQL schedule and branch deletion for cache cleanup), never on `push`. PRs into `main` or a `v*` branch get the full Apple-platform matrix.

- The manifest needs Swift 6.4, so Linux lanes use the `swiftlang/swift:nightly-6.4.x` image and Apple lanes use the `xcode-27` runner image.
- Swift Package Index builds the published docs (`.spi.yml`).

## Tests

`Tests/SwoopKitTests` uses XCTest, one test class per record. Cover encode/decode round trips, `recordName`, validation failures, and decoding of older JSON when a field is added.
