//
//  KDBXGroup.swift
//  KeePassSupport
//
//  Created by Donny Lawrence on 7/8/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import Foundation

public protocol KDBGroup: AnyObject {
  var uuid: String { get set }
  var groupName: String { get set }
  var iconID: UInt8? { get set }
  
  var entries: [KDBEntry] { get }
  var childGroups: [KDBGroup] { get }
}
