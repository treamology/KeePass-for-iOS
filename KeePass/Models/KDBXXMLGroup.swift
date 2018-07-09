//
//  KDBXXMLGroup.swift
//  KeePassSupport
//
//  Created by Donny Lawrence on 7/8/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import Foundation
import AEXML

public class KDBXXMLGroup: KDBXXMLElement, KDBXGroup {
  
  public var xmlElement: AEXMLElement
  
  public static var elementName = "Group"
  public static let defaultGroupName = "Group"
  
  public var uuid: String {
    get {
      if let unwrappedUUID = xmlElement["UUID"].value {
        return unwrappedUUID
      } else {
        let newUUID = UUID().uuidString
        xmlElement["UUID"].value = newUUID
        return newUUID
      }
    }
    set {
      xmlElement["UUID"].value = newValue
    }
  }
  public var groupName: String {
    get {
      if let unwrappedGroupName = xmlElement["Name"].value {
        return unwrappedGroupName
      } else {
        xmlElement["Name"].value = KDBXXMLGroup.defaultGroupName
        return KDBXXMLGroup.defaultGroupName
      }
    }
    set {
      xmlElement["Name"].value = newValue
    }
  }
  public var iconID: UInt8? {
    get {
      if let iconIDString = xmlElement["IconID"].value {
        return UInt8(iconIDString)
      }
      return nil
    } set {
      if let newIconID = newValue {
        xmlElement["IconID"].value = String(newIconID)
      }
    }
  }
  
  private var entriesList: KDBXXMLList<KDBXXMLEntry>
  public var entries: [KDBXEntry] {
    get {
      return entriesList.elements
    }
  }
  
  private var childGroupsList: KDBXXMLList<KDBXXMLGroup>
  public var childGroups: [KDBXGroup] {
    get {
      return childGroupsList.elements
    }
  }
  
  required public init(withElement element: AEXMLElement = AEXMLElement(name: KDBXXMLGroup.elementName)) {
    entriesList = KDBXXMLList(withRootElement: element)
    childGroupsList = KDBXXMLList(withRootElement: element)
    
    xmlElement = element
  }
}
