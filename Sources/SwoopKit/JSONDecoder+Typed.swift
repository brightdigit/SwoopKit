//
//  JSONDecoder+Typed.swift
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

extension JSONDecoder {
  /// `decode(_:from:)` with its error typed.
  ///
  /// `JSONDecoder` only throws `DecodingError`; anything else a value's own
  /// `init(from:)` throws is wrapped as `.dataCorrupted`.
  ///
  /// - Parameters:
  ///   - type: The type to decode.
  ///   - data: The JSON to decode.
  /// - Returns: The decoded value.
  /// - Throws: A `DecodingError` when `data` doesn't decode as `type`.
  public func decodeValue<Value: Decodable>(
    _ type: Value.Type,
    from data: Data
  ) throws(DecodingError) -> Value {
    do {
      return try decode(type, from: data)
    } catch let error as DecodingError {
      throw error
    } catch {
      throw .dataCorrupted(
        .init(codingPath: [], debugDescription: "\(error)", underlyingError: error)
      )
    }
  }
}
