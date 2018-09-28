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
  
  private static var _dateFormatter: DateFormatter?
  internal static var dateFormatter: DateFormatter {
    if _dateFormatter == nil {
      _dateFormatter = DateFormatter()
      _dateFormatter!.dateFormat = "YYYY-MM-DD'T'HH:mm:ssZ"
    }
    return _dateFormatter!
  }
  
  public static var elementName = "Root"
  
  internal var xmlElement: AEXMLElement
  var xmlDocument: AEXMLDocument
  
  internal var groupList: KDBXList<KDBXGroup>?
  public var groups: [KDBGroup]? {
    return groupList?.elements
  }
  
  public weak var kdbxFile: KDBXFile?
  
  public convenience init(withXML xml: [UInt8], andFile file: KDBXFile?) {
    self.init()
    
    generator = "KeePass for iOS"
    dbName = "Database"
    description = ""
    
    dateOfNameChange = Date()
    dateOfUsernameChange = Date()
    dateOfMasterKeyChange = Date()
    dateOfRecycleBinChange = Date()
    
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
        return KDBXDatabase.dateFormatter.date(from: nameChangeString)
      }
      return nil
    }
    set {
      if let newValueUnwrapped = newValue {
        xmlDocument.root["Meta"]["DatabaseNameChanged"].value = KDBXDatabase.dateFormatter.string(from: newValueUnwrapped)
      }
    }
  }
  public var dateOfUsernameChange: Date? {
    get {
      if let usernameChangeString = xmlDocument.root["Meta"]["DefaultUserNameChanged"].value {
        return KDBXDatabase.dateFormatter.date(from: usernameChangeString)
      }
      return nil
    }
    set {
      if let newValueUnwrapped = newValue {
        xmlDocument.root["Meta"]["DefaultUserNameChanged"].value = KDBXDatabase.dateFormatter.string(from: newValueUnwrapped)
      }
    }
  }
  public var dateOfMasterKeyChange: Date? {
    get {
      if let masterkeyChangeString = xmlDocument.root["Meta"]["MasterKeyChanged"].value {
        return KDBXDatabase.dateFormatter.date(from: masterkeyChangeString)
      }
      return nil
    }
    set {
      if let newValueUnwrapped = newValue {
        xmlDocument.root["Meta"]["MasterKeyChanged"].value = KDBXDatabase.dateFormatter.string(from: newValueUnwrapped)
      }
    }
  }
  public var dateOfRecycleBinChange: Date? {
    get {
      if let recycleBinChangeString = xmlDocument.root["Meta"]["RecycleBinChanged"].value {
        return KDBXDatabase.dateFormatter.date(from: recycleBinChangeString)
      }
      return nil
    }
    set {
      if let newValueUnwrapped = newValue {
        xmlDocument.root["Meta"]["RecycleBinChanged"].value = KDBXDatabase.dateFormatter.string(from: newValueUnwrapped)
      }
    }
  }
  
}
