//
//  BencodeDecoder.swift
//  

import Foundation

open class BencodeDecoder {
    public typealias Input = Data

    /// Contextual user-provided information for use during decoding.
    open var userInfo: [CodingUserInfoKey : Any] = [:]

    // MARK: - Constructing a Bencode Decoder

    // Initializes `self` with default strategies.
    public init() {}

    // MARK: - Decoding Values

    /// Decodes a top-level value of the given type from the given Bencode representation.
    ///
    /// - parameter type: The type of the value to decode.
    /// - parameter data: The data to decode from.
    /// - returns: A value of the requested type.
    /// - throws: `DecodingError.dataCorrupted` if values requested from the payload are corrupted, or if the given data is not valid Bencode.
    /// - throws: An error if any value throws an error during decoding.
    open func decode<T: Decodable, Bytes: Collection>(
        _ type: T.Type,
        from bytes: Bytes
    ) throws -> T where Bytes.Element == UInt8 {
        let topLevel: BencodeValue
        do {
            topLevel = try BencodeParser.parse(bytes: bytes)
        } catch {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "The given data was not valid Bencode.",
                    underlyingError: error
                )
            )
        }

        let decoder = _Decoder(referencing: topLevel, options: self.options)
        guard let value = try decoder.unbox_(topLevel, as: type) else {
            throw DecodingError.valueNotFound(
                type, DecodingError.Context(
                    codingPath: [],
                    debugDescription: "The given data did not contain a top-level value."
                )
            )
        }

        return value
    }
}

#if canImport(Combine)
import Combine
extension BencodeDecoder: TopLevelDecoder {
}
#endif
