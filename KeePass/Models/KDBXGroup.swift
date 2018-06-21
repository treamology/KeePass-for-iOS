//
//  KDBXGroup.swift
//  KeePassSupport
//
//  Created by Donny Lawrence on 6/20/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import Foundation
import AEXML

public class KDBXGroup {
  public var uuid: String
  public var name: String
  public var iconID: UInt8 = 0
  
  public var entries = [KDBXEntry]()
  public var childGroups = [KDBXGroup]()
  
  public init(withXML xml: AEXMLElement) {
    // Loads only basic information
    uuid = xml["UUID"].value ?? UUID().uuidString
    name = xml["Name"].value ?? ""
    if let iconIDString = xml["IconID"].value {
      iconID = UInt8(iconIDString) ?? iconID
    }
    
    for entryXML in xml.children {
      if entryXML.name == "Entry" {
        entries.append(KDBXEntry(withXML: entryXML))
      } else if entryXML.name == "Group" {
        childGroups.append(KDBXGroup(withXML: entryXML))
      }
    }
  }
}
