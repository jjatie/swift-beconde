//
//  _BencoderEncodingStorage.swift
//  

import Foundation

struct _EncodingStorage {
    // MARK: Properties

    /// The container stack.
    private(set) var containers: [BencodeValue] = []

    // MARK: - Initialization

    /// Initializes `self` with no containers.
    init() {}

    // MARK: - Modifying the Stack

    var count: Int {
        self.containers.count
    }

    mutating func pushKeyedContainer() -> Ref<BDictionary> {
        let dictionary = Ref<BDictionary>([:])
        self.containers.append(dictionary)
        return dictionary
    }

    mutating func pushUnkeyedContainer() -> Ref<BArray> {
        let array = Ref<BArray>([])
        self.containers.append(array)
        return array
    }

    mutating func push(container: __owned BencodeValue) {
        self.containers.append(container)
    }

    mutating func popContainer() -> BencodeValue {
        precondition(!self.containers.isEmpty, "Empty container stack.")
        return self.containers.popLast()!
    }
}
