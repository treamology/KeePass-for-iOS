//
//  Data+Crypto.swift
//  KeePass
//
//  Created by Donny Lawrence on 6/7/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import Foundation
import CommonCrypto

extension ArraySlice where Element == UInt8 {
  func toUInt<T: FixedWidthInteger>(ofType type: T.Type) -> T? {
    guard self.count == type.bitWidth / 8 else {
      return nil
    }
    let rawPointer = self.withUnsafeBufferPointer({
      UnsafeRawPointer($0.baseAddress)
    })
    let pointer = rawPointer?.assumingMemoryBound(to: type)
    return pointer!.pointee
  }
  
  func toUInt64() -> UInt64? {
    return self.toUInt(ofType: UInt64.self)
  }
  
  func toUInt32() -> UInt32? {
    return self.toUInt(ofType: UInt32.self)
  }
  
  func toUInt16() -> UInt16? {
    return self.toUInt(ofType: UInt16.self)
  }
  
  func sha256() -> [UInt8] {
    var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
//    let ptr = UnsafeBufferPointer(start: self.withUnsafe, count: self.count)
    self.withUnsafeBufferPointer({
      _ = CC_SHA256($0.baseAddress, CC_LONG(self.count), &hash)
    })
    return hash
  }
}

extension Array where Element == UInt8 {
  func sha256() -> [UInt8] {
    return self.suffix(from: 0).sha256()
  }
}
