//
//  _Decoder+Unboxing.swift
//  

import Foundation

extension _Decoder {
    /// Returns the given value unboxed from a container.
    func unbox(_ value: BencodeValue, as type: Bool.Type) throws -> Bool? {
        guard let int = value as? Int else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }

        if int == 0 {
            return false
        } else if int == 1 {
            return true
        } else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }
    }

    func unbox<T: FixedWidthInteger>(_ value: BencodeValue, as type: T.Type) throws -> T? {
        guard let int = value as? Int else {
            throw DecodingError._typeMismatch(
                at: self.codingPath,
                expectation: type,
                reality: value
            )
        }

        if type == Int.self {
            return (int as! T)
        }

        guard let number = T(exactly: int) else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: self.codingPath,
                    debugDescription: "Parsed Bencode number <\(int)> does not fit in \(type)."
                )
            )
        }

        return number
    }

    func unbox(_ value: BencodeValue, as type: Float.Type) throws -> Float? {
        guard let string = value as? String else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: Double.self, reality: value)
        }

        return Float(string)
    }

    func unbox(_ value: BencodeValue, as type: Double.Type) throws -> Double? {
        guard let string = value as? String else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: Double.self, reality: value)
        }

        return Double(string)
    }

    func unbox(_ value: BencodeValue, as type: String.Type) throws -> String? {
        guard let string = value as? String else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }

        return string
    }

    func unbox(_ value: BencodeValue, as type: Date.Type) throws -> Date? {
        guard !(value is NSNull) else { return nil }

//        switch self.options.dateDecodingStrategy {
//        case .deferredToDate:
//            self.storage.push(container: value)
//            defer { self.storage.popContainer() }
//            return try Date(from: self)
//
//        case .secondsSince1970:
            let double = try self.unbox(value, as: Double.self)!
            return Date(timeIntervalSince1970: double)
//
//        case .millisecondsSince1970:
//            let double = try self.unbox(value, as: Double.self)!
//            return Date(timeIntervalSince1970: double / 1000.0)
//
//        case .iso8601:
//            if #available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
//                let string = try self.unbox(value, as: String.self)!
//                guard let date = _iso8601Formatter.date(from: string) else {
//                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Expected date string to be ISO8601-formatted."))
//                }
//
//                return date
//            } else {
//                fatalError("ISO8601DateFormatter is unavailable on this platform.")
//            }
//
//        case .formatted(let formatter):
//            let string = try self.unbox(value, as: String.self)!
//            guard let date = formatter.date(from: string) else {
//                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Date string does not match format expected by formatter."))
//            }
//
//            return date
//
//        case .custom(let closure):
//            self.storage.push(container: value)
//            defer { self.storage.popContainer() }
//            return try closure(self)
//        }
    }

    func unbox(_ value: BencodeValue, as type: Data.Type) throws -> Data? {
//        guard !(value is NSNull) else { return nil }
//
//        switch self.options.dataDecodingStrategy {
//        case .deferredToData:
//            self.storage.push(container: value)
//            defer { self.storage.popContainer() }
//            return try Data(from: self)
//
//        case .base64:
            guard let string = value as? String else {
                throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
            }

            guard let data = Data(base64Encoded: string) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Encountered Data is not valid Base64."))
            }

            return data

//        case .custom(let closure):
//            self.storage.push(container: value)
//            defer { self.storage.popContainer() }
//            return try closure(self)
//        }
    }

    func unbox(_ value: BencodeValue, as type: Decimal.Type) throws -> Decimal? {
        guard let string = value as? String else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }

        return Decimal(string: string)
    }

    func unbox_<T : Decodable>(_ value: BencodeValue, as type: T.Type) throws -> T? {
        return try unbox__(value, as: type) as? T
    }

    private func unbox__(_ value: BencodeValue, as type: Decodable.Type) throws -> Any? {
        if type == Date.self || type == NSDate.self {
            return try self.unbox(value, as: Date.self)
        } else if type == Data.self || type == NSData.self {
            return try self.unbox(value, as: Data.self)
        } else if type == URL.self || type == NSURL.self {
            guard let urlString = try self.unbox(value, as: String.self) else {
                return nil
            }

            guard let url = URL(string: urlString) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath,
                                                                        debugDescription: "Invalid URL string."))
            }
            return url
        } else if type == Decimal.self || type == NSDecimalNumber.self {
            return try self.unbox(value, as: Decimal.self)
        } else {
            self.storage.push(container: value)
            defer { self.storage.popContainer() }
            return try type.init(from: self)
        }
    }
}
