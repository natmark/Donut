//
//  TemplateDirectoryTests.swift
//  DonutTests
//
//  Created by AtsuyaSato on 2018/06/07.
//

import XCTest
@testable import DonutKit

class TemplateDirectoryTests: XCTestCase {
    func testExample() {
        TemplateDirectory.homeDirectory = URL(fileURLWithPath: "/Users/Donut")
        XCTAssertEqual(TemplateDirectory.baseURL, URL(fileURLWithPath: "/Users/Donut/Library/Developers/Xcode/Template/Template Files"))
    }
}
