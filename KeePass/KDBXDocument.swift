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
  
  var password: String?
  
  override func contents(forType typeName: String) throws -> Any {
    let fileData = try file!.encryptPayload()
    return Data(fileData)
  }
  
  override func load(fromContents contents: Any, ofType typeName: String?) throws {
    let rawData = contents as! Data
    let utf8password = password!.utf8
    file = try KDBXFileMagician.kdbxFile(withBytes: [UInt8](rawData), password: [UInt8](utf8password), keyfile: nil)
  }
}
