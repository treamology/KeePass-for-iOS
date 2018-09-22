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
  
  var file: KDBXFile?
  var parsedData: KDBXXMLDatabase?
  
  var password: String?
  
  override func save(to url: URL, for saveOperation: UIDocument.SaveOperation, completionHandler: ((Bool) -> Void)? = nil) {
    if saveOperation == .forCreating {
      // We're creating the file for the first time, so fill it with the default data.
      // These unwraps are forced because Default.xml is guaranteed to be in the app bundle
      // and valid.
      let defaultURL = Bundle.main.url(forResource: "Default", withExtension: "xml")
      let defaultData = try! Data(contentsOf: defaultURL!)
      parsedData = KDBXXMLDatabase(withXML: [UInt8](defaultData), andFile: file)
    }
    
    super.save(to: url, for: saveOperation, completionHandler: completionHandler)
  }
  
  override func contents(forType typeName: String) throws -> Any {
    let fileData = try file!.encryptPayload()
    return Data(fileData)
  }
  
  override func load(fromContents contents: Any, ofType typeName: String?) throws {
    let rawData = contents as! Data
    let utf8password = password!.utf8
    file = try KDBXFileMagician.kdbxFile(withBytes: [UInt8](rawData), password: [UInt8](utf8password), keyfile: nil)
    
    guard file != nil else {
      return
    }
    parsedData = KDBXXMLDatabase(withXML: (file?.payloadBytes)!, andFile: file)
  }
}
