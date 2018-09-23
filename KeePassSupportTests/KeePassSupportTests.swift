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
  func testNoData() {
    XCTAssertThrowsError(try KDBX3File(withFileBytes: [], password: [], keyfile: nil), "") { (error) in
      if case KDBX3File.ParseError.badKDBXFile = error {}
      else { XCTFail("Threw: \(error)") }
    }
  }

  func testBadHeader() {
    var data = Data(repeating: 0x00, count: 4)
    XCTAssertThrowsError(try KDBX3File(withFileBytes: [UInt8](data), password: [], keyfile: nil), "") { (error) in
      if case KDBX3File.ParseError.badKDBXFile = error {}
      else { XCTFail("Threw: \(error)") }
    }

    data = Data(repeating: 0x00, count: 12)
    XCTAssertThrowsError(try KDBX3File(withFileBytes: [UInt8](data), password: [], keyfile: nil), "") { (error) in
      if case KDBX3File.ParseError.badKDBXFile = error {}
      if case KDBX3File.ParseError.versionMismatch = error {}
      else { XCTFail("Threw: \(error)") }
    }

    data = Data(repeating: 0x00, count: 200)
    data.replaceSubrange(0..<4, with: KDBX3File.MAGIC)
    XCTAssertThrowsError(try KDBX3File(withFileBytes: [UInt8](data), password: [], keyfile: nil), "") { (error) in
      if case KDBX3File.ParseError.badKDBXFile = error {}
      else { XCTFail("Threw: \(error)") }
    }
  }

  func testBadDynamicHeader() {
    let url = Bundle(for: type(of: self)).url(forResource: "BadDynamicHeader", withExtension: "kdbx")
    let data = try! Data(contentsOf: url!)
    XCTAssertThrowsError(try KDBX3File(withFileBytes: [UInt8](data), password: [], keyfile: nil), "") { (error) in
      if case KDBX3File.ParseError.badHeaderID = error {}
      else { XCTFail("Threw: \(error)") }
    }
  }

  func testBadPayload() {
    let url = Bundle(for: type(of: self)).url(forResource: "BadPayload", withExtension: "kdbx")
    let data = try! Data(contentsOf: url!)
    XCTAssertThrowsError(try KDBX3File(withFileBytes: [UInt8](data), password: [], keyfile: nil), "") { (error) in
      if case KDBX3File.ParseError.badStreamStartBytes = error {}
      else { XCTFail("Threw: \(error)") }
    }
  }

  func testWrongPassword() {
    let url = Bundle(for: type(of: self)).url(forResource: "ValidFile", withExtension: "kdbx")
    let data = try! Data(contentsOf: url!)

    XCTAssertThrowsError(try KDBX3File(withFileBytes: [UInt8](data), password: [UInt8]("wrongpassword".data(using: .utf8)!), keyfile: nil), "") { (error) in
      if case KDBX3File.ParseError.badStreamStartBytes = error {}
      else { XCTFail("Threw: \(error)") }
    }
  }

  func testOpenValidFile() {
    let url = Bundle(for: type(of: self)).url(forResource: "ValidFile", withExtension: "kdbx")
    let data = try! Data(contentsOf: url!)

    let handler = try! KDBX3File(withFileBytes: [UInt8](data), password: [UInt8]("password".data(using: .utf8)!), keyfile: nil)
    let decodedXML = String(bytes: handler.payloadBytes, encoding: .utf8)
    let refURL = Bundle(for: type(of: self)).url(forResource: "ValidFileXML", withExtension: "xml")
    let refXML = String(bytes: try! Data(contentsOf: refURL!), encoding: .utf8)

    XCTAssertEqual(decodedXML, refXML!)
  }
}
