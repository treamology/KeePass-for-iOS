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
    var converted: [UInt8]!
    withUnsafePointer(to: self) {
      let bufferPtr = UnsafeRawBufferPointer(start: $0, count: 4)
      converted = bufferPtr.bindMemory(to: [UInt8].self).baseAddress?.pointee
    }
    return converted
  }
}
