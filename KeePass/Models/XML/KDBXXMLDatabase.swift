//
//  KDBXDatabase.swift
//  KeePassSupport
//
//  Created by Donny Lawrence on 6/20/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import Foundation
import AEXML

public class KDBXXMLDatabase: KDBXXMLElement, KDBXDatabase {
  
  public static var dateFormatter = DateFormatter()
  public static var elementName = "Root"
  
  public var xmlElement: AEXMLElement
  public var xmlDocument: AEXMLDocument
  
  private var dateFormatter: DateFormatter
  
  public var groupList: KDBXXMLList<KDBXXMLGroup>
  public var groups: [KDBXGroup] {
    get {
      return groupList.elements
    }
  }
  
  public static func newEmptyDatabase() -> KDBXXMLDatabase {
    let database = KDBXXMLDatabase()
    database.generator = "KeePass for iOS"
    database.dbName = "Database"
    database.description = ""
    
    database.dateOfNameChange = Date()
    database.dateOfUsernameChange = Date()
    database.dateOfMasterKeyChange = Date()
    database.dateOfRecycleBinChange = Date()
    
    return database
  }
  
  public convenience init(withXML xml: Data) {
    self.init()
    
    do {
      try xmlDocument.loadXML(xml)
    } catch {
      print(error)
    }
    
    // Reinitialize this with the new root element now that we've loaded
    // some data.
    groupList = KDBXXMLList(withRootElement: xmlDocument.root["Root"])
  }
  
  public required init(withElement element: AEXMLElement = AEXMLDocument()) {
    xmlElement = element
    xmlDocument = element as! AEXMLDocument
  
    dateFormatter = KDBXXMLDatabase.dateFormatter
    dateFormatter.dateFormat = "YYYY-MM-DD'T'HH:mm:ssZ"
    
    groupList = KDBXXMLList(withRootElement: xmlDocument.root["Root"])
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
