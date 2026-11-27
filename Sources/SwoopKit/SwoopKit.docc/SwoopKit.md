# ``SwoopKit``

Shared models for Apple release data: SDKs, simulator runtimes, Xcode and Swift
releases, and macOS restore images.

## Overview

SwoopKit holds the value types that every Swoop package agrees on. A writer such as
SwoopMistKit fills them from public sources and saves them to a CloudKit public
database; a reader such as SwoopCloudKit maps the stored records back into them; and
apps match what is installed on a Mac against them.

The package depends only on Foundation, so it builds wherever its consumers do,
including Linux. Every type is `Sendable` and `Codable`, and each record exposes a
stable `recordName` that writers use as its CloudKit record name.

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
```

### Matching installed runtimes

A simulator runtime's build number often differs from the SDK it ships with, and some
device-specific runtimes have no SDK at all. Match an installed runtime against
``SimulatorRuntimeRecord`` first, by ``SimulatorRuntimeRecord/buildNumber``, and fall
back to ``SDKVersionRecord`` (via ``SimulatorRuntimeRecord/sdkBuildNumbers`` or
platform, version and stage) only when there is no runtime record.

Order releases of the same platform and version by
``SimulatorRuntimeRecord/ReleaseLabel`` rather than by build number: betas sort before
release candidates, which sort before the final release.

### Release-data snapshots

``ReleaseDataSnapshot`` holds the `SDKVersion`, `XcodeVersion` and `SimulatorRuntime`
records fetched together, stamped with ``ReleaseDataSnapshot/fetchedAt``. Encode it
with ``Foundation/JSONEncoder/iso8601PrettySorted`` so the file is stable and
diffable, and decode one with ``ReleaseDataSnapshot/init(json:)``:

```swift
let data = try JSONEncoder.iso8601PrettySorted.encode(snapshot)
let bundled = try ReleaseDataSnapshot(json: data)
```

ISO 8601 keeps whole seconds only, so a `fetchedAt` with a fractional second comes
back without it.

### Validation

Decoding a record doesn't validate it. When you ingest data from an external source,
call ``RestoreImageRecord/validate()`` or
``DataSourceMetadata/validate(sourceName:recordTypeName:recordCount:fetchDurationSeconds:)``
and handle ``RestoreImageRecordValidationError`` or
``DataSourceMetadataValidationError``.

## Topics

### SDKs and simulator runtimes

- ``SDKVersionRecord``
- ``SDKVersionRecord/Platform``
- ``SimulatorRuntimeRecord``
- ``SimulatorRuntimeRecord/ReleaseLabel``

### Developer tools

- ``XcodeVersionRecord``
- ``SwiftVersionRecord``

### macOS restore images

- ``RestoreImageRecord``
- ``RestoreImageRecordValidationError``

### Release-data snapshots

- ``ReleaseDataSnapshot``
- ``Foundation/JSONEncoder/iso8601PrettySorted``
- ``Foundation/JSONDecoder/iso8601``
- ``Foundation/JSONDecoder/decodeValue(_:from:)``

### Data source bookkeeping

- ``DataSourceMetadata``
- ``DataSourceMetadataValidationError``
