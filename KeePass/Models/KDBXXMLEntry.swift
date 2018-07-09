//
//  KDBXXMLEntry.swift
//  KeePassSupport
//
//  Created by Donny Lawrence on 7/8/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import Foundation
import AEXML

class KDBXXMLEntry: KDBXXMLElement, KDBXEntry {
  
  static var elementName = "Entry"
  
  var xmlElement: AEXMLElement
  
  var name: String = "Entry"
  var uuid: String = ""
  var website: String?
  var modificationTime: Date?
  var creationTime: Date?
  var lastAccessTime: Date?
  var locationChangedTime: Date?
  var expiryTime: Date?
  var expires: Bool?
  var username: String = ""
  var password: String = ""
  var notes: String?
  
  required init(withElement element: AEXMLElement = AEXMLElement(name: KDBXXMLEntry.elementName)) {
    xmlElement = element
  }
  
}
