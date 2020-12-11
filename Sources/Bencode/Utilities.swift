//
//  File.swift
//  
//
//  Created by Jacob Christie on 2020-12-06.
//

import Foundation

//===----------------------------------------------------------------------===//
// Shared ISO8601 Date Formatter
//===----------------------------------------------------------------------===//

// NOTE: This value is implicitly lazy and _must_ be lazy. We're compiled against the latest SDK (w/ ISO8601DateFormatter), but linked against whichever Foundation the user has. ISO8601DateFormatter might not exist, so we better not hit this code path on an older OS.
@available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
var _iso8601Formatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = .withInternetDateTime
    return formatter
}()

//===----------------------------------------------------------------------===//
// Error Utilities
//===----------------------------------------------------------------------===//

extension EncodingError {
    /// Returns a `.invalidValue` error describing the given invalid floating-point value.
    ///
    ///
    /// - parameter value: The value that was invalid to encode.
    /// - parameter path: The path of `CodingKey`s taken to encode this value.
    /// - returns: An `EncodingError` with the appropriate path and debug description.
    static func _invalidFloatingPointValue<T : FloatingPoint>(_ value: T, at codingPath: [CodingKey]) -> EncodingError {
        let valueDescription: String
        if value == T.infinity {
            valueDescription = "\(T.self).infinity"
        } else if value == -T.infinity {
            valueDescription = "-\(T.self).infinity"
        } else {
            valueDescription = "\(T.self).nan"
        }

        let debugDescription = "Unable to encode \(valueDescription) directly in Bencode. Use BencodeEncoder.NonConformingFloatEncodingStrategy.convertToString to specify how the value should be encoded."
        return .invalidValue(value, EncodingError.Context(codingPath: codingPath, debugDescription: debugDescription))
    }
}

extension DecodingError {
    static func _typeMismatch(
        at path: [CodingKey],
        expectation: Any.Type,
        reality: BencodeValue
    ) -> DecodingError {
        let description = "Expected to decode \(expectation) but found \(type(of: reality)) instead."
        return .typeMismatch(expectation, Context(codingPath: path, debugDescription: description))
    }

    static func _valueNotFound(at path: [CodingKey], expectation: Any.Type) -> DecodingError {
        DecodingError.valueNotFound(
            expectation,
            DecodingError.Context(
                codingPath: path,
                debugDescription: "Expected \(expectation) value but found null instead."
            )
        )
    }

    static func _errorDescription(of key: CodingKey) -> String {
        return "\(key) (\"\(key.stringValue)\")"
    }

    static func _keyNotFound(at path: [CodingKey], key: CodingKey) -> DecodingError {
        DecodingError.keyNotFound(
            key,
            DecodingError.Context(
                codingPath: path,
                debugDescription: "No value associated with key \(_errorDescription(of: key))."
            )
        )
    }
}
