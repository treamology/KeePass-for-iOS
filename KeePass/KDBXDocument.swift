//
//  KDBXDocument.swift
//  KeePass
//
//  Created by Donny Lawrence on 6/14/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import Foundation
import UIKit
import KeePassSupport
import AEXML

class KDBXDocument: UIDocument {
  var cryptoHandler: KDBXCryptoHandler?
  var parsedData: AEXMLDocument?
  
  var password: String?
  
  override func contents(forType typeName: String) throws -> Any {
    if parsedData == nil {
      let defaultURL = Bundle.main.url(forResource: "Default", withExtension: "xml")
      let defaultData = try! Data(contentsOf: defaultURL!)
      parsedData = try AEXMLDocument(xml: defaultData)
      return defaultData
    } else {
      let utf8XML = parsedData?.xml.utf8
      return Data(utf8XML!)
    }
  }
  
  override func load(fromContents contents: Any, ofType typeName: String?) throws {
    let rawData = contents as! Data
    do {
      cryptoHandler = try KDBXCryptoHandler(withBytes: [UInt8](rawData), password: password)
    } catch {
      print(error)
    }
    guard cryptoHandler != nil else {
      return
    }
    do {
      parsedData = try AEXMLDocument(xml: (cryptoHandler?.payload)!)
    } catch {
      print(error)
    }
  }
}
