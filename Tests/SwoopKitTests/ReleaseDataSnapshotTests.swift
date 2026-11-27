//
//  ReleaseDataSnapshotTests.swift
//  SwoopKit
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import XCTest

@testable import SwoopKit

internal final class ReleaseDataSnapshotTests: XCTestCase {
  /// 2023-11-14T22:13:20.750Z: a fetch time with a fractional second.
  private static let fetchedAt = Date(timeIntervalSince1970: 1_700_000_000.75)

  /// `makeSnapshot()` as a bundled snapshot. Empty arrays print as `[`, a
  /// blank line and `]`, as Foundation's pretty printer writes them.
  private static let expectedJSON = """
    {
      "fetchedAt" : "2023-11-14T22:13:20Z",
      "sdkVersions" : [
        {
          "buildNumber" : "24B113",
          "isPrerelease" : false,
          "platform" : "iOS",
          "releaseDate" : "2023-11-14T22:13:20Z",
          "version" : "27.2"
        }
      ],
      "simulatorRuntimes" : [

      ],
      "xcodeVersions" : [
        {
          "buildNumber" : "18B100",
          "isPrerelease" : false,
          "releaseDate" : "2023-11-14T22:13:20Z",
          "version" : "27.2"
        }
      ]
    }
    """

  private func makeSnapshot(
    simulatorRuntimes: [SimulatorRuntimeRecord] = []
  ) -> ReleaseDataSnapshot {
    ReleaseDataSnapshot(
      fetchedAt: Self.fetchedAt,
      sdkVersions: [
        SDKVersionRecord(
          platform: .iOS,
          version: "27.2",
          buildNumber: "24B113",
          isPrerelease: false,
          releaseDate: Date(timeIntervalSince1970: 1_700_000_000)
        )
      ],
      xcodeVersions: [
        XcodeVersionRecord(
          version: "27.2",
          buildNumber: "18B100",
          releaseDate: Date(timeIntervalSince1970: 1_700_000_000),
          isPrerelease: false
        )
      ],
      simulatorRuntimes: simulatorRuntimes
    )
  }

  private func makeRuntime() -> SimulatorRuntimeRecord {
    SimulatorRuntimeRecord(
      platform: .iOS,
      version: "27.2",
      buildNumber: "24B114",
      releaseLabel: .final,
      sdkBuildNumbers: ["24B113"]
    )
  }

  internal func testDefaultsToNoSimulatorRuntimes() {
    let snapshot = ReleaseDataSnapshot(
      fetchedAt: Self.fetchedAt,
      sdkVersions: [],
      xcodeVersions: []
    )
    XCTAssertTrue(snapshot.simulatorRuntimes.isEmpty)
  }

  internal func testRoundTrip() throws {
    let original = makeSnapshot(simulatorRuntimes: [makeRuntime()])

    let data = try JSONEncoder.iso8601PrettySorted.encode(original)
    let decoded = try ReleaseDataSnapshot(json: data)

    XCTAssertEqual(decoded.fetchedAt, Date(timeIntervalSince1970: 1_700_000_000))
    XCTAssertEqual(decoded.sdkVersions, original.sdkVersions)
    XCTAssertEqual(decoded.xcodeVersions.map(\.recordName), ["XcodeVersion-18B100"])
    XCTAssertEqual(decoded.simulatorRuntimes, original.simulatorRuntimes)
    XCTAssertEqual(try JSONEncoder.iso8601PrettySorted.encode(decoded), data)
  }

  /// The encoder's output is the bundled-snapshot format, byte for byte:
  /// pretty-printed, sorted keys and whole-second ISO 8601 dates.
  internal func testEncodesStableJSON() throws {
    let data = try JSONEncoder.iso8601PrettySorted.encode(makeSnapshot())
    XCTAssertEqual(String(decoding: data, as: UTF8.self), Self.expectedJSON)
  }

  internal func testEncodesWholeSecondDates() throws {
    let data = try JSONEncoder.iso8601PrettySorted.encode(makeSnapshot())
    let json = String(decoding: data, as: UTF8.self)

    XCTAssertTrue(json.contains(#""fetchedAt" : "2023-11-14T22:13:20Z""#))
    XCTAssertFalse(json.contains(".75"))
  }

  internal func testDecodesWithoutSimulatorRuntimes() throws {
    let json = Data(
      #"""
      {"fetchedAt": "2026-11-17T12:00:00Z", "sdkVersions": [],
      "xcodeVersions": []}
      """#.utf8
    )

    let decoded = try ReleaseDataSnapshot(json: json)

    XCTAssertTrue(decoded.simulatorRuntimes.isEmpty)
    XCTAssertEqual(decoded.fetchedAt, Date(timeIntervalSince1970: 1_794_916_800))
  }

  internal func testRejectsMissingFetchedAt() {
    let json = Data(#"{"sdkVersions": [], "xcodeVersions": []}"#.utf8)

    do {
      _ = try ReleaseDataSnapshot(json: json)
      XCTFail("Expected a DecodingError")
    } catch {
      guard case .keyNotFound(let key, _) = error else {
        return XCTFail("Expected keyNotFound, got \(error)")
      }
      XCTAssertEqual(key.stringValue, "fetchedAt")
    }
  }

  internal func testRejectsNonISO8601Dates() {
    let json = Data(
      #"{"fetchedAt": 749433600, "sdkVersions": [], "xcodeVersions": []}"#.utf8
    )
    XCTAssertThrowsError(try ReleaseDataSnapshot(json: json))
  }
}
