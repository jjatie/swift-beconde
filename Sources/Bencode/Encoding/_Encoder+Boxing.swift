//
//  _Encoder+Boxing.swift
//  

import Foundation

extension _Encoder {
    func box(_ value: Bool) -> BencodeValue { value ? 1 : 0 }

    func box<T: FixedWidthInteger & Encodable>(_ value: T) -> BencodeValue { Int(value) }

    func box(_ value: String) -> BencodeValue { value }

    func box(_ float: Float) throws -> BencodeValue { try box(Double(float)) }

    func box(_ double: Double) throws -> BencodeValue {
        guard !double.isInfinite && !double.isNaN else {
//            guard case let .convertToString(
//                positiveInfinity: posInfString,
//                negativeInfinity: negInfString,
//                nan: nanString
//            ) = self.options.nonConformingFloatEncodingStrategy else {
                throw EncodingError._invalidFloatingPointValue(double, at: codingPath)
//            }
//
//            if double == Double.infinity {
//                return box(posInfString)
//            } else if double == -Double.infinity {
//                return box(negInfString)
//            } else {
//                return box(nanString)
//            }
        }

        return "\(double)"
    }

    func box(_ date: Date) throws -> BencodeValue? {
//        switch self.options.dateEncodingStrategy {
//        case .deferredToDate:
//            // Must be called with a surrounding with(pushedKey:) call.
//            // Dates encode as single-value objects; this can't both throw and push a container, so no need to catch the error.
//            try date.encode(to: self)
//            return self.storage.popContainer()
//
//        case .secondsSince1970:
            return box(Int(date.timeIntervalSince1970))
//
//        case .millisecondsSince1970:
//            return try box(1000.0 * date.timeIntervalSince1970)
//
//        case .iso8601:
//            if #available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
//                return box(_iso8601Formatter.string(from: date))
//            } else {
//                fatalError("ISO8601DateFormatter is unavailable on this platform.")
//            }
//
//        case .formatted(let formatter):
//            return box(formatter.string(from: date))
//
//        case .custom(let closure):
//            let depth = self.storage.count
//            do {
//                try closure(date, self)
//            } catch {
//                // If the value pushed a container before throwing, pop it back off to restore state.
//                if self.storage.count > depth {
//                    let _ = self.storage.popContainer()
//                }
//
//                throw error
//            }
//
//            guard self.storage.count > depth else {
//                // The closure didn't encode anything. Return the default keyed container.
//                return nil
//            }
//
//            // We can pop because the closure encoded something.
//            return self.storage.popContainer()
//        }
    }

    func box(_ data: Data) throws -> BencodeValue {
//        switch self.options.dataEncodingStrategy {
//        case .deferredToData:
//            // Must be called with a surrounding with(pushedKey:) call.
//            let depth = self.storage.count
//            do {
//                try data.encode(to: self)
//            } catch {
//                // If the value pushed a container before throwing, pop it back off to restore state.
//                // This shouldn't be possible for Data (which encodes as an array of bytes), but it can't hurt to catch a failure.
//                if self.storage.count > depth {
//                    let _ = self.storage.popContainer()
//                }
//
//                throw error
//            }
//
//            return self.storage.popContainer()
//
//        case .base64:
            return data.base64EncodedString()
//
//        case .custom(let closure):
//            let depth = self.storage.count
//            do {
//                try closure(data, self)
//            } catch {
//                // If the value pushed a container before throwing, pop it back off to restore state.
//                if self.storage.count > depth {
//                    let _ = self.storage.popContainer()
//                }
//
//                throw error
//            }
//
//            guard self.storage.count > depth else {
//                // The closure didn't encode anything. Return the default keyed container.
//                return NSDictionary()
//            }
//
//            // We can pop because the closure encoded something.
//            return self.storage.popContainer()
//        }
    }

    func box(_ dict: [String: Encodable]) throws -> BencodeValue? {
        let depth = self.storage.count
        let result = self.storage.pushKeyedContainer()
        do {
            for (key, value) in dict {
                self.codingPath.append(BencodeKey(stringValue: key, intValue: nil))
                defer { self.codingPath.removeLast() }
                result[key] = try box_(value)
            }
        } catch {
            // If the value pushed a container before throwing, pop it back off to restore state.
            if self.storage.count > depth {
                let _ = self.storage.popContainer()
            }

            throw error
        }

        // The top container should be a new container.
        guard self.storage.count > depth else {
            return nil
        }

        return self.storage.popContainer()
    }

    func box_(_ value: Encodable) throws -> BencodeValue {
        try self.box__(value) ?? [:]
    }

    // This method is called "box_" instead of "box" to disambiguate it from the overloads. Because the return type here is different from all of the "box" overloads (and is more general), any "box" calls in here would call back into "box" recursively instead of calling the appropriate overload, which is not what we want.
    func box__(_ value: Encodable) throws -> BencodeValue? {
        // Disambiguation between variable and function is required due to
        // issue tracked at: https://bugs.swift.org/browse/SR-1846
        let type = Swift.type(of: value)
        if type == Date.self || type == NSDate.self {
            // Respect Date encoding strategy
            return try self.box((value as! Date))
        } else if type == Data.self || type == NSData.self {
            // Respect Data encoding strategy
            return try self.box((value as! Data))
        } else if type == URL.self || type == NSURL.self {
            // Encode URLs as single strings.
            return self.box((value as! URL).absoluteString)
        } else if type == Decimal.self || type == NSDecimalNumber.self {
            return "\(value as! Decimal)"
        }

        // The value should request a container from the _Encoder.
        let depth = self.storage.count
        do {
            try value.encode(to: self)
        } catch {
            // If the value pushed a container before throwing, pop it back off to restore state.
            if self.storage.count > depth {
                let _ = self.storage.popContainer()
            }

            throw error
        }

        // The top container should be a new container.
        guard self.storage.count > depth else {
            return nil
        }

        return self.storage.popContainer()
    }
}
