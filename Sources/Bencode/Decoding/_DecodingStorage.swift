//
//  _DecodingStorage.swift
//  
//
//  Created by Jacob Christie on 2020-12-09.
//

struct _DecodingStorage {
    // MARK: Properties

    /// The container stack.
    private(set) var containers: BArray = []

    // MARK: - Initialization

    /// Initializes `self` with no containers.
    init() {}

    // MARK: - Modifying the Stack

    var count: Int {
        return self.containers.count
    }

    var topContainer: BencodeValue {
        precondition(!self.containers.isEmpty, "Empty container stack.")
        return self.containers.last!
    }

    mutating func push(container: __owned BencodeValue) {
        self.containers.append(container)
    }

    mutating func popContainer() {
        precondition(!self.containers.isEmpty, "Empty container stack.")
        self.containers.removeLast()
    }
}
