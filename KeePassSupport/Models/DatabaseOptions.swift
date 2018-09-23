//
//  DatabaseOptions.swift
//  KeePassSupport
//
//  Created by Donny Lawrence on 9/22/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import Foundation

public struct DatabaseOptions {
  public let name: String
  public let password: String
  public let keyfile: [UInt8]
  
  public init(name: String, password: String, keyfile: [UInt8]) {
    self.name = name
    self.password = password
    self.keyfile = keyfile
  }
}
