//
//  KDBXXMLString.swift
//  KeePassSupport
//
//  Created by Donny Lawrence on 7/9/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import Foundation
import AEXML

public class KDBXString: KDBXXMLElement {
  public static var elementName = "String"
  public var xmlElement: AEXMLElement
  
  public required init(withElement element: AEXMLElement) {
    xmlElement = element
  }
}
