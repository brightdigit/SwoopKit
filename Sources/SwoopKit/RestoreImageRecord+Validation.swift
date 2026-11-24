//
//  RestoreImageRecord+Validation.swift
//  SwoopKit
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
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

internal import Foundation

extension RestoreImageRecord {
  /// Validates that a string contains only lowercase hexadecimal characters.
  ///
  /// - Parameter string: The string to validate. Must be already normalized to lowercase.
  /// - Returns: `true` if the string contains only lowercase hex digits (0-9, a-f), `false` otherwise.
  ///
  /// - Note: This method expects the input to be pre-normalized to lowercase.
  ///   Use `string.lowercased()` before calling this method if the input may contain uppercase characters.
  private static func isValidHexadecimal(_ string: String) -> Bool {
    string.allSatisfy { $0.isHexDigit && ($0.isLowercase || $0.isNumber) }
  }

  /// Validates a cryptographic hash string.
  ///
  /// - Parameters:
  ///   - hash: The hash string to validate
  ///   - expectedLength: Expected character length (64 for SHA-256, 40 for SHA-1)
  ///   - invalidLengthError: Error to throw if length is incorrect
  ///   - nonHexError: Error to throw if non-hexadecimal characters present
  /// - Throws: Provided error if validation fails
  private static func validateHash(
    _ hash: String,
    expectedLength: Int,
    invalidLengthError: @autoclosure () -> RestoreImageRecordValidationError,
    nonHexError: @autoclosure () -> RestoreImageRecordValidationError
  ) throws(RestoreImageRecordValidationError) {
    let normalizedHash = hash.lowercased()
    guard normalizedHash.count == expectedLength else {
      throw invalidLengthError()
    }
    guard isValidHexadecimal(normalizedHash) else {
      throw nonHexError()
    }
  }

  private static func validateSHA256Hash(_ hash: String)
    throws(RestoreImageRecordValidationError)
  {
    try validateHash(
      hash,
      expectedLength: 64,
      invalidLengthError: .invalidSHA256Hash(hash, expectedLength: 64),
      nonHexError: .nonHexadecimalSHA256(hash)
    )
  }

  private static func validateSHA1Hash(_ hash: String)
    throws(RestoreImageRecordValidationError)
  {
    try validateHash(
      hash,
      expectedLength: 40,
      invalidLengthError: .invalidSHA1Hash(hash, expectedLength: 40),
      nonHexError: .nonHexadecimalSHA1(hash)
    )
  }

  private static func validateFileSize(_ size: Int)
    throws(RestoreImageRecordValidationError)
  {
    guard size > 0 else {
      throw RestoreImageRecordValidationError.nonPositiveFileSize(size)
    }
  }

  private static func validateDownloadURL(_ url: URL)
    throws(RestoreImageRecordValidationError)
  {
    guard let scheme = url.scheme?.lowercased() else {
      throw RestoreImageRecordValidationError.missingURLScheme(url)
    }
    guard scheme == "https" else {
      throw RestoreImageRecordValidationError.insecureDownloadURL(url)
    }
  }

  /// Validates all fields of the restore image record.
  ///
  /// Call this after decoding a record from an external source, since `Codable`
  /// decoding does not enforce validation (see the type-level note).
  ///
  /// - Throws: `RestoreImageRecordValidationError` if any field is invalid.
  public func validate() throws(RestoreImageRecordValidationError) {
    try Self.validateSHA256Hash(sha256Hash)
    try Self.validateSHA1Hash(sha1Hash)
    try Self.validateFileSize(fileSize)
    try Self.validateDownloadURL(downloadURL)
  }
}
