//
//  KDBXEntry.swift
//  KeePassSupport
//
//  Created by Donny Lawrence on 6/20/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import Foundation
import AEXML

public class KDBXEntryOld {
  private var dateFormatter: DateFormatter
  
  public var uuid: String
  public var name: String!
  public var website: String!
  
  public var modificationTime: Date = Date()
  public var creationTime: Date = Date()
  public var lastAccessTime: Date = Date()
  public var locationChangedTime: Date = Date()
  
  public var expiryTime: Date = Date()
  public var expires: Bool = false
  
  public var username: String!
  public var password: String!
  public var notes: String!
  
  public init(withXML xml: AEXMLElement) {
    func parseString(stringXML: AEXMLElement) {
      let key = stringXML["Key"].value
      let value = stringXML["Value"].value
      switch key {
      case "Title":
        name = value ?? ""
      case "URL":
        website = value ?? ""
      case "UserName":
        username = value ?? ""
      case "Password":
        password = value ?? ""
      case "Notes":
        notes = value ?? ""
      default:
        return
      }
    }
    
    dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "YYYY-MM-DD'T'HH:mm:ssZ"
    
    uuid = xml["UUID"].value ?? UUID().uuidString
    
    for childXML in xml.children {
      if childXML.name == "String" {
        parseString(stringXML: childXML)
      } else if childXML.name == "Times" {
        if let modificationTimeString = childXML["LastModificationTime"].value {
          modificationTime = dateFormatter.date(from: modificationTimeString) ?? modificationTime
        }
        if let creationTimeString = childXML["CreationTime"].value {
          creationTime = dateFormatter.date(from: creationTimeString) ?? creationTime
        }
        if let lastAccessTimeString = childXML["LastAccessTime"].value {
          lastAccessTime = dateFormatter.date(from: lastAccessTimeString) ?? lastAccessTime
        }
        if let locationChangedTimeString = childXML["LocationChanged"].value {
          locationChangedTime = dateFormatter.date(from: locationChangedTimeString) ?? locationChangedTime
        }
        if let expiryTimeString = childXML["ExpiryTime"].value {
          expiryTime = dateFormatter.date(from: expiryTimeString) ?? expiryTime
        }
        if let expiresString = childXML["Expires"].value {
          expires = Bool(expiresString) ?? expires
        }
      }
    }
  }
}
