//
//  _Decoder.swift
//  
//
//  Created by Jacob Christie on 2020-12-09.
//

extension BencodeDecoder {
    /// Options set on the top-level encoder to pass down the decoding hierarchy.
    struct _Options {
//        let dateDecodingStrategy: DateDecodingStrategy
//        let dataDecodingStrategy: DataDecodingStrategy
//        let nonConformingFloatDecodingStrategy: NonConformingFloatDecodingStrategy
//        let keyDecodingStrategy: KeyDecodingStrategy
        let userInfo: [CodingUserInfoKey : Any]
    }

    /// The options set on the top-level decoder.
    var options: _Options {
        _Options(
//            dateDecodingStrategy: dateDecodingStrategy,
//            dataDecodingStrategy: dataDecodingStrategy,
//            nonConformingFloatDecodingStrategy: nonConformingFloatDecodingStrategy,
//            keyDecodingStrategy: keyDecodingStrategy,
            userInfo: userInfo
        )
    }
}

final class _Decoder: Decoder {
    // MARK: Properties

    /// The decoder's storage.
    var storage: _DecodingStorage

    /// Options set on the top-level decoder.
    let options: BencodeDecoder._Options

    /// The path to the current point in encoding.
    fileprivate(set) var codingPath: [CodingKey]

    /// Contextual user-provided information for use during encoding.
    var userInfo: [CodingUserInfoKey : Any] {
        return self.options.userInfo
    }

    // MARK: - Initialization

    /// Initializes `self` with the given top-level container and options.
    init(referencing container: BencodeValue, at codingPath: [CodingKey] = [], options: BencodeDecoder._Options) {
        self.storage = _DecodingStorage()
        self.storage.push(container: container)
        self.codingPath = codingPath
        self.options = options
    }

    // MARK: - Decoder Methods

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
        guard let topContainer = self.storage.topContainer as? BDictionary else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: BDictionary.self, reality: self.storage.topContainer)
        }

        let container = _KeyedDecodingContainer<Key>(referencing: self, wrapping: topContainer)
        return KeyedDecodingContainer(container)
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        guard let topContainer = self.storage.topContainer as? BArray else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: BArray.self, reality: self.storage.topContainer)
        }

        return _UnkeyedDecodingContainer(referencing: self, wrapping: topContainer)
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return self
    }
}

// MARK: Decoding Containers

private struct _KeyedDecodingContainer<Key: CodingKey> : KeyedDecodingContainerProtocol {
    // MARK: Properties

    /// A reference to the decoder we're reading from.
    private let decoder: _Decoder

    /// A reference to the container we're reading from.
    private let container: BDictionary

    /// The path of coding keys taken to get to this point in decoding.
    private(set) var codingPath: [CodingKey]

    // MARK: - Initialization

    /// Initializes `self` by referencing the given decoder and container.
    init(referencing decoder: _Decoder, wrapping container: BDictionary) {
        self.decoder = decoder
        self.container = container
        self.codingPath = decoder.codingPath
    }

    // MARK: - KeyedDecodingContainerProtocol Methods

    var allKeys: [Key] {
        return self.container.keys.compactMap { Key(stringValue: $0) }
    }

    func contains(_ key: Key) -> Bool {
        return self.container[key.stringValue] != nil
    }

    func decodeNil(forKey key: Key) throws -> Bool {
        guard self.container.keys.contains(key.stringValue) else {
            throw DecodingError._keyNotFound(at: self.decoder.codingPath, key: key)
        }

        return self.container[key.stringValue] == nil
    }

    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError._keyNotFound(at: self.decoder.codingPath, key: key)
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: Bool.self) else {
            throw DecodingError._valueNotFound(at: self.decoder.codingPath, expectation: type)
        }

        return value
    }

    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError._keyNotFound(at: self.decoder.codingPath, key: key)
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: Int.self) else {
            throw DecodingError._valueNotFound(at: self.decoder.codingPath, expectation: type)
        }

        return value
    }

    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError._keyNotFound(at: self.decoder.codingPath, key: key)
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: Int8.self) else {
            throw DecodingError._valueNotFound(at: self.decoder.codingPath, expectation: type)
        }

        return value
    }

    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError._keyNotFound(at: self.decoder.codingPath, key: key)
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: Int16.self) else {
            throw DecodingError._valueNotFound(at: self.decoder.codingPath, expectation: type)
        }

        return value
    }

    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError._keyNotFound(at: self.decoder.codingPath, key: key)
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: Int32.self) else {
            throw DecodingError._valueNotFound(at: self.decoder.codingPath, expectation: type)
        }

        return value
    }

    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError._keyNotFound(at: self.decoder.codingPath, key: key)
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: Int64.self) else {
            throw DecodingError._valueNotFound(at: self.decoder.codingPath, expectation: type)
        }

        return value
    }

    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError._keyNotFound(at: self.decoder.codingPath, key: key)
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: UInt.self) else {
            throw DecodingError._valueNotFound(at: self.decoder.codingPath, expectation: type)
        }

        return value
    }

    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError._keyNotFound(at: self.decoder.codingPath, key: key)
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: UInt8.self) else {
            throw DecodingError._valueNotFound(at: self.decoder.codingPath, expectation: type)
        }

        return value
    }

    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError._keyNotFound(at: self.decoder.codingPath, key: key)
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: UInt16.self) else {
            throw DecodingError._valueNotFound(at: self.decoder.codingPath, expectation: type)
        }

        return value
    }

    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError._keyNotFound(at: self.decoder.codingPath, key: key)
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: UInt32.self) else {
            throw DecodingError._valueNotFound(at: self.decoder.codingPath, expectation: type)
        }

        return value
    }

    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError._keyNotFound(at: self.decoder.codingPath, key: key)
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: UInt64.self) else {
            throw DecodingError._valueNotFound(at: self.decoder.codingPath, expectation: type)
        }

        return value
    }

    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError._keyNotFound(at: self.decoder.codingPath, key: key)
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: Float.self) else {
            throw DecodingError._valueNotFound(at: self.decoder.codingPath, expectation: type)
        }

        return value
    }

    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError._keyNotFound(at: self.decoder.codingPath, key: key)
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: Double.self) else {
            throw DecodingError._valueNotFound(at: self.decoder.codingPath, expectation: type)
        }

        return value
    }

    func decode(_ type: String.Type, forKey key: Key) throws -> String {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError._keyNotFound(at: self.decoder.codingPath, key: key)
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: String.self) else {
            throw DecodingError._valueNotFound(at: self.decoder.codingPath, expectation: type)
        }

        return value
    }

    func decode<T : Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError._keyNotFound(at: self.decoder.codingPath, key: key)
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox_(entry, as: type) else {
            throw DecodingError._valueNotFound(at: self.decoder.codingPath, expectation: type)
        }

        return value
    }

    func nestedContainer<NestedKey>(
        keyedBy type: NestedKey.Type,
        forKey key: Key
    ) throws -> KeyedDecodingContainer<NestedKey> {
        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = self.container[key.stringValue] else {
            throw DecodingError.keyNotFound(
                key,
                DecodingError.Context(
                    codingPath: self.codingPath,
                    debugDescription: "Cannot get \(KeyedDecodingContainer<NestedKey>.self) -- no value found for key \(DecodingError._errorDescription(of: key))"
                )
            )
        }

        guard let dictionary = value as? BDictionary else {
            throw DecodingError._typeMismatch(
                at: self.codingPath,
                expectation: BDictionary.self,
                reality: value
            )
        }

        let container = _KeyedDecodingContainer<NestedKey>(
            referencing: self.decoder,
            wrapping: dictionary
        )
        return KeyedDecodingContainer(container)
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = self.container[key.stringValue] else {
            throw DecodingError.keyNotFound(
                key,
                DecodingError.Context(
                    codingPath: self.codingPath,
                    debugDescription: "Cannot get UnkeyedDecodingContainer -- no value found for key \(DecodingError._errorDescription(of: key))"
                )
            )
        }

        guard let array = value as? BArray else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: BArray.self, reality: value)
        }

        return _UnkeyedDecodingContainer(referencing: self.decoder, wrapping: array)
    }

    private func _superDecoder(forKey key: __owned CodingKey) throws -> Decoder {
        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = self.container[key.stringValue] else {
            throw DecodingError.keyNotFound(
                key,
                DecodingError.Context(
                    codingPath: self.codingPath,
                    debugDescription: "Cannot get superDecoder -- no value found for key \(DecodingError._errorDescription(of: key))"
                )
            )
        }

        return _Decoder(
            referencing: value,
            at: self.decoder.codingPath,
            options: self.decoder.options
        )
    }

    func superDecoder() throws -> Decoder {
        return try _superDecoder(forKey: BencodeKey.super)
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        return try _superDecoder(forKey: key)
    }
}

private struct _UnkeyedDecodingContainer : UnkeyedDecodingContainer {
    // MARK: Properties

    /// A reference to the decoder we're reading from.
    private let decoder: _Decoder

    /// A reference to the container we're reading from.
    private let container: BArray

    /// The path of coding keys taken to get to this point in decoding.
    private(set) public var codingPath: [CodingKey]

    /// The index of the element we're about to decode.
    private(set) public var currentIndex: Int

    // MARK: - Initialization

    /// Initializes `self` by referencing the given decoder and container.
    init(referencing decoder: _Decoder, wrapping container: BArray) {
        self.decoder = decoder
        self.container = container
        self.codingPath = decoder.codingPath
        self.currentIndex = 0
    }

    // MARK: - UnkeyedDecodingContainer Methods

    public var count: Int? {
        return self.container.count
    }

    public var isAtEnd: Bool {
        return self.currentIndex >= self.count!
    }

    public mutating func decodeNil() throws -> Bool {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(
                BencodeValue?.self,
                DecodingError.Context(
                    codingPath: self.decoder.codingPath + [BencodeKey(index: self.currentIndex)],
                    debugDescription: "Unkeyed container is at end."
                )
            )
        }

        return false
    }

    public mutating func decode(_ type: Bool.Type) throws -> Bool {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [BencodeKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(BencodeKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Bool.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [BencodeKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    public mutating func decode(_ type: Int.Type) throws -> Int {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [BencodeKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(BencodeKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Int.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [BencodeKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    public mutating func decode(_ type: Int8.Type) throws -> Int8 {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [BencodeKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(BencodeKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Int8.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [BencodeKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    public mutating func decode(_ type: Int16.Type) throws -> Int16 {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [BencodeKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(BencodeKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Int16.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [BencodeKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    public mutating func decode(_ type: Int32.Type) throws -> Int32 {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [BencodeKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(BencodeKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Int32.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [BencodeKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    public mutating func decode(_ type: Int64.Type) throws -> Int64 {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [BencodeKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(BencodeKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Int64.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [BencodeKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    public mutating func decode(_ type: UInt.Type) throws -> UInt {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [BencodeKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(BencodeKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: UInt.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [BencodeKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    public mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [BencodeKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(BencodeKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: UInt8.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [BencodeKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    public mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [BencodeKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(BencodeKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: UInt16.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [BencodeKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    public mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [BencodeKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(BencodeKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: UInt32.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [BencodeKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    public mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [BencodeKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(BencodeKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: UInt64.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [BencodeKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    public mutating func decode(_ type: Float.Type) throws -> Float {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [BencodeKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(BencodeKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Float.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [BencodeKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    public mutating func decode(_ type: Double.Type) throws -> Double {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [BencodeKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(BencodeKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Double.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [BencodeKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    public mutating func decode(_ type: String.Type) throws -> String {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [BencodeKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(BencodeKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: String.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [BencodeKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    public mutating func decode<T : Decodable>(_ type: T.Type) throws -> T {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [BencodeKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(BencodeKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox_(self.container[self.currentIndex], as: type) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [BencodeKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    public mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> {
        self.decoder.codingPath.append(BencodeKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(KeyedDecodingContainer<NestedKey>.self,
                                              DecodingError.Context(codingPath: self.codingPath,
                                                                    debugDescription: "Cannot get nested keyed container -- unkeyed container is at end."))
        }

        let value = self.container[self.currentIndex]
        guard let dictionary = value as? BDictionary else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: BDictionary.self, reality: value)
        }

        self.currentIndex += 1
        let container = _KeyedDecodingContainer<NestedKey>(referencing: self.decoder, wrapping: dictionary)
        return KeyedDecodingContainer(container)
    }

    public mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        self.decoder.codingPath.append(BencodeKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self,
                                              DecodingError.Context(codingPath: self.codingPath,
                                                                    debugDescription: "Cannot get nested keyed container -- unkeyed container is at end."))
        }

        let value = self.container[self.currentIndex]
        guard let array = value as? BArray else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: BArray.self, reality: value)
        }

        self.currentIndex += 1
        return _UnkeyedDecodingContainer(referencing: self.decoder, wrapping: array)
    }

    public mutating func superDecoder() throws -> Decoder {
        self.decoder.codingPath.append(BencodeKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(Decoder.self,
                                              DecodingError.Context(codingPath: self.codingPath,
                                                                    debugDescription: "Cannot get superDecoder() -- unkeyed container is at end."))
        }

        let value = self.container[self.currentIndex]
        self.currentIndex += 1
        return _Decoder(referencing: value, at: self.decoder.codingPath, options: self.decoder.options)
    }
}

// MARK: - SingleValueDecodingContainer Methods

extension _Decoder: SingleValueDecodingContainer {

    private func expectNonNull<T>(_ type: T.Type) throws {
        guard !self.decodeNil() else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Expected \(type) but found null value instead."))
        }
    }

    public func decodeNil() -> Bool {
        return false
    }

    public func decode(_ type: Bool.Type) throws -> Bool {
        try expectNonNull(Bool.self)
        return try self.unbox(self.storage.topContainer, as: Bool.self)!
    }

    public func decode(_ type: Int.Type) throws -> Int {
        try expectNonNull(Int.self)
        return try self.unbox(self.storage.topContainer, as: Int.self)!
    }

    public func decode(_ type: Int8.Type) throws -> Int8 {
        try expectNonNull(Int8.self)
        return try self.unbox(self.storage.topContainer, as: Int8.self)!
    }

    public func decode(_ type: Int16.Type) throws -> Int16 {
        try expectNonNull(Int16.self)
        return try self.unbox(self.storage.topContainer, as: Int16.self)!
    }

    public func decode(_ type: Int32.Type) throws -> Int32 {
        try expectNonNull(Int32.self)
        return try self.unbox(self.storage.topContainer, as: Int32.self)!
    }

    public func decode(_ type: Int64.Type) throws -> Int64 {
        try expectNonNull(Int64.self)
        return try self.unbox(self.storage.topContainer, as: Int64.self)!
    }

    public func decode(_ type: UInt.Type) throws -> UInt {
        try expectNonNull(UInt.self)
        return try self.unbox(self.storage.topContainer, as: UInt.self)!
    }

    public func decode(_ type: UInt8.Type) throws -> UInt8 {
        try expectNonNull(UInt8.self)
        return try self.unbox(self.storage.topContainer, as: UInt8.self)!
    }

    public func decode(_ type: UInt16.Type) throws -> UInt16 {
        try expectNonNull(UInt16.self)
        return try self.unbox(self.storage.topContainer, as: UInt16.self)!
    }

    public func decode(_ type: UInt32.Type) throws -> UInt32 {
        try expectNonNull(UInt32.self)
        return try self.unbox(self.storage.topContainer, as: UInt32.self)!
    }

    public func decode(_ type: UInt64.Type) throws -> UInt64 {
        try expectNonNull(UInt64.self)
        return try self.unbox(self.storage.topContainer, as: UInt64.self)!
    }

    public func decode(_ type: Float.Type) throws -> Float {
        try expectNonNull(Float.self)
        return try self.unbox(self.storage.topContainer, as: Float.self)!
    }

    public func decode(_ type: Double.Type) throws -> Double {
        try expectNonNull(Double.self)
        return try self.unbox(self.storage.topContainer, as: Double.self)!
    }

    public func decode(_ type: String.Type) throws -> String {
        try expectNonNull(String.self)
        return try self.unbox(self.storage.topContainer, as: String.self)!
    }

    public func decode<T : Decodable>(_ type: T.Type) throws -> T {
        try expectNonNull(type)
        return try self.unbox_(self.storage.topContainer, as: type)!
    }
}
