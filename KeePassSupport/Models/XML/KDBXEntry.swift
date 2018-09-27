//
//  KDBXXMLEntry.swift
//  KeePassSupport
//
//  Created by Donny Lawrence on 7/8/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import Foundation
import AEXML

class KDBXEntry: KDBXXMLElement, KDBEntry {
  
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
        return KDBXDatabase.dateFormatter.date(from: modTimeString)
      }
      return nil
    }
    set {
      if let date = newValue {
        xmlElement["Times"]["LastModificationTime"].value = KDBXDatabase.dateFormatter.string(from: date)
        return
      }
      xmlElement["Times"]["LastModificationTime"].value = nil
    }
  }
  var creationTime: Date? {
    get {
      if let createTimeString = xmlElement["Times"]["CreationTime"].value {
        return KDBXDatabase.dateFormatter.date(from: createTimeString)
      }
      return nil
    }
    set {
      if let date = newValue {
        xmlElement["Times"]["CreationTime"].value = KDBXDatabase.dateFormatter.string(from: date)
        return
      }
      xmlElement["Times"]["CreationTime"].value = nil
    }
  }
  var lastAccessTime: Date? {
    get {
      if let lastAccessString = xmlElement["Times"]["LastAccessTime"].value {
        return KDBXDatabase.dateFormatter.date(from: lastAccessString)
      }
      return nil
    }
    set {
      if let date = newValue {
        xmlElement["Times"]["LastAccessTime"].value = KDBXDatabase.dateFormatter.string(from: date)
        return
      }
      xmlElement["Times"]["LastAccessTime"].value = nil
    }
  }
  var locationChangedTime: Date? {
    get {
      if let locationChangeString = xmlElement["Times"]["LocationChanged"].value {
        return KDBXDatabase.dateFormatter.date(from: locationChangeString)
      }
      return nil
    }
    set {
      if let date = newValue {
        xmlElement["Times"]["LocationChanged"].value = KDBXDatabase.dateFormatter.string(from: date)
        return
      }
      xmlElement["Times"]["LocationChanged"].value = nil
    }
  }
  var expiryTime: Date? {
    get {
      if let expiryTimeString = xmlElement["Times"]["ExpiryTime"].value {
        return KDBXDatabase.dateFormatter.date(from: expiryTimeString)
      }
      return nil
    }
    set {
      if let date = newValue {
        xmlElement["Times"]["ExpiryTime"].value = KDBXDatabase.dateFormatter.string(from: date)
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
  
  private var strings: KDBXDict<KDBXString>
  
  required init(withElement element: AEXMLElement = AEXMLElement(name: KDBXEntry.elementName)) {
    xmlElement = element
    strings = KDBXDict(withRootElement: xmlElement)
  }
}
