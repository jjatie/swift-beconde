//
//  BencodeParser.swift
//  

import Foundation

enum BencodeParsingError: Error {
    case unexpectedCharacter(ascii: UInt8, characterIndex: Int)
    case unexpectedEndOfFile

    case numberWithLeadingZero(index: Int)
}

struct BencodeParser {
    init() {}

    @inlinable
    static func parse<Bytes: Collection>(
        bytes: Bytes
    ) throws -> BencodeValue where Bytes.Element == UInt8 {
        var impl = _BencodeParser(bytes: bytes)
        return try impl.parse()
    }
}

@usableFromInline struct _BencodeParser {
    @usableFromInline var reader: DocumentReader
    @usableFromInline var depth: Int = 0

    @inlinable
    init<Bytes: Collection>(bytes: Bytes) where Bytes.Element == UInt8 {
        self.reader = DocumentReader(bytes: bytes)
    }

    @usableFromInline
    mutating func parse() throws -> BencodeValue {
        let value = try parseValue()

        #if DEBUG
        defer {
            guard self.depth == 0 else {
                preconditionFailure("Expected to end parsing with a depth of 0")
            }
        }
        #endif

        return value
    }

    // MARK: - General Value Parsing

    private mutating func parseValue() throws -> BencodeValue {
        while let (byte, index) = reader.read() {
            switch byte {
            case UInt8(ascii: "d"):
                return try parseDictionary()

            case UInt8(ascii: "l"):
                return try parseArray()

            case UInt8(ascii: "i"):
                return try parseInt()

            case UInt8(ascii: "1")...UInt8(ascii: "9"):
                return try self.parseString()

            default:
                throw BencodeParsingError.unexpectedCharacter(ascii: reader.value!, characterIndex: reader.index)
            }
        }

        throw BencodeParsingError.unexpectedEndOfFile
    }

    // MARK: - Parse String

    private mutating func parseString() throws -> String {
        let stringLength = try parseStringLength()
        return try reader.readUTF8String(ofLength: stringLength)
    }

    private mutating func parseStringLength() throws -> Int {
        let startIndex = self.reader.index
        while let (byte, index) = reader.read() {
            switch byte {
            case UInt8(ascii: "1")...UInt8(ascii: "9"):
                continue

            case UInt8(ascii: ":"):
                let string = reader.makeStringFast(reader[startIndex..<index])
                return Int(string)!

            default:
                throw BencodeParsingError.unexpectedCharacter(ascii: reader.value!, characterIndex: reader.index)
            }
        }

        throw BencodeParsingError.unexpectedEndOfFile
    }

    // MARK: - Parse Number

    private mutating func parseInt() throws -> Int {
        assert(self.reader.value == UInt8(ascii: "i"))
        // parse first character
        guard let (value, stringStartIndex) = self.reader.read() else {
            throw BencodeParsingError.unexpectedEndOfFile
        }

        var numbersSinceControlChar: UInt = 0
        var hasLeadingZero = false


        switch value {
        case UInt8(ascii: "0"):
            numbersSinceControlChar = 1
            hasLeadingZero = true

        case UInt8(ascii: "1")...UInt8(ascii: "9"):
            numbersSinceControlChar = 1

        case UInt8(ascii: "-"):
            numbersSinceControlChar = 0

        default:
            preconditionFailure("This state should never be reached")
        }

        // parse everything else
        while let (byte, index) = reader.read() {
            switch byte {
            case UInt8(ascii: "0"):
                if hasLeadingZero {
                    throw BencodeParsingError.numberWithLeadingZero(index: index)
                }
                if numbersSinceControlChar == 0 {
                    // the number started with a minus. this is the leading zero.
                    hasLeadingZero = true
                    throw BencodeParsingError.numberWithLeadingZero(index: index)
                }
                numbersSinceControlChar += 1

            case UInt8(ascii: "1")...UInt8(ascii: "9"):
                if hasLeadingZero {
                    throw BencodeParsingError.numberWithLeadingZero(index: index)
                }
                numbersSinceControlChar += 1

            case UInt8(ascii: "e"):
                guard numbersSinceControlChar > 0 else {
                    throw BencodeParsingError.unexpectedCharacter(ascii: reader.value!, characterIndex: reader.index)
                }

                let string = self.reader.makeStringFast(self.reader[stringStartIndex ..< index])
                return Int(string)!

            default:
                throw BencodeParsingError.unexpectedCharacter(ascii: reader.value!, characterIndex: reader.index)
            }
        }

        guard numbersSinceControlChar > 0 else {
            throw BencodeParsingError.unexpectedEndOfFile
        }

        let string = String(
            decoding: self.reader.remainingBytes(from: stringStartIndex),
            as: Unicode.UTF8.self
        )
        return Int(string)!
    }

    // MARK: - Parse Array

    private mutating func parseArray() throws -> BArray {
        assert(self.reader.value == UInt8(ascii: "l"))
        self.depth += 1
        defer { depth -= 1 }

        var array = BArray()
        array.reserveCapacity(10)

        // parse first value or immediate end

        while true {
            do {
                let value = try parseValue()
                array.append(value)
            } catch BencodeParsingError.unexpectedCharacter(ascii: UInt8(ascii: "e"), _) {
                return array
            } catch {
                throw error
            }
        }
    }

    // MARK: - Object parsing

    private enum ObjectState: Equatable {
        case expectKeyOrEnd
        case expectValue(key: String)
    }

    private mutating func parseDictionary() throws -> BDictionary {
        assert(self.reader.value == UInt8(ascii: "d"))
        self.depth += 1
        defer { depth -= 1 }

        var state = ObjectState.expectKeyOrEnd
        var dictionary = BDictionary()
        dictionary.reserveCapacity(20)

        while true {
            switch state {
            case .expectKeyOrEnd:
                guard let (byte, index) = reader.read() else {
                    throw BencodeParsingError.unexpectedEndOfFile
                }

                switch byte {
                case UInt8(ascii: "1")...UInt8(ascii: "9"):
                    state = .expectValue(key: try self.parseString())

                case UInt8(ascii: "e"):
                    return dictionary

                default:
                    throw BencodeParsingError.unexpectedCharacter(ascii: reader.value!, characterIndex: reader.index)
                }


            case .expectValue(let key):
                let value = try parseValue()
                dictionary[key] = value
                state = .expectKeyOrEnd
            }
        }
    }
}
