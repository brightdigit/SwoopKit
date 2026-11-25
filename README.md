# SwoopKit

[![SwiftPM](https://img.shields.io/badge/SPM-Linux%20%7C%20iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS%20%7C%20visionOS-success?logo=swift)](https://swift.org)
[![Swift Versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrightdigit%2FSwoopKit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/brightdigit/SwoopKit)
[![Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrightdigit%2FSwoopKit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/brightdigit/SwoopKit)
[![License](https://img.shields.io/github/license/brightdigit/SwoopKit)](LICENSE)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/brightdigit/SwoopKit/SwoopKit.yml?label=actions&logo=github)](https://github.com/brightdigit/SwoopKit/actions)
[![Documentation](https://img.shields.io/badge/docc-read_documentation-blue)](https://swiftpackageindex.com/brightdigit/SwoopKit/documentation)

Shared Swift models for Apple release data: SDKs, simulator runtimes, Xcode and Swift releases, and macOS restore images.

## Table of Contents

- [Overview](#overview)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Documentation](#documentation)
- [Development](#development)
- [License](#license)

## Overview

SwoopKit is the vocabulary the Swoop packages share. A writer fills these records from public sources and stores them in a CloudKit public database; a reader maps the stored records back; apps match what's installed on a Mac against them.

- [SwoopMistKit](https://github.com/brightdigit/SwoopMistKit) writes the records to CloudKit with MistKit.
- [SwoopCloudKit](https://github.com/brightdigit/SwoopCloudKit) reads them with native CloudKit.
- [Bushel](https://getbushel.app) and Stewed use them to show and match releases.

| Type | What it describes |
|---|---|
| `SDKVersionRecord` | A platform SDK build shipped with Xcode (iOS, macOS, tvOS, visionOS, watchOS) |
| `SimulatorRuntimeRecord` | A simulator runtime build from Apple's simulator index, with its `ReleaseLabel` (Beta N, RC N or Final) |
| `XcodeVersionRecord` | An Xcode release |
| `SwiftVersionRecord` | A Swift compiler release |
| `RestoreImageRecord` | A macOS restore image (IPSW), with hash and URL validation |
| `DataSourceMetadata` | When a data source was last fetched, and how many records it gave |

It depends only on Foundation. Every type is `Sendable` and `Codable`, and each record has a stable `recordName` for its CloudKit record.

## Requirements

- Swift 6.4 (swift-tools-version 6.4, Swift 6 language mode)
- macOS 12, iOS 18, watchOS 11, tvOS 18, visionOS 2 or Mac Catalyst 18; or Linux

## Installation

Add SwoopKit to your `Package.swift`:

```swift
dependencies: [
  .package(url: "https://github.com/brightdigit/SwoopKit.git", from: "1.0.0")
]
```

and to your target:

```swift
.target(
  name: "YourTarget",
  dependencies: [
    .product(name: "SwoopKit", package: "SwoopKit")
  ]
)
```

## Usage

```swift
import SwoopKit

let runtime = SimulatorRuntimeRecord(
  platform: .iOS,
  version: "27.2",
  buildNumber: "24B114",
  releaseLabel: .releaseCandidate(1),
  sdkBuildNumbers: ["24B113"]
)

runtime.isPrerelease  // true
runtime.recordName    // "SimulatorRuntime-iOS-24B114"

// Labels order Beta 1 < … < RC 1 < … < Final.
SimulatorRuntimeRecord.ReleaseLabel("Beta 4")! < .releaseCandidate(1)  // true
```

Decoding doesn't validate. After ingesting external data, call `RestoreImageRecord.validate()` or `DataSourceMetadata.validate(sourceName:recordTypeName:recordCount:fetchDurationSeconds:)`.

## Documentation

The DocC catalog is in [`Sources/SwoopKit/SwoopKit.docc`](Sources/SwoopKit/SwoopKit.docc). Swift Package Index hosts the [published documentation](https://swiftpackageindex.com/brightdigit/SwoopKit/documentation).

To build it locally (no plugin dependency; unresolved symbol links fail the build):

```bash
make docs          # .build/docs/SwoopKit.doccarchive
make docs-preview  # live preview
```

## Development

```bash
mise trust && mise install   # swift-format, SwiftLint and periphery, pinned in mise.toml
make build
make test
make lint      # Scripts/lint.sh: format, swift-format, SwiftLint, build, headers, periphery
```

CI runs on pull requests only (`.github/workflows`): Linux (Swift 6.4) and Apple platforms (Xcode 27.2), the DocC build, lint, CodeQL and an `unsafeFlags` check.

## License

SwoopKit is available under the MIT license. See [LICENSE](LICENSE).
