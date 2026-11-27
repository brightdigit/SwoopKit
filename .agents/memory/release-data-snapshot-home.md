# ReleaseDataSnapshot lives here (since brightdigit/Stewed#194)

- `ReleaseDataSnapshot` and its coders (`JSONEncoder.iso8601PrettySorted`, `JSONDecoder.iso8601`, `JSONDecoder.decodeValue(_:from:)`) moved down from SwoopCloudKit so SwoopMistKit's snapshot export can produce the same JSON without depending on SwoopCloudKit. `ReleaseDataCacheFile` and `JSONEncoder.encodeAsserting(_:)` stayed in SwoopCloudKit.
- The JSON must stay byte-identical to what SwoopCloudKit and Stewed's `release-data-snapshot` wrote: pretty-printed, sorted keys, ISO 8601 whole-second dates. `ReleaseDataSnapshotTests.testEncodesStableJSON` pins the exact bytes, on Linux too (swift-foundation prints the same as Darwin, including `[`, blank line, `]` for an empty array).
- A consumer that keeps its own copies of these static extensions alongside SwoopKit's gets ambiguous-member errors, so SwoopCloudKit has to delete its copies when it adopts the SwoopKit version.
