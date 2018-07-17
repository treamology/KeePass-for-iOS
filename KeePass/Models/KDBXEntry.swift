//
//  KDBXEntry.swift
//  KeePass
//
//  Created by Donny Lawrence on 7/8/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import Foundation

public protocol KDBXEntry {
  var uuid: String { get set }
  var name: String { get set }
  var website: String? { get set }
  
  var modificationTime: Date? { get set }
  var creationTime: Date? { get set }
  var lastAccessTime: Date? { get set }
  var locationChangedTime: Date? { get set}
  
  var expiryTime: Date? { get set }
  var expires: Bool? { get set }
  
  var username: String { get set }
  var password: String { get set }
  var notes: String? { get set }
}
