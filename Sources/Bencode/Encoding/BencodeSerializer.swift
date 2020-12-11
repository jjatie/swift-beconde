//
//  BencodeSerializer.swift
//  

import Foundation

struct BencodeSerializer {
    private static let dictionaryStartToken = "d".data(using: .ascii)!
    private static let listStartToken = "l".data(using: .ascii)!
    private static let integerStartToken = "i".data(using: .ascii)!
    private static let endToken = "e".data(using: .ascii)!
    private static func stringStartToken(for string: String) -> Data {
        "\(string.utf8.count):".data(using: .ascii)!
    }

    init() { }

    func serialize(_ value: BencodeValue) throws -> Data {
        switch value {
        case let dict as Ref<BDictionary>: return try serialize(dict.base)
        case let dict as BDictionary: return try serialize(dict)

        case let array as Ref<BArray>: return try serialize(array.base)
        case let array as BArray: return try serialize(array)

        case let string as String: return serialize(string)
        case let int as Int: return serialize(int)

        default:
            fatalError("Unknown type: \(type(of: value))")
        }
    }

    private func serialize(_ dictionary: BDictionary) throws -> Data {
        let data = try dictionary.reduce(into: Data()) { (data, pair) in
            data += serialize(pair.key)
            data += try serialize(pair.value)
        }

        return Self.dictionaryStartToken + data + Self.endToken
    }

    private func serialize(_ array: BArray) throws -> Data {
        let data = try array.reduce(into: Data()) {
            $0 += try serialize($1)
        }
        return Self.listStartToken + data + Self.endToken
    }

    private func serialize(_ string: String) -> Data {
        Self.stringStartToken(for: string) + string.data(using: .utf8)!
    }

    private func serialize(_ int: Int) -> Data {
        Self.integerStartToken + "\(int)".data(using: .ascii)! + Self.endToken
    }
}
