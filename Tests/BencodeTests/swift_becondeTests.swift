import XCTest
@testable import Bencode

struct Test: Codable {
    let test = "abc"
    let whoKnows = ["me" : [145]]

    private enum CodingKeys: String, CodingKey {
        case test, whoKnows = "who knows"
    }
}

final class swift_becondeTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let obj = Test()
        let encoder = BencodeEncoder()
        let data = try! encoder.encode(obj)
        debugPrint(String(data: data, encoding: .utf8)!)
        let decoder = BencodeDecoder()
        XCTAssertNoThrow(try decoder.decode(Test.self, from: data))
//        let decodedObj = try!
//        debugPrint(decodedObj)

//        XCTAssertEqual(swift_beconde().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
