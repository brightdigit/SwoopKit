//
//  ReleaseDataSnapshot.swift
//  SwoopKit
//
//  Created by Leo Dion.
//  Copyright © 2026 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the “Software”), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

public import Foundation

/// `SDKVersion`, `XcodeVersion` and `SimulatorRuntime` records fetched
/// together, with when they were fetched from CloudKit.
///
/// A disk cache (SwoopCloudKit's `ReleaseDataCacheFile`) and an app's bundled
/// snapshot each hold one. The JSON is one object with `fetchedAt`
/// (ISO 8601), `sdkVersions`, `xcodeVersions` and `simulatorRuntimes`, using
/// the records' own `Codable` field names. `simulatorRuntimes` was added
/// later, so a file without it decodes with none. Write it with
/// ``Foundation/JSONEncoder/iso8601PrettySorted`` so the file is stable and
/// diffable.
public struct ReleaseDataSnapshot: Sendable, Codable {
  /// When the records were fetched from CloudKit, never a file's
  /// modification time.
  public var fetchedAt: Date
  /// The `SDKVersion` records.
  public var sdkVersions: [SDKVersionRecord]
  /// The `XcodeVersion` records.
  public var xcodeVersions: [XcodeVersionRecord]
  /// The `SimulatorRuntime` records from Apple's simulator index.
  public var simulatorRuntimes: [SimulatorRuntimeRecord]

  /// Creates a snapshot.
  ///
  /// - Parameters:
  ///   - fetchedAt: When the records were fetched from CloudKit.
  ///   - sdkVersions: The `SDKVersion` records.
  ///   - xcodeVersions: The `XcodeVersion` records.
  ///   - simulatorRuntimes: The `SimulatorRuntime` records; none by default.
  public init(
    fetchedAt: Date,
    sdkVersions: [SDKVersionRecord],
    xcodeVersions: [XcodeVersionRecord],
    simulatorRuntimes: [SimulatorRuntimeRecord] = []
  ) {
    self.fetchedAt = fetchedAt
    self.sdkVersions = sdkVersions
    self.xcodeVersions = xcodeVersions
    self.simulatorRuntimes = simulatorRuntimes
  }

  /// Decodes a snapshot; a missing `simulatorRuntimes` is empty.
  ///
  /// - Parameter decoder: The decoder to read from.
  /// - Throws: A `DecodingError` when a required key is missing or a record
  ///   doesn't decode.
  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.init(
      fetchedAt: try container.decode(Date.self, forKey: .fetchedAt),
      sdkVersions: try container.decode([SDKVersionRecord].self, forKey: .sdkVersions),
      xcodeVersions: try container.decode(
        [XcodeVersionRecord].self,
        forKey: .xcodeVersions
      ),
      simulatorRuntimes: try container.decodeIfPresent(
        [SimulatorRuntimeRecord].self,
        forKey: .simulatorRuntimes
      ) ?? []
    )
  }
}

extension ReleaseDataSnapshot {
  /// Decodes a snapshot from its JSON, such as a bundled snapshot.
  ///
  /// Dates are ISO 8601 (``Foundation/JSONDecoder/iso8601``), which keeps
  /// whole seconds only: plenty for an hourly refresh.
  ///
  /// - Parameter data: A snapshot's JSON.
  /// - Throws: A `DecodingError` when `data` isn't a snapshot.
  public init(json data: Data) throws(DecodingError) {
    self = try JSONDecoder.iso8601.decodeValue(Self.self, from: data)
  }
}
