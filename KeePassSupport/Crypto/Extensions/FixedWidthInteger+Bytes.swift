//
//  FixedWidthInteger+Bytes.swift
//  KeePassSupport
//
//  Created by Donny Lawrence on 6/15/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import Foundation

extension FixedWidthInteger {
  func toBytes() -> [UInt8] {
    return withUnsafePointer(to: self) {
      $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<Self>.size) {
        Array(UnsafeBufferPointer(start: $0, count: MemoryLayout<Self>.size))
      }
    }
  }
}
