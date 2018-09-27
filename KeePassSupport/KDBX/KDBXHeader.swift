//
//  KDBXParse.swift
//  KeePass
//
//  Created by Donny Lawrence on 6/6/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import Foundation

// Don't use this class directly
public class KDBXHeader {
  public var secondaryID: UInt32!
  public var majorVersion: UInt16!
  public var minorVersion: UInt16!
}

public class KDBX3Header: KDBXHeader {
  enum CompressionFlags: UInt32 {
    case None, GZIP
  }
  enum InnerRandomStreamID: UInt32 {
    case None, Arc4Variant, Salsa20
  }
  
  var cipherID: [UInt8]
  var compressionFlags: CompressionFlags?
  var masterSeed: [UInt8]?
  var transformSeed: [UInt8]?
  var transformRounds: UInt64?
  var encryptionIV: [UInt8]?
  var protectedStreamKey: [UInt8]?
  var streamStartBytes: [UInt8]!
  var innerRandomStreamID: InnerRandomStreamID!
  
  override init() {
    // Set some reasonable defaults.
    cipherID = [0x31,0xc1,0xf2,0xe6,0xbf,0x71,0x43,0x50,0xbe,0x58,0x05,0x21,0x6a,0xfc,0x5a,0xff] // AES128 encryption
    compressionFlags = CompressionFlags.GZIP
    innerRandomStreamID = .None
    
    super.init()
    
    secondaryID = ([0x67,0xFB,0x4B,0xB5] as ArraySlice<UInt8>).toUInt32()!
    majorVersion = 3
    minorVersion = 1
  }
  
  public static func generateNewHeader() -> KDBX3Header? {
    let header = KDBX3Header()
    
    // We'll use GZIP compression by default
    header.compressionFlags = .GZIP
    
    // Generate a random master seed.
    var masterSeedBytes = [UInt8](repeating: 0, count: 32)
    let masterGenStatus = SecRandomCopyBytes(kSecRandomDefault, masterSeedBytes.count, &masterSeedBytes)
    guard masterGenStatus == errSecSuccess else {
      return nil
    }
    header.masterSeed = masterSeedBytes
    
    // Generate the transform seed.
    var transformSeedBytes = [UInt8](repeating: 0, count: 32)
    let transformGenStatus = SecRandomCopyBytes(kSecRandomDefault, transformSeedBytes.count, &transformSeedBytes)
    guard transformGenStatus == errSecSuccess else {
      return nil
    }
    header.transformSeed = transformSeedBytes
    header.transformRounds = 64
    
    // Generate the encryption IV.
    var encryptionIVBytes = [UInt8](repeating: 0, count: 16)
    let encryptionIVStatus = SecRandomCopyBytes(kSecRandomDefault, encryptionIVBytes.count, &encryptionIVBytes)
    guard encryptionIVStatus == errSecSuccess else {
      return nil
    }
    header.encryptionIV = encryptionIVBytes
    
    // Generate some start bytes.
    var streamStartBytes = [UInt8](repeating: 0, count: 32)
    let streamStartStatus = SecRandomCopyBytes(kSecRandomDefault, streamStartBytes.count, &streamStartBytes)
    guard streamStartStatus == errSecSuccess else {
      return nil
    }
    header.streamStartBytes = streamStartBytes
    
    return header
  }
}
public struct KDBX3HeaderEntry {
  var headerID: UInt8
  var headerPayload: [UInt8]
  var headerSize: UInt16 {
    get { return UInt16(headerPayload.count) }
  }
  
  init(id: UInt8, payload: [UInt8]! = [UInt8]()) {
    headerID = id
    headerPayload = payload
  }
  
  func bytes() -> [UInt8] {
    var bytes = [UInt8]()
    bytes.append(headerID)
    bytes.append(contentsOf: headerSize.toBytes())
    bytes.append(contentsOf: headerPayload)
    return bytes
  }
}
