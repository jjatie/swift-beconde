//
//  Ref.swift
//  

import Foundation

@usableFromInline
protocol BencodeValue { }
extension String: BencodeValue { }
extension Int: BencodeValue { }

typealias BDictionary = [String: BencodeValue]
extension BDictionary: BencodeValue { }

typealias BArray = [BencodeValue]
extension BArray: BencodeValue { }

@dynamicMemberLookup
final class Ref<Base> {
    var base: Base

    init(_ base: Base) {
        self.base = base
    }

    subscript<T>(dynamicMember keyPath: ReferenceWritableKeyPath<Base, T>) -> T {
        get { base[keyPath: keyPath] }
        set { base[keyPath: keyPath] = newValue }
    }
}

extension Ref: BencodeValue where Base: BencodeValue { }

extension Ref: Equatable where Base: Equatable {
    static func == (lhs: Ref, rhs: Ref) -> Bool {
        lhs.base == rhs.base
    }
}

extension Ref: Sequence where Base: Sequence {
    typealias Iterator = Base.Iterator

    func makeIterator() -> Base.Iterator {
        base.makeIterator()
    }
}

extension Ref: Collection where Base: Collection {
    typealias Element = Base.Element
    typealias Index = Base.Index

    var startIndex: Base.Index { base.startIndex }
    var endIndex: Base.Index { base.endIndex }

    func index(after i: Base.Index) -> Base.Index {
        base.index(after: i)
    }

    subscript(position: Base.Index) -> Base.Element {
        base[position]
    }
}

extension Ref: BidirectionalCollection where Base: BidirectionalCollection {
    func index(before i: Base.Index) -> Base.Index {
        base.index(before: i)
    }
}

extension Ref: RandomAccessCollection where Base: RandomAccessCollection { }

extension Ref: MutableCollection where Base: MutableCollection {
    subscript(position: Base.Index) -> Base.Element {
        get { base[position] }
        set { base[position] = newValue }
    }
}

extension Ref: RangeReplaceableCollection where Base: RangeReplaceableCollection {
    convenience init() {
        self.init([])
    }

    func insert(_ newElement: Base.Element, at i: Base.Index) {
        base.insert(newElement, at: i)
    }
}

extension Ref where Base == BDictionary {
    subscript(position: Base.Key) -> Base.Value? {
        get { base[position] }
        set { base[position] = newValue }
    }
}

extension Ref where Base == BArray {
    func append(_ newElement: Base.Element) {
        base.append(newElement)
    }
}
