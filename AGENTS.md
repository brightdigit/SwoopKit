# CLAUDE.md

Guidance for Claude Code when working in this repository.

## What this is

SwoopKit is a Swift package of shared models for Apple release data: `SDKVersionRecord`, `SimulatorRuntimeRecord` (with `ReleaseLabel`), `XcodeVersionRecord`, `SwiftVersionRecord`, `RestoreImageRecord`, `DataSourceMetadata` and the two validation errors. It has one library product and one target, `SwoopKit`, and depends only on Foundation.

Its consumers rely on these types staying stable:

- **SwoopMistKit** writes them to a CloudKit public database.
- **SwoopCloudKit** maps `CKRecord`s back to them.
- **Bushel** and **Stewed** match installed software against them.

## Rules

- **Don't break the wire format.** Field names and the synthesized `Codable` output are persisted in CloudKit, JSON snapshots and disk caches. A new field must be an optional property so the synthesized `Codable` decodes it with `decodeIfPresent` (see `XcodeVersionRecord.prereleaseLabel`), with a test that old JSON still decodes (`XcodeVersionRecordTests.testDecodesWithoutPrereleaseLabel`).
- **`recordName` is a CloudKit record name.** Never change how one is built; existing records would be orphaned.
- **Foundation only.** No other dependencies, and nothing Apple-only: the package builds on Linux.
- **No swift-docc-plugin in `Package.swift`.** It would be resolved by every package that depends on SwoopKit. Build docs with `Scripts/docc.sh` instead.
- Swift 6.4 (swift-tools-version 6.4), Swift 6 language mode, complete strict concurrency, `ExistentialAny` and `InternalImportsByDefault`. Every public type is `Sendable`.
- **Typed throws everywhere**, e.g. `throws(RestoreImageRecordValidationError)`. The only exceptions are protocol witnesses whose body calls untyped-throwing APIs (`Codable`'s `init(from:)` and `encode(to:)`).
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

`Scripts/lint.sh` formats in place outside CI, then runs swift-format and SwiftLint in strict mode, `swift build --build-tests` (locally), the header script and periphery (locally, if installed). In Claude Code web sessions (`CLAUDE_CODE_REMOTE=true`) it skips mise, SwiftLint and periphery.

There is no Xcode project or XcodeGen target; open `Package.swift` directly.

## CI

GitHub Actions workflows trigger on `pull_request` (plus `workflow_dispatch`, a weekly CodeQL schedule, branch deletion for cache cleanup, and issue/review-comment events for `claude.yml`), never on `push`. PRs into `main` or a semver branch (`v1.2.3`, `1.2.3-beta.1`) get the full Apple-platform matrix.

- The manifest needs Swift 6.4, so Linux lanes use the `swiftlang/swift:nightly-6.4.x` image and Apple lanes use the `xcode-27` runner image.
- Swift Package Index builds the published docs (`.spi.yml`).

## Tests

`Tests/SwoopKitTests` uses XCTest, one test class per record. Cover encode/decode round trips, `recordName`, validation failures, and decoding of older JSON when a field is added.

## Memory & Corrections Convention

`AGENTS.md` and `.agents/` are the real files. `CLAUDE.md` and `.claude` are symlinks to them, so Claude Code finds them too. Edit the real paths, and don't replace a symlink with a copy.

These two files are the source of truth for how to work in this repo. Both are committed to git.

- **`.agents/agent-notes.md`**: an append-only log of the maintainer's corrections and standing always/never directives, one line each, newest at the bottom.
- **`.agents/memory/`**: this project's memory store. One markdown file per project-scoped fact (decisions, constraints, gotchas, context not derivable from the code or git history), indexed in `.agents/memory/MEMORY.md`.

Rules:

1. Read `.agents/agent-notes.md` and `.agents/memory/MEMORY.md` before doing any work.
2. Append to them proactively, without being asked: a line in `agent-notes.md` for every correction or always/never instruction, and a memory file plus index line for every project fact worth keeping.
3. When a directive or memory is superseded or wrong, update or delete the stale entry rather than leaving both.
4. Never store project-scoped memories in a native or global memory system (such as Claude Code's `~/.claude/projects/<project>/memory/`). They belong in the repo so they're versioned and visible to every person and agent working here.
