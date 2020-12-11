import Foundation

open class BencodeEncoder {
    public typealias Output = Data

    /// Contextual user-provided information for use during encoding.
    open var userInfo: [CodingUserInfoKey : Any] = [:]

    public init() { }
    
    open func encode<T: Encodable>(_ value: T) throws -> Data {
        let encoder = _Encoder(options: self.options)

        guard let topLevel = try encoder.box__(value) else {
            throw EncodingError.invalidValue(
                value,
                EncodingError.Context(
                    codingPath: [],
                    debugDescription: "Top-level \(T.self) did not encode any values."
                )
            )
        }

        do {
            return try BencodeSerializer().serialize(topLevel)
        } catch {
            throw EncodingError.invalidValue(
                value,
                EncodingError.Context(
                    codingPath: [],
                    debugDescription: "Unable to encode the given top-level value to Bencode.",
                    underlyingError: error
                )
            )
        }
    }
}

#if canImport(Combine)
import Combine
extension BencodeEncoder: TopLevelEncoder { }
#endif
