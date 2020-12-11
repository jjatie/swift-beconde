//
//  DocumentReader.swift
//

@usableFromInline struct DocumentReader {
    @usableFromInline let array: [UInt8]
    @usableFromInline let count: Int

    @usableFromInline /* private(set) */ var index: Int = -1
    @usableFromInline /* private(set) */ var value: UInt8?

    @inlinable
    init<Bytes: Collection>(bytes: Bytes) where Bytes.Element == UInt8 {
        if let array = bytes as? [UInt8] {
            self.array = array
        } else {
            self.array = Array(bytes)
        }

        self.count = self.array.count
    }

    @inlinable subscript(bounds: Range<Int>) -> ArraySlice<UInt8> {
        self.array[bounds]
    }

    @inlinable mutating func read() -> (UInt8, Int)? {
        guard self.index < self.count - 1 else {
            self.value = nil
            self.index = self.array.endIndex
            return nil
        }

        self.index += 1
        self.value = self.array[self.index]

        return (self.value!, self.index)
    }

    @inlinable func remainingBytes(from index: Int) -> ArraySlice<UInt8> {
        self.array.suffix(from: index)
    }

    mutating func readUTF8String(ofLength length: Int) throws -> String {
        precondition(self.value == UInt8(ascii: ":"), "Expected to have read a colon character last")
        let startIndex = array.index(after: index)
        let endIndex = array.index(startIndex, offsetBy: length)
        guard endIndex <= array.endIndex else {
            throw BencodeParsingError.unexpectedEndOfFile
        }
        index = array.index(endIndex, offsetBy: -1)
        print(endIndex)
        return makeStringFast(self[startIndex..<endIndex])
    }

    // can be removed as soon https://bugs.swift.org/browse/SR-12126 and
    // https://bugs.swift.org/browse/SR-12125 has landed.
    // Thanks @weissi for making my code fast!
    @inlinable func makeStringFast<Bytes: Collection>(
        _ bytes: Bytes
    ) -> String where Bytes.Element == UInt8 {
        bytes.withContiguousStorageIfAvailable {
            String(decoding: $0, as: Unicode.UTF8.self)
        } ?? String(decoding: bytes, as: Unicode.UTF8.self)
    }
}
