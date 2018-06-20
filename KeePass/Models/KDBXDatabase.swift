//
//  KDBXDatabase.swift
//  KeePassSupport
//
//  Created by Donny Lawrence on 6/20/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import Foundation
import AEXML

public class KDBXDatabase {
  
  private var dateFormatter: DateFormatter
  
  var generator: String
  var name: String
  var description: String
  
  var recycleBinEnabled: Bool = false
  
  var dateOfNameChange: Date = Date()
  var dateOfUsernameChange: Date = Date()
  var dateOfMasterKeyChange: Date = Date()
  var dateOfRecycleBinChange: Date = Date()
  
  var groups = [KDBXGroup]()
  
  public init(withXML xml: AEXMLDocument) {
    dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "YYYY-MM-DD'T'HH:mm:ssZ"
    
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
      groups.append(KDBXGroup(withXML: groupXML))
    }
  }
}
