//
//  TemplateDirectoryTests.swift
//  DonutTests
//
//  Created by AtsuyaSato on 2018/06/07.
//

import XCTest
@testable import DonutKit

class TemplateDirectoryTests: XCTestCase {
    func testBaseURL() {
        TemplateDirectory.homeDirectory = URL(fileURLWithPath: "/Users/Donut")
        XCTAssertEqual(TemplateDirectory.basePath, URL(fileURLWithPath: "/Users/Donut/Library/Developer/Xcode/Templates/File Templates"))
    }
}
