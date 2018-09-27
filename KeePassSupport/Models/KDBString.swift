//
//  KDBXString.swift
//  KeePassSupport
//
//  Created by Donny Lawrence on 7/9/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import Foundation

public protocol KDBString {
  var key: String { get }
  var value: String { get set }
}
