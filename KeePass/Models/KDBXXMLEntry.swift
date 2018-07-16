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
  
  public var name: String {
    get {
      return strings["Title"] ?? "(no name)"
    }
    set {
      strings["Title"] = newValue
    }
  }
  var uuid: String {
    get {
      return xmlElement["UUID"].value ?? UUID().uuidString
    }
    set {
      xmlElement["UUID"].value = newValue
    }
  }
  var website: String? {
    get {
      return strings["Website"]
    }
    set {
      strings["Website"] = newValue
    }
  }
  var modificationTime: Date? {
    get {
      if let modTimeString = xmlElement["Times"]["LastModificationTime"].value {
        return KDBXXMLDatabase.dateFormatter.date(from: modTimeString)
      }
      return nil
    }
    set {
      if let date = newValue {
        xmlElement["Times"]["LastModificationTime"].value = KDBXXMLDatabase.dateFormatter.string(from: date)
        return
      }
      xmlElement["Times"]["LastModificationTime"].value = nil
    }
  }
  var creationTime: Date? {
    get {
      if let createTimeString = xmlElement["Times"]["CreationTime"].value {
        return KDBXXMLDatabase.dateFormatter.date(from: createTimeString)
      }
      return nil
    }
    set {
      if let date = newValue {
        xmlElement["Times"]["CreationTime"].value = KDBXXMLDatabase.dateFormatter.string(from: date)
        return
      }
      xmlElement["Times"]["CreationTime"].value = nil
    }
  }
  var lastAccessTime: Date? {
    get {
      if let lastAccessString = xmlElement["Times"]["LastAccessTime"].value {
        return KDBXXMLDatabase.dateFormatter.date(from: lastAccessString)
      }
      return nil
    }
    set {
      if let date = newValue {
        xmlElement["Times"]["LastAccessTime"].value = KDBXXMLDatabase.dateFormatter.string(from: date)
        return
      }
      xmlElement["Times"]["LastAccessTime"].value = nil
    }
  }
  var locationChangedTime: Date? {
    get {
      if let locationChangeString = xmlElement["Times"]["LocationChanged"].value {
        return KDBXXMLDatabase.dateFormatter.date(from: locationChangeString)
      }
      return nil
    }
    set {
      if let date = newValue {
        xmlElement["Times"]["LocationChanged"].value = KDBXXMLDatabase.dateFormatter.string(from: date)
        return
      }
      xmlElement["Times"]["LocationChanged"].value = nil
    }
  }
  var expiryTime: Date? {
    get {
      if let expiryTimeString = xmlElement["Times"]["ExpiryTime"].value {
        return KDBXXMLDatabase.dateFormatter.date(from: expiryTimeString)
      }
      return nil
    }
    set {
      if let date = newValue {
        xmlElement["Times"]["ExpiryTime"].value = KDBXXMLDatabase.dateFormatter.string(from: date)
        return
      }
      xmlElement["Times"]["ExpiryTime"].value = nil
    }
  }
  var expires: Bool? {
    get {
      if let expiresString = xmlElement["Times"]["Expires"].value {
        return Bool(expiresString)
      }
      return nil
    }
    set {
      if let unwrappedNewValue = newValue {
        xmlElement["Times"]["Expires"].value = String(unwrappedNewValue)
      }
    }
  }
  var username: String {
    get {
      return strings["UserName"] ?? ""
    }
    set {
      strings["UserName"] = newValue
    }
  }
  var password: String {
    get {
      return strings["Password"] ?? ""
    }
    set {
      strings["Password"] = newValue
    }
  }
  var notes: String? {
    get {
      return strings["Notes"]
    }
    set {
      strings["Notes"] = newValue
    }
  }
  
  private var strings: KDBXXMLDict<KDBXXMLString>
  
  required init(withElement element: AEXMLElement = AEXMLElement(name: KDBXXMLEntry.elementName)) {
    xmlElement = element
    strings = KDBXXMLDict(withRootElement: xmlElement)
  }
}
