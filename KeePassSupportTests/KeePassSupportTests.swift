//
//  KeePassSupportTests.swift
//  KeePassSupportTests
//
//  Created by Donny Lawrence on 6/9/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import XCTest
@testable import KeePassSupport

class KDBXParseTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testNoData() {
    XCTAssertThrowsError(try KDBXFile(withBytes: []))
    let file = try? KDBXFile(withBytes: [])
    XCTAssertNil(file)
  }
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
}
