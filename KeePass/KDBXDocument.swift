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
  var parsedData: KDBXXMLDatabase?
  
  var password: String?
  
  override func save(to url: URL, for saveOperation: UIDocument.SaveOperation, completionHandler: ((Bool) -> Void)? = nil) {
    if saveOperation == .forCreating {
      // We're creating the file for the first time, so fill it with the default data.
      // These unwraps are forced because Default.xml is guaranteed to be in the app bundle
      // and valid.
      let defaultURL = Bundle.main.url(forResource: "Default", withExtension: "xml")
      let defaultData = try! Data(contentsOf: defaultURL!)
      parsedData = KDBXXMLDatabase(withXML: defaultData)
    }
    
    super.save(to: url, for: saveOperation, completionHandler: completionHandler)
  }
  
  override func contents(forType typeName: String) throws -> Any {
    let utf8XML = parsedData?.xmlElement.xml.utf8
    return Data(utf8XML!)
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
    parsedData = KDBXXMLDatabase(withXML: (cryptoHandler?.payload)!)
  }
}
