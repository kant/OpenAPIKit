//
//  URLTemplateTests.swift
//  
//
//  Created by Mathew Polzin on 8/13/20.
//

import Foundation
import OpenAPIKit
import XCTest

final class URLTemplateTests: XCTestCase {
    func test_init() {
        XCTAssertNotNil(URLTemplate(rawValue: "https://website.com"))
        XCTAssertEqual(URLTemplate(rawValue: "https://website.com"), URLTemplate(url: URL(string: "https://website.com")!))
    }

    func test_urlAccess() {
        let t1 = URLTemplate(rawValue: "https://website.com")
        let t2 = URLTemplate(rawValue: "{scheme}://website.com")

        XCTAssertEqual(t1?.url, URL(string: "https://website.com"))
        XCTAssertNil(t2?.url)
    }

    func test_absoluteString() {
        let t1 = URLTemplate(rawValue: "https://website.com")
        let t2 = URLTemplate(rawValue: "/a/relative/path")
        let t3 = URLTemplate(rawValue: "website.com?query=value")

        XCTAssertEqual(t1?.absoluteString, URL(string: "https://website.com")?.absoluteString)
        XCTAssertEqual(t2?.absoluteString, URL(string: "/a/relative/path")?.absoluteString)
        XCTAssertEqual(t3?.absoluteString, URL(string: "website.com?query=value")?.absoluteString)
    }
}

// MARK: - Codable
extension URLTemplateTests {
    func test_encode() throws {
        let t1 = TemplatedURLWrapper(
            url: URLTemplate(rawValue: "https://website.com")
        )

        assertJSONEquivalent(
            try orderUnstableTestStringFromEncoding(of: t1),
            """
            {
              "url" : "https:\\/\\/website.com"
            }
            """
        )
    }

    func test_decode() throws {
        let t1Data = """
        {
          "url": "https://website.com"
        }
        """.data(using: .utf8)!

        let t1 = try orderUnstableDecode(TemplatedURLWrapper.self, from: t1Data)

        XCTAssertEqual(
            t1.url,
            URLTemplate(rawValue: "https://website.com")
        )
    }

    func test_encode_withVariables() throws {
        let t1 = TemplatedURLWrapper(
            url: URLTemplate(rawValue: "{scheme}://{host}.com")
        )

        assertJSONEquivalent(
            try orderUnstableTestStringFromEncoding(of: t1),
            """
            {
              "url" : "{scheme}:\\/\\/{host}.com"
            }
            """
        )
    }

    func test_decode_withVariables() throws {
        let t1Data = """
        {
          "url": "{scheme}://{host}.com"
        }
        """.data(using: .utf8)!

        let t1 = try orderUnstableDecode(TemplatedURLWrapper.self, from: t1Data)

        XCTAssertEqual(
            t1.url,
            URLTemplate(rawValue: "{scheme}://{host}.com")
        )
    }
}

fileprivate struct TemplatedURLWrapper: Codable {
    let url: URLTemplate?
}
