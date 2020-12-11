//
//  _Encoder.swift
//  

extension BencodeEncoder {
    struct _Options {
//        let dateEncodingStrategy: DateEncodingStrategy
//        let dataEncodingStrategy: DataEncodingStrategy
//        let nonConformingFloatEncodingStrategy: NonConformingFloatEncodingStrategy
//        let keyEncodingStrategy: KeyEncodingStrategy
        let userInfo: [CodingUserInfoKey : Any]
    }

    var options: _Options {
        _Options(
//            dateEncodingStrategy: dateEncodingStrategy,
//            dataEncodingStrategy: dataEncodingStrategy,
//            nonConformingFloatEncodingStrategy: nonConformingFloatEncodingStrategy,
//            keyEncodingStrategy: keyEncodingStrategy,
            userInfo: userInfo
        )
    }
}

class _Encoder: Encoder {
    /// The encoder's storage.
    var storage = _EncodingStorage()

    /// Options set on the top-level encoder.
    let options: BencodeEncoder._Options

    var codingPath: [CodingKey]

    var userInfo: [CodingUserInfoKey : Any] {
        options.userInfo
    }

    // MARK: - Initialization

    init(options: BencodeEncoder._Options, codingPath: [CodingKey] = []) {
        self.options = options
        self.codingPath = codingPath
    }

    /// Returns whether a new element can be encoded at this coding path.
    ///
    /// `true` if an element has not yet been encoded at this coding path; `false` otherwise.
    var canEncodeNewValue: Bool {
        // Every time a new value gets encoded, the key it's encoded for is pushed onto the coding path (even if it's a nil key from an unkeyed container).
        // At the same time, every time a container is requested, a new value gets pushed onto the storage stack.
        // If there are more values on the storage stack than on the coding path, it means the value is requesting more than one container, which violates the precondition.
        //
        // This means that anytime something that can request a new container goes onto the stack, we MUST push a key onto the coding path.
        // Things which will not request containers do not need to have the coding path extended for them (but it doesn't matter if it is, because they will not reach here).
        return self.storage.count == self.codingPath.count
    }

    // MARK: - Encoder Methods

    func container<Key>(
        keyedBy type: Key.Type
    ) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        // If an existing keyed container was already requested, return that one.
        let topContainer: Ref<Dictionary<String, BencodeValue>>
        if self.canEncodeNewValue {
            // We haven't yet pushed a container at this level; do so here.
            topContainer = self.storage.pushKeyedContainer()
        } else {
            guard let container = self.storage.containers.last as? Ref<BDictionary> else {
                preconditionFailure("Attempt to push new keyed encoding container when already previously encoded at this path.")
            }

            topContainer = container
        }

        let container = _KeyedEncodingContainer<Key>(referencing: self, codingPath: self.codingPath, wrapping: topContainer)
        return KeyedEncodingContainer(container)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        // If an existing unkeyed container was already requested, return that one.
        let topContainer: Ref<BArray>
        if self.canEncodeNewValue {
            // We haven't yet pushed a container at this level; do so here.
            topContainer = self.storage.pushUnkeyedContainer()
        } else {
            guard let container = self.storage.containers.last as? Ref<BArray> else {
                preconditionFailure("Attempt to push new unkeyed encoding container when already previously encoded at this path.")
            }

            topContainer = container
        }

        return _UnkeyedEncodingContainer(
            referencing: self,
            codingPath: self.codingPath,
            wrapping: topContainer
        )

    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        self
    }
}

// MARK: - Encoding Containers

private struct _KeyedEncodingContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
    /// A reference to the encoder we're writing to.
    private let encoder: _Encoder

    /// A reference to the container we're writing to.
    private let container: Ref<BDictionary>

    /// The path of coding keys taken to get to this point in encoding.
    private(set) var codingPath: [CodingKey]

    // MARK: - Initialization

    /// Initializes `self` with the given references.
    init(
        referencing encoder: _Encoder,
        codingPath: [CodingKey],
        wrapping container: Ref<BDictionary>
    ) {
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
    }

    mutating func encodeNil(forKey key: Key) throws {
        self.container[key.stringValue] = nil
    }

    mutating func encode(_ value: Bool, forKey key: Key) throws {
        self.container[key.stringValue] = self.encoder.box(value)
    }

    mutating func encode(_ value: Int, forKey key: Key) throws {
        self.container[key.stringValue] = self.encoder.box(value)
    }

    mutating func encode(_ value: Int8, forKey key: Key) throws {
        self.container[key.stringValue] = self.encoder.box(value)
    }

    mutating func encode(_ value: Int16, forKey key: Key) throws {
        self.container[key.stringValue] = self.encoder.box(value)
    }

    mutating func encode(_ value: Int32, forKey key: Key) throws {
        self.container[key.stringValue] = self.encoder.box(value)
    }

    mutating func encode(_ value: Int64, forKey key: Key) throws {
        self.container[key.stringValue] = self.encoder.box(value)
    }

    mutating func encode(_ value: UInt, forKey key: Key) throws {
        self.container[key.stringValue] = self.encoder.box(value)
    }

    mutating func encode(_ value: UInt8, forKey key: Key) throws {
        self.container[key.stringValue] = self.encoder.box(value)
    }

    mutating func encode(_ value: UInt16, forKey key: Key) throws {
        self.container[key.stringValue] = self.encoder.box(value)
    }

    mutating func encode(_ value: UInt32, forKey key: Key) throws {
        self.container[key.stringValue] = self.encoder.box(value)
    }

    mutating func encode(_ value: UInt64, forKey key: Key) throws {
        self.container[key.stringValue] = self.encoder.box(value)
    }

    mutating func encode(_ value: String, forKey key: Key) throws {
        self.container[key.stringValue] = self.encoder.box(value)
    }

    mutating func encode(_ value: Float, forKey key: Key) throws {
        // Since the float may be invalid and throw, the coding path needs to contain this key.
        self.encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        self.container[key.stringValue] = try self.encoder.box(value)
    }

    mutating func encode(_ value: Double, forKey key: Key) throws {
        // Since the double may be invalid and throw, the coding path needs to contain this key.
        self.encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        self.container[key.stringValue] = try self.encoder.box(value)
    }

    mutating func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
        // Since the value may be invalid and throw, the coding path needs to contain this key.
        self.encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        self.container[key.stringValue] = try self.encoder.box_(value)
    }

    mutating func nestedContainer<NestedKey>(
        keyedBy keyType: NestedKey.Type,
        forKey key: Key
    ) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let containerKey = key.stringValue
        let dictionary: Ref<BDictionary>
        if let existingContainer = self.container[containerKey] {
            precondition(
                existingContainer is Ref<BDictionary>,
                "Attempt to re-encode into nested KeyedEncodingContainer<\(Key.self)> for key \"\(containerKey)\" is invalid: non-keyed container already encoded for this key"
            )
            dictionary = existingContainer as! Ref<BDictionary>
        } else {
            dictionary = Ref<BDictionary>([:])
            self.container[containerKey] = dictionary
        }

        self.codingPath.append(key)
        defer { self.codingPath.removeLast() }

        let container = _KeyedEncodingContainer<NestedKey>(
            referencing: self.encoder,
            codingPath: self.codingPath,
            wrapping: dictionary
        )
        return KeyedEncodingContainer(container)
    }

    mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let containerKey = key.stringValue
        let array: Ref<BArray>
        if let existingContainer = self.container[containerKey] {
            precondition(
                existingContainer is Ref<BArray>,
                "Attempt to re-encode into nested UnkeyedEncodingContainer for key \"\(containerKey)\" is invalid: keyed container/single value already encoded for this key"
            )
            array = existingContainer as! Ref<BArray>
        } else {
            array = Ref<BArray>([])
            self.container[containerKey] = array
        }

        self.codingPath.append(key)
        defer { self.codingPath.removeLast() }
        return _UnkeyedEncodingContainer(
            referencing: self.encoder,
            codingPath: self.codingPath,
            wrapping: array
        )
    }

    mutating func superEncoder() -> Encoder {
        _ReferencingEncoder(
            referencing: self.encoder,
            key: BencodeKey.super,
            convertedKey: BencodeKey.super,
            wrapping: self.container
        )
    }

    mutating func superEncoder(forKey key: Key) -> Encoder {
        _ReferencingEncoder(
            referencing: self.encoder,
            key: key,
            convertedKey: key,
            wrapping: self.container
        )
    }
}

private struct _UnkeyedEncodingContainer: UnkeyedEncodingContainer {
    // MARK: Properties

    /// A reference to the encoder we're writing to.
    private let encoder: _Encoder

    /// A reference to the container we're writing to.
    private let container: Ref<BArray>

    /// The path of coding keys taken to get to this point in encoding.
    private(set) var codingPath: [CodingKey]

    /// The number of elements encoded into the container.
    var count: Int {
        self.container.count
    }

    // MARK: - Initialization

    /// Initializes `self` with the given references.
    init(
        referencing encoder: _Encoder,
        codingPath: [CodingKey],
        wrapping container: Ref<BArray>
    ) {
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
    }

    // MARK: - UnkeyedEncodingContainer Methods

    mutating func encodeNil() throws {
        // no-op
    }

    public mutating func encode(_ value: Bool) throws {
        self.container.append(self.encoder.box(value))
    }
    public mutating func encode(_ value: Int) throws {
        self.container.append(self.encoder.box(value))
    }
    public mutating func encode(_ value: Int8) throws {
        self.container.append(self.encoder.box(value))
    }
    public mutating func encode(_ value: Int16) throws {
        self.container.append(self.encoder.box(value))
    }
    public mutating func encode(_ value: Int32) throws {
        self.container.append(self.encoder.box(value))
    }
    public mutating func encode(_ value: Int64) throws {
        self.container.append(self.encoder.box(value))
    }
    public mutating func encode(_ value: UInt) throws {
        self.container.append(self.encoder.box(value))
    }
    public mutating func encode(_ value: UInt8) throws {
        self.container.append(self.encoder.box(value))
    }
    public mutating func encode(_ value: UInt16) throws {
        self.container.append(self.encoder.box(value))
    }
    public mutating func encode(_ value: UInt32) throws {
        self.container.append(self.encoder.box(value))
    }
    public mutating func encode(_ value: UInt64) throws {
        self.container.append(self.encoder.box(value))
    }
    public mutating func encode(_ value: String) throws {
        self.container.append(self.encoder.box(value))
    }

    public mutating func encode(_ value: Float)  throws {
        // Since the float may be invalid and throw, the coding path needs to contain this key.
        self.encoder.codingPath.append(BencodeKey(index: self.count))
        defer { self.encoder.codingPath.removeLast() }
        self.container.append(try self.encoder.box(value))
    }

    public mutating func encode(_ value: Double) throws {
        // Since the double may be invalid and throw, the coding path needs to contain this key.
        self.encoder.codingPath.append(BencodeKey(index: self.count))
        defer { self.encoder.codingPath.removeLast() }
        self.container.append(try self.encoder.box(value))
    }

    public mutating func encode<T : Encodable>(_ value: T) throws {
        self.encoder.codingPath.append(BencodeKey(index: self.count))
        defer { self.encoder.codingPath.removeLast() }
        self.container.append(try self.encoder.box_(value))
    }

    mutating func nestedContainer<NestedKey: CodingKey>(
        keyedBy keyType: NestedKey.Type
    ) -> KeyedEncodingContainer<NestedKey> {
        self.codingPath.append(BencodeKey(index: self.count))
        defer { self.codingPath.removeLast() }

        let dictionary = Ref<BDictionary>([:])
        self.container.append(dictionary)

        let container = _KeyedEncodingContainer<NestedKey>(
            referencing: self.encoder,
            codingPath: self.codingPath,
            wrapping: dictionary
        )
        return KeyedEncodingContainer(container)
    }

    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        self.codingPath.append(BencodeKey(index: self.count))
        defer { self.codingPath.removeLast() }

        let array = Ref<BArray>([])
        self.container.append(array)
        return _UnkeyedEncodingContainer(
            referencing: self.encoder,
            codingPath: self.codingPath,
            wrapping: array
        )
    }

    mutating func superEncoder() -> Encoder {
        _ReferencingEncoder(
            referencing: self.encoder, 
            at: self.container.count,
            wrapping: self.container
        )
    }
}

// MARK: - SingleValueEncodingContainer Methods

extension _Encoder: SingleValueEncodingContainer {
    private func assertCanEncodeNewValue() {
        precondition(
            self.canEncodeNewValue,
            "Attempt to encode value through single value container when previously value already encoded."
        )
    }

    func encodeNil() throws {
        assertCanEncodeNewValue()
//        self.storage.push
    }

    func encode(_ value: Bool) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }

    func encode(_ value: Int) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }

    func encode(_ value: Int8) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }

    func encode(_ value: Int16) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }

    func encode(_ value: Int32) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }

    func encode(_ value: Int64) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }

    func encode(_ value: UInt) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }

    func encode(_ value: UInt8) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }

    func encode(_ value: UInt16) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }

    func encode(_ value: UInt32) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }

    func encode(_ value: UInt64) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }

    func encode(_ value: String) throws {
        assertCanEncodeNewValue()
    }

    func encode(_ value: Float) throws {
        assertCanEncodeNewValue()
    }

    func encode(_ value: Double) throws {
        assertCanEncodeNewValue()
    }

    func encode<T : Encodable>(_ value: T) throws {
        assertCanEncodeNewValue()
        try self.storage.push(container: self.box_(value))
    }
}

// MARK: - _ReferencingEncoder

/// `_ReferencingEncoder` is a special subclass of `_Encoder` which has its own storage, but references the contents of a different encoder.
/// It's used in superEncoder(), which returns a new encoder for encoding a superclass -- the lifetime of the encoder should not escape the scope it's created in, but it doesn't necessarily know when it's done being used (to write to the original container).
private class _ReferencingEncoder : _Encoder {
    // MARK: Reference types.

    /// The type of container we're referencing.
    private enum Reference {
        /// Referencing a specific index in an array container.
        case array(Ref<BArray>, Int)

        /// Referencing a specific key in a dictionary container.
        case dictionary(Ref<BDictionary>, String)
    }

    // MARK: - Properties

    /// The encoder we're referencing.
    let encoder: _Encoder

    /// The container reference itself.
    private let reference: Reference

    // MARK: - Initialization

    /// Initializes `self` by referencing the given array container in the given encoder.
    init(referencing encoder: _Encoder, at index: Int, wrapping array: Ref<BArray>) {
        self.encoder = encoder
        self.reference = .array(array, index)
        super.init(options: encoder.options, codingPath: encoder.codingPath)

        self.codingPath.append(BencodeKey(index: index))
    }

    /// Initializes `self` by referencing the given dictionary container in the given encoder.
    init(
        referencing encoder: _Encoder,
        key: CodingKey,
        convertedKey: __shared CodingKey,
        wrapping dictionary: Ref<BDictionary>
    ) {
        self.encoder = encoder
        self.reference = .dictionary(dictionary, convertedKey.stringValue)
        super.init(options: encoder.options, codingPath: encoder.codingPath)

        self.codingPath.append(key)
    }

    // MARK: - Coding Path Operations

    override var canEncodeNewValue: Bool {
        // With a regular encoder, the storage and coding path grow together.
        // A referencing encoder, however, inherits its parents coding path, as well as the key it was created for.
        // We have to take this into account.
        return self.storage.count == self.codingPath.count - self.encoder.codingPath.count - 1
    }

    // MARK: - Deinitialization

    // Finalizes `self` by writing the contents of our storage to the referenced encoder's storage.
    deinit {
        let value: BencodeValue
        switch self.storage.count {
        case 0: value = BDictionary()
        case 1: value = self.storage.popContainer()
        default: fatalError("Referencing encoder deallocated with multiple containers on stack.")
        }

        switch self.reference {
        case .array(let array, let index):
            array.insert(value, at: index)

        case .dictionary(let dictionary, let key):
            dictionary[key] = value
        }
    }
}
