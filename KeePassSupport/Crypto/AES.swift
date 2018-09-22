//
//  AES.swift
//  KeePass
//
//  Created by Donny Lawrence on 6/7/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import Foundation
import CommonCrypto

// Convenience class for Apple's CommonCrypto implementation of AES
public class AES {
  public enum AESOperation: UInt32 {
    case Encrypt, Decrypt
  }
  
  var cryptor: CCCryptorRef!
  var operation: AESOperation
  
  public init?(operation: AESOperation, padding: Bool, key: [UInt8], iv: [UInt8]?) {
    self.operation = operation
    
    let option: CCOptions
    let rawIVPtr: UnsafeRawPointer?
    
    if let unwrapped_iv = iv {
      if padding {
        option = UInt32(kCCOptionPKCS7Padding)
      } else {
        option = UInt32(kCCOptionECBMode)
      }
      let ivDataPtr = UnsafeMutableBufferPointer<UInt8>
        .allocate(capacity: iv!.count)
      _ = ivDataPtr.initialize(from: unwrapped_iv)
      rawIVPtr = UnsafeRawPointer(ivDataPtr.baseAddress)
    } else {
      option = UInt32(kCCOptionECBMode)
      rawIVPtr = nil
    }
    
    let keyDataPtr = UnsafeMutableBufferPointer<UInt8>
      .allocate(capacity: key.count)
    _ = keyDataPtr.initialize(from: key)
    
    let status = CCCryptorCreate(operation.rawValue,
                                 UInt32(kCCAlgorithmAES),
                                 option,
                                 keyDataPtr.baseAddress,
                                 key.count,
                                 rawIVPtr,
                                 &self.cryptor)
    if self.cryptor == nil {
      print(status)
      return nil;
    }
  }
  
  public convenience init?(operation: AESOperation, padding: Bool, key: String, iv: String?) {
    var ivBytes: [UInt8]? = nil
    if let ivUTF8 = iv?.utf8 {
      ivBytes = [UInt8](ivUTF8)
    }
    self.init(operation: operation,
              padding: padding,
              key: [UInt8](key.utf8),
              iv: ivBytes)
  }
  
  public convenience init?(operation: AESOperation, padding: Bool, key: String) {
    self.init(operation: operation, padding: padding, key: key, iv: nil)
  }
  
  public convenience init?(operation: AESOperation, padding: Bool, key: [UInt8]) {
    self.init(operation: operation, padding: padding, key: key, iv: nil)
  }
  
  public func performOperation(_ data: [UInt8]) -> [UInt8] {
    let requiredLength = CCCryptorGetOutputLength(self.cryptor,
                                                  data.count,
                                                  true)

    var outputBuffer = [UInt8]()
    var scratchBuffer = [UInt8](repeating: 0x00, count: requiredLength)
    var bytesWritten = 0
    
    let status = CCCryptorUpdate(self.cryptor,
                                 data,
                                 data.count,
                                 &scratchBuffer,
                                 scratchBuffer.count,
                                 &bytesWritten)
    scratchBuffer[bytesWritten...] = []
    outputBuffer.append(contentsOf: scratchBuffer)
    
    scratchBuffer = [UInt8](repeating: 0x00, count: requiredLength)
    switch status {
    case Int32(kCCSuccess):
      bytesWritten = 0
      let status = CCCryptorFinal(self.cryptor,
                                  &scratchBuffer,
                                  scratchBuffer.count,
                                  &bytesWritten)
      
      scratchBuffer[bytesWritten...] = []
      outputBuffer.append(contentsOf: scratchBuffer)
      
      switch status {
      case Int32(kCCSuccess):
        return outputBuffer
      default:
        print(status)
        abort()
      }
      
    default:
      print(status)
      abort()
    }
  }
  
}
