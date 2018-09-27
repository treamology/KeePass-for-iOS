//
//  KDBXDatabase.swift
//  KeePassSupport
//
//  Created by Donny Lawrence on 6/20/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import Foundation
import AEXML
import Salsa20

public class KDBXDatabase: KDBXXMLElement, KDBDatabase {
  
  public static var dateFormatter = DateFormatter()
  public static var elementName = "Root"
  
  public var xmlElement: AEXMLElement
  public var xmlDocument: AEXMLDocument
  
  private var dateFormatter: DateFormatter
  
  public var groupList: KDBXList<KDBXGroup>
  public var groups: [KDBGroup] {
    get {
      return groupList.elements
    }
  }
  
  public weak var kdbxFile: KDBXFile?
  
  public static func newEmptyDatabase() -> KDBXDatabase {
    let database = KDBXDatabase()
    database.generator = "KeePass for iOS"
    database.dbName = "Database"
    database.description = ""
    
    database.dateOfNameChange = Date()
    database.dateOfUsernameChange = Date()
    database.dateOfMasterKeyChange = Date()
    database.dateOfRecycleBinChange = Date()
    
    return database
  }
  
  public convenience init(withXML xml: [UInt8], andFile file: KDBXFile?) {
    self.init()
    
    do {
      try xmlDocument.loadXML(Data(xml))
    } catch {
      print(error)
    }
    
    // Reinitialize this with the new root element now that we've loaded
    // some data.
    groupList = KDBXList(withRootElement: xmlDocument.root["Root"])
    
    kdbxFile = file
    decryptProtectedValues()
  }
  
  public required init(withElement element: AEXMLElement = AEXMLDocument()) {
    xmlElement = element
    xmlDocument = element as! AEXMLDocument
  
    dateFormatter = KDBXDatabase.dateFormatter
    dateFormatter.dateFormat = "YYYY-MM-DD'T'HH:mm:ssZ"
    
    groupList = KDBXList(withRootElement: xmlDocument.root["Root"])
  }
  
  public func decryptProtectedValues() {
    guard let file = kdbxFile else {
      return
    }
    
    let fileVersion = file.header.majorVersion
    
    var innerRandomStreamID: KDBX3Header.InnerRandomStreamID?
    var protectedStreamKey: [UInt8]?
    if fileVersion == 3 {
      let header3 = file.header as! KDBX3Header
      innerRandomStreamID = header3.innerRandomStreamID
      protectedStreamKey = header3.protectedStreamKey
    }
    
    guard let psk = protectedStreamKey, let sid = innerRandomStreamID else {
      return
    }
    
    switch (sid) {
    case .None:
      // The values are already in plaintext, so there's nothing to do.
      return
    case .Arc4Variant:
      // TODO: Handle Arc4Variant
      return
    case .Salsa20:
      let ivData: [UInt8] = [0xE8,0x30,0x09,0x4B,0x97,0x20,0x5D,0x2A]
      let pskSHA = psk.sha256()
      
      let pskPtr = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: pskSHA.count)
      _ = pskPtr.initialize(from: pskSHA)
      let ivPtr = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: ivData.count)
      _ = ivPtr.initialize(from: ivData)
      
      xmlElement.allDescendants(where: {$0.attributes["Protected"] == "True"}).forEach { (element) in
        if let value = element.value {
          let valueData = Data(base64Encoded: value)
          let valueArray = [UInt8](valueData!)
          
          let valuePtr = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: valueArray.count)
          _ = valuePtr.initialize(from: valueArray)
          
          s20_crypt(pskPtr.baseAddress!, S20_KEYLEN_256, ivPtr.baseAddress!, 0, valuePtr.baseAddress!, UInt32(valueData!.count))

          element.value = String(bytes: valuePtr, encoding: .utf8)
        }
      }
    }
  }
  
  // MARK: - Getters/Setters
  public var generator: String? {
    get {
      return xmlDocument.root["Meta"]["Generator"].value
    }
    set {
      xmlDocument.root["Meta"]["Generator"].value = newValue
    }
  }
  public var dbName: String? {
    get {
      return xmlDocument.root["Meta"]["DatabaseName"].value
    }
    set {
      xmlDocument.root["Meta"]["DatabaseName"].value = newValue
    }
  }
  public var description: String? {
    get {
      return xmlDocument.root["Meta"]["DatabaseDescription"].value
    }
    set {
      xmlDocument.root["Meta"]["DatabseDescription"].value = newValue
    }
  }
  public var recycleBinEnabled: Bool? {
    get {
      if let binEnabled = xmlDocument.root["Meta"]["RecycleBinEnabled"].value {
        return Bool(binEnabled)
      }
      return nil
    }
    set {
      if let newValueUnwrapped = newValue {
        xmlDocument.root["Meta"]["RecycleBinEnabled"].value = String(newValueUnwrapped)
      }
    }
  }
  public var dateOfNameChange: Date? {
    get {
      if let nameChangeString = xmlDocument.root["Meta"]["DatabaseNameChanged"].value {
        return dateFormatter.date(from: nameChangeString)
      }
      return nil
    }
    set {
      if let newValueUnwrapped = newValue {
        xmlDocument.root["Meta"]["DatabaseNameChanged"].value = dateFormatter.string(from: newValueUnwrapped)
      }
    }
  }
  public var dateOfUsernameChange: Date? {
    get {
      if let usernameChangeString = xmlDocument.root["Meta"]["DefaultUserNameChanged"].value {
        return dateFormatter.date(from: usernameChangeString)
      }
      return nil
    }
    set {
      if let newValueUnwrapped = newValue {
        xmlDocument.root["Meta"]["DefaultUserNameChanged"].value = dateFormatter.string(from: newValueUnwrapped)
      }
    }
  }
  public var dateOfMasterKeyChange: Date? {
    get {
      if let masterkeyChangeString = xmlDocument.root["Meta"]["MasterKeyChanged"].value {
        return dateFormatter.date(from: masterkeyChangeString)
      }
      return nil
    }
    set {
      if let newValueUnwrapped = newValue {
        xmlDocument.root["Meta"]["MasterKeyChanged"].value = dateFormatter.string(from: newValueUnwrapped)
      }
    }
  }
  public var dateOfRecycleBinChange: Date? {
    get {
      if let recycleBinChangeString = xmlDocument.root["Meta"]["RecycleBinChanged"].value {
        return dateFormatter.date(from: recycleBinChangeString)
      }
      return nil
    }
    set {
      if let newValueUnwrapped = newValue {
        xmlDocument.root["Meta"]["RecycleBinChanged"].value = dateFormatter.string(from: newValueUnwrapped)
      }
    }
  }
  
}
