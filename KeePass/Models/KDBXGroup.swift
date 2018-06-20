//
//  KDBXGroup.swift
//  KeePassSupport
//
//  Created by Donny Lawrence on 6/20/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import Foundation
import AEXML

public class KDBXGroupDetails {
  init(withXML xml: AEXMLElement) {
    
  }
}

public class KDBXGroup {
  var uuid: String
  var name: String
  var website: String
  var iconID: UInt8 = 0
  
  var details: KDBXGroupDetails?
  
  init(withXML xml: AEXMLElement) {
    // Loads only basic information
    uuid = xml["UUID"].value ?? UUID().uuidString
    name = xml["Name"].value ?? ""
    website = xml["Website"].value ?? ""
    if let iconIDString = xml["IconID"].value {
      iconID = UInt8(iconIDString) ?? iconID
    }
  }
  
  func initDetails() {
    
  }
}
