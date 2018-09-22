//
//  KDBXXMLElement.swift
//  KeePassSupport
//
//  Created by Donny Lawrence on 7/9/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import Foundation
import AEXML

public protocol KDBXXMLElement {
  static var elementName: String { get }
  var xmlElement: AEXMLElement { get set }
  
  init(withElement element: AEXMLElement)
}
