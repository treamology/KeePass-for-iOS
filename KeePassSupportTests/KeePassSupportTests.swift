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
//  func testNoData() {
//    XCTAssertThrowsError(try KDBXCryptoHandler(withBytes: [], password: ""), "") { (error) in
//      if case KDBXCryptoHandler.ParseError.badKDBXFile = error {}
//      else { XCTFail() }
//    }
//  }
//
//  func testBadHeader() {
//    var data = Data(repeating: 0x00, count: 4)
//    XCTAssertThrowsError(try KDBXCryptoHandler(withBytes: [UInt8](data), password: ""), "") { (error) in
//      if case KDBXCryptoHandler.ParseError.badKDBXFile = error {}
//      else { XCTFail() }
//    }
//
//    data = Data(repeating: 0x00, count: 12)
//    XCTAssertThrowsError(try KDBXCryptoHandler(withBytes: [UInt8](data), password: ""), "") { (error) in
//      if case KDBXCryptoHandler.ParseError.badKDBXFile = error {}
//      else { XCTFail() }
//    }
//
//    data = Data(repeating: 0x00, count: 200)
//    data.replaceSubrange(0..<4, with: KDBXCryptoHandler.KDBX3_MAGIC)
//    XCTAssertThrowsError(try KDBXCryptoHandler(withBytes: [UInt8](data), password: ""), "") { (error) in
//      if case KDBXCryptoHandler.ParseError.badKDBXFile = error {}
//      else { XCTFail() }
//    }
//  }
//
//  func testBadDynamicHeader() {
//    let url = Bundle(for: type(of: self)).url(forResource: "BadDynamicHeader", withExtension: "kdbx")
//    let data = try! Data(contentsOf: url!)
//    XCTAssertThrowsError(try KDBXCryptoHandler(withBytes: [UInt8](data), password: ""), "") { (error) in
//      if case KDBXCryptoHandler.ParseError.badHeaderID = error {}
//      else { XCTFail("Threw: \(error)") }
//    }
//  }
//
//  func testBadPayload() {
//    let url = Bundle(for: type(of: self)).url(forResource: "BadPayload", withExtension: "kdbx")
//    let data = try! Data(contentsOf: url!)
//    XCTAssertThrowsError(try KDBXCryptoHandler(withBytes: [UInt8](data), password: ""), "") { (error) in
//      if case KDBXCryptoHandler.ParseError.badStreamStartBytes = error {}
//      else { XCTFail("Threw: \(error)") }
//    }
//  }
//
//  func testWrongPassword() {
//    let url = Bundle(for: type(of: self)).url(forResource: "ValidFile", withExtension: "kdbx")
//    let data = try! Data(contentsOf: url!)
//
//    XCTAssertThrowsError(try KDBXCryptoHandler(withBytes: [UInt8](data), password: "wrongpassword"), "") { (error) in
//      if case KDBXCryptoHandler.ParseError.badStreamStartBytes = error {}
//      else { XCTFail("Threw: \(error)") }
//    }
//  }
//
//  func testOpenValidFile() {
//    let url = Bundle(for: type(of: self)).url(forResource: "ValidFile", withExtension: "kdbx")
//    let data = try! Data(contentsOf: url!)
//
//    let handler = try! KDBXCryptoHandler(withBytes: [UInt8](data), password: "password")
//    let decodedXML = String(bytes: handler!.payload, encoding: .utf8)
//    let refURL = Bundle(for: type(of: self)).url(forResource: "ValidFileXML", withExtension: "xml")
//    let refXML = String(bytes: try! Data(contentsOf: refURL!), encoding: .utf8)
//
//    XCTAssertEqual(decodedXML, refXML!)
//  }
}
