//
//  KDBXDatabase.swift
//  KeePassSupport
//
//  Created by Donny Lawrence on 7/8/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import Foundation

public protocol KDBDatabase {
  var generator: String? { get }
  var dbName: String? { get set }
  var description: String? { get set }
  
  var recycleBinEnabled: Bool? { get set }
  
  var dateOfNameChange: Date? { get set }
  var dateOfUsernameChange: Date? { get set }
  var dateOfMasterKeyChange: Date? { get set }
  var dateOfRecycleBinChange: Date? { get set }
  
  var groups: [KDBGroup] { get }
}
