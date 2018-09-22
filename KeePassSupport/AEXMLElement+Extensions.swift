//
//  AEXMLElement+Extensions.swift
//  KeePassSupport
//
//  Created by Donny Lawrence on 7/8/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import Foundation
import AEXML

extension AEXMLElement {
  public static func ==(left: AEXMLElement, right: AEXMLElement) -> Bool {
    return left["UUID"].value == right["UUID"].value
  }
}
