//
//  KDBXEntry.swift
//  KeePassSupport
//
//  Created by Donny Lawrence on 6/20/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import Foundation
import AEXML

public class KDBXEntryDetails {
  public init(withXML xml: AEXMLElement) {
    
  }
}

public class KDBXEntry {
  public var uuid: String
  public var name: String!
  public var website: String!
  
  var details: KDBXEntryDetails?
  
  public init(withXML xml: AEXMLElement) {
    uuid = xml["UUID"].value ?? UUID().uuidString
    
    for stringXML in xml.children {
      guard stringXML.name == "String" else {
        continue
      }
      let key = stringXML["Key"].value
      let value = stringXML["Value"].value
      switch key {
      case "Title":
        name = value ?? ""
      case "URL":
        website = value ?? ""
      default:
        continue
      }
    }
  }
}
