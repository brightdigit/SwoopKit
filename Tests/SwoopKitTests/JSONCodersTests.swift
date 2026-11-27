//
//  JSONCodersTests.swift
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

internal final class JSONCodersTests: XCTestCase {
  private struct Rejecting: Decodable {
    private struct Rejected: Error {}

    init(from decoder: any Decoder) throws {
      throw Rejected()
    }
  }

  internal func testEncoderSettings() {
    let encoder = JSONEncoder.iso8601PrettySorted

    XCTAssertEqual(encoder.outputFormatting, [.prettyPrinted, .sortedKeys])
    guard case .iso8601 = encoder.dateEncodingStrategy else {
      return XCTFail("Expected ISO 8601 dates")
    }
  }

  /// Each call returns a new encoder, so one caller's change doesn't leak.
  internal func testEncoderIsNewEachTime() {
    let first = JSONEncoder.iso8601PrettySorted
    first.outputFormatting = []

    XCTAssertNotIdentical(first, JSONEncoder.iso8601PrettySorted)
    XCTAssertEqual(
      JSONEncoder.iso8601PrettySorted.outputFormatting,
      [.prettyPrinted, .sortedKeys]
    )
  }

  internal func testDecoderIsNewEachTime() {
    let first = JSONDecoder.iso8601
    XCTAssertNotIdentical(first, JSONDecoder.iso8601)
  }

  internal func testDecoderReadsWhatEncoderWrites() throws {
    let date = Date(timeIntervalSince1970: 1_700_000_000)
    let data = try JSONEncoder.iso8601PrettySorted.encode([date])

    XCTAssertEqual(try JSONDecoder.iso8601.decodeValue([Date].self, from: data), [date])
  }

  internal func testDecodeValuePassesDecodingErrorsThrough() {
    do {
      _ = try JSONDecoder.iso8601.decodeValue([Int].self, from: Data("{}".utf8))
      XCTFail("Expected a DecodingError")
    } catch {
      guard case .typeMismatch = error else {
        return XCTFail("Expected typeMismatch, got \(error)")
      }
    }
  }

  internal func testDecodeValueWrapsOtherErrors() {
    do {
      _ = try JSONDecoder.iso8601.decodeValue(Rejecting.self, from: Data("{}".utf8))
      XCTFail("Expected a DecodingError")
    } catch {
      guard case .dataCorrupted(let context) = error else {
        return XCTFail("Expected dataCorrupted, got \(error)")
      }
      XCTAssertNotNil(context.underlyingError)
    }
  }
}
