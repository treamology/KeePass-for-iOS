//
//  KDBXDatabase.swift
//  KeePassSupport
//
//  Created by Donny Lawrence on 6/20/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import Foundation
import AEXML

public class KDBXDatabase: EditableEntry {
  
  private var dateFormatter: DateFormatter
  
  public var generator: String = "KeePass for iOS"
  public var name: String = "Database"
  public var description: String = ""
  
  public var recycleBinEnabled: Bool = false
  
  public var dateOfNameChange: Date = Date()
  public var dateOfUsernameChange: Date = Date()
  public var dateOfMasterKeyChange: Date = Date()
  public var dateOfRecycleBinChange: Date = Date()
  
  public var groups = [KDBXGroup]()
  
  public init() {
    dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "YYYY-MM-DD'T'HH:mm:ssZ"
  }
  
  public convenience init(withXML xml: AEXMLDocument) {
    self.init()
    
    let meta = xml.root["Meta"]
    
    generator = meta["Generator"].value ?? "KeePass for iOS"
    name = meta["DatabaseName"].value ?? ""
    description = meta["DatabaseDescription"].value ?? ""
    
    if let binEnabledBool = meta["RecycleBinEnabled"].value {
      recycleBinEnabled = Bool(binEnabledBool) ?? recycleBinEnabled
    }
    
    if let nameChangeString = meta["DatabaseNameChanged"].value {
      dateOfNameChange = dateFormatter.date(from: nameChangeString) ?? dateOfNameChange
    }
    if let usernameChangeString = meta["DefaultUserNameChanged"].value {
      dateOfUsernameChange = dateFormatter.date(from: usernameChangeString) ?? dateOfUsernameChange
    }
    if let masterKeyChangeString = meta["MasterKeyChanged"].value {
      dateOfMasterKeyChange = dateFormatter.date(from: masterKeyChangeString) ?? dateOfMasterKeyChange
    }
    if let recycleBinChangeString = meta["RecycleBinChanged"].value {
      dateOfRecycleBinChange = dateFormatter.date(from: recycleBinChangeString) ?? dateOfRecycleBinChange
    }
    
    for groupXML in xml.root["Root"].children {
      guard groupXML.name == "Group" else {
        continue
      }
      groups.append(KDBXGroup(withXML: groupXML))
    }
  }
  
  // MARK: - Editable Entry Options
  public var entryNames = [
    "Name",
    "Description"
  ]
  
  public var currentEntryValues: [String?] {
    get {
      return [
        name, description
      ]
    }
  }
}
