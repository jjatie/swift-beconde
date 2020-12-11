import XCTest
@testable import Bencode

class BencodeDecoderTests: XCTestCase {
    func testDecodeHelloWorld() throws {
        struct HelloWorld: Codable {
            let hello: String
            let subStruct: SubStruct
            let test: Bool
            let number: UInt
            let numbers: [UInt]

            struct SubStruct: Codable, Equatable {
                let name: String
            }
        }

        do {
            let string = #"""
            d5:hello5:world9:subStructd4:name4:hihie4:testi1e6:numberi123e7:numbersli12ei345ei78eee
            """#

            let result = try BencodeDecoder().decode(HelloWorld.self, from: string.utf8)

            XCTAssertEqual(result.hello, "world")
            XCTAssertEqual(result.subStruct, HelloWorld.SubStruct(name: "hihi"))
            XCTAssertEqual(result.test, true)
            XCTAssertEqual(result.number, 123)
            XCTAssertEqual(result.numbers, [12, 345, 78])
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testGetUnkeyedContainerFromKeyedPayload() {
        struct HelloWorld: Decodable {
            init(from decoder: Decoder) throws {
                _ = try decoder.unkeyedContainer()
                XCTFail("Did not expect to reach this point")
            }
        }

        let string = #"d5:hello5:worlde"#
        XCTAssertThrowsError(
            try BencodeDecoder().decode(HelloWorld.self, from: string.utf8)
        ) { error in
            guard case Swift.DecodingError.typeMismatch(let type, let context) = error else {
                XCTFail("Unexpected error: \(error)"); return
            }

            XCTAssertTrue(type == [BencodeValue].self)
            XCTAssertEqual(context.debugDescription, "Expected to decode Array<BencodeValue> but found Dictionary<String, BencodeValue> instead.")
        }
    }

    func testGetKeyedContainerFromUnkeyedPayload() {
        struct HelloWorld: Decodable {
            enum CodingKeys: String, CodingKey {
                case hello
            }

            init(from decoder: Decoder) throws {
                _ = try decoder.container(keyedBy: CodingKeys.self)
                XCTFail("Did not expect to reach this point")
            }
        }

        let string = #"l4:haha4:hihie"#
        XCTAssertThrowsError(
            try BencodeDecoder().decode(HelloWorld.self, from: string.utf8)
        ) { error in
            guard case Swift.DecodingError.typeMismatch(let type, let context) = error else {
                XCTFail("Unexpected error: \(error)"); return
            }

            XCTAssertTrue(type == [String: BencodeValue].self)
            XCTAssertEqual(context.debugDescription, "Expected to decode Dictionary<String, BencodeValue> but found Array<BencodeValue> instead.")
        }
    }

    func testDecodeInvalidBencode() {
        struct HelloWorld: Decodable {
            enum CodingKeys: String, CodingKey {
                case hello
            }

            init(from _: Decoder) throws {
                XCTFail("Did not expect to be called")
            }
        }

        let string = #"d6:hello👩‍👩‍👧‍👧i123ee"#
        XCTAssertThrowsError(
            try BencodeDecoder().decode(HelloWorld.self, from: string.utf8)
        ) { error in
            guard case Swift.DecodingError.dataCorrupted(let context) = error else {
                XCTFail("Unexpected error: \(error)"); return
            }

            XCTAssertEqual(context.codingPath.count, 0)
            XCTAssertEqual(context.debugDescription, "The given data was not valid Bencode.")
            XCTAssertNotNil(context.underlyingError)
        }
    }

    func testDecodeEmptyArray() {
        struct Foo: Decodable {
            let array: [String]
        }

        let string = #"""
        d5:arraylee
        """#

        let decoder = BencodeDecoder()
        var result: Foo?
        XCTAssertNoThrow(result = try decoder.decode(Foo.self, from: string.utf8))
        XCTAssertEqual(result?.array, [])
    }

    func testIfUserInfoIsHandedDown() {
        struct Foo: Decodable {
            init(decoder: Decoder) {
                XCTAssertEqual(decoder.userInfo as? [CodingUserInfoKey: String], [CodingUserInfoKey(rawValue: "foo")!: "bar"])
            }
        }

        let string = #"de"#
        let decoder = BencodeDecoder()
        decoder.userInfo[CodingUserInfoKey(rawValue: "foo")!] = "bar"
        XCTAssertNoThrow(_ = try decoder.decode(Foo.self, from: string.utf8))
    }
}
