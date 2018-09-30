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
  public var bytes: [UInt8] {
    get {
      return []
    }
  }
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
  var headerEndBytes: [UInt8]?
  
  public override var bytes: [UInt8] {
    get {
      var headerBytes = [UInt8]()
      headerBytes.append(contentsOf: KDBX3File.MAGIC)
      headerBytes.append(contentsOf: self.secondaryID.toBytes())
      headerBytes.append(contentsOf: self.minorVersion.toBytes())
      headerBytes.append(contentsOf: self.majorVersion.toBytes())
      
      let cipherID = KDBX3HeaderEntry(id: 2, payload: self.cipherID)
      headerBytes.append(contentsOf: cipherID.bytes())
      
      let compressionFlags = KDBX3HeaderEntry(id: 3, payload: self.compressionFlags!.rawValue.toBytes())
      headerBytes.append(contentsOf: compressionFlags.bytes())
      
      let masterSeed = KDBX3HeaderEntry(id: 4, payload: self.masterSeed)
      headerBytes.append(contentsOf: masterSeed.bytes())
      
      let encryptionIV = KDBX3HeaderEntry(id: 7, payload: self.encryptionIV)
      headerBytes.append(contentsOf: encryptionIV.bytes())
      
      let transformSeed = KDBX3HeaderEntry(id: 5, payload: self.transformSeed)
      headerBytes.append(contentsOf: transformSeed.bytes())
      
      let transformRounds = KDBX3HeaderEntry(id: 6, payload: self.transformRounds!.toBytes())
      headerBytes.append(contentsOf: transformRounds.bytes())
      
      if self.protectedStreamKey != nil {
        let protectedStreamKey = KDBX3HeaderEntry(id: 8, payload: self.protectedStreamKey)
        headerBytes.append(contentsOf: protectedStreamKey.bytes())
      }
      
      let streamStartBytes = KDBX3HeaderEntry(id: 9, payload: self.streamStartBytes)
      headerBytes.append(contentsOf: streamStartBytes.bytes())
      
      if self.innerRandomStreamID != nil {
        let innerRandomStreamID = KDBX3HeaderEntry(id: 10, payload: self.innerRandomStreamID!.rawValue.toBytes())
        headerBytes.append(contentsOf: innerRandomStreamID.bytes())
      }
      
      let headerEndBytesEntry = KDBX3HeaderEntry(id: 0, payload: self.headerEndBytes)
      headerBytes.append(contentsOf: headerEndBytesEntry.bytes())
      
      return headerBytes
    }
  }
  
  override init() {
    // Set some reasonable defaults.
    cipherID = [0x31,0xc1,0xf2,0xe6,0xbf,0x71,0x43,0x50,0xbe,0x58,0x05,0x21,0x6a,0xfc,0x5a,0xff] // AES128 encryption
    compressionFlags = CompressionFlags.GZIP
    innerRandomStreamID = .None
    
    super.init()
    
    secondaryID = ([0x67,0xFB,0x4B,0xB5] as ArraySlice<UInt8>).toUInt32()!
    majorVersion = 3
    minorVersion = 1
    
    headerEndBytes = [0xDE, 0xAD, 0xBE, 0xEF]
  }
  
  public static func generateValidHeader() throws -> KDBX3Header {
    let header = KDBX3Header()
    
    // We'll use GZIP compression by default
    header.compressionFlags = .GZIP
    
    // Generate a random master seed.
    var masterSeedBytes = [UInt8](repeating: 0, count: 32)
    let masterGenStatus = SecRandomCopyBytes(kSecRandomDefault, masterSeedBytes.count, &masterSeedBytes)
    guard masterGenStatus == errSecSuccess else {
      throw KDBX3File.EncryptError.randomNumNotAvailable
    }
    header.masterSeed = masterSeedBytes
    
    // Generate the transform seed.
    var transformSeedBytes = [UInt8](repeating: 0, count: 32)
    let transformGenStatus = SecRandomCopyBytes(kSecRandomDefault, transformSeedBytes.count, &transformSeedBytes)
    guard transformGenStatus == errSecSuccess else {
      throw KDBX3File.EncryptError.randomNumNotAvailable
    }
    header.transformSeed = transformSeedBytes
    header.transformRounds = 64
    
    // Generate the encryption IV.
    var encryptionIVBytes = [UInt8](repeating: 0, count: 16)
    let encryptionIVStatus = SecRandomCopyBytes(kSecRandomDefault, encryptionIVBytes.count, &encryptionIVBytes)
    guard encryptionIVStatus == errSecSuccess else {
      throw KDBX3File.EncryptError.randomNumNotAvailable
    }
    header.encryptionIV = encryptionIVBytes
    
    // Generate some start bytes.
    var streamStartBytes = [UInt8](repeating: 0, count: 32)
    let streamStartStatus = SecRandomCopyBytes(kSecRandomDefault, streamStartBytes.count, &streamStartBytes)
    guard streamStartStatus == errSecSuccess else {
      throw KDBX3File.EncryptError.randomNumNotAvailable
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
