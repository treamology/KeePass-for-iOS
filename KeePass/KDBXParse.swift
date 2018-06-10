//
//  KDBXParse.swift
//  KeePass
//
//  Created by Donny Lawrence on 6/6/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import Foundation
import Gzip

public class TestClass {
  public init() {
    
  }
}

public class KDBXFile {
  static let KDBX3_MAGIC = [0x03,0xD9,0xA2,0x9A];
  enum DynHeaderID: UInt8 {
    case end, comment, cipherID, compressionFlags, masterSeed, transformSeed,
    transformRounds, encryptionIV, protectedStreamKey, streamStartBytes,
    innerRandomStreamID
  }
  enum CompressionFlags: UInt32 {
    case None, GZIP
  }
  
  let secondaryID: UInt32
  let version: (major: UInt16, minor: UInt16)
  var payload: String!
  
  public init?(withKDBX3Bytes bytes: [UInt8]) {
    // FIXME: We can probably not use the Data type to avoid conversions
    var cipherID: [UInt8]
    var compressionFlags: CompressionFlags!
    var masterSeed: [UInt8]!
    var transformSeed: [UInt8]!
    var transformRounds: UInt64!
    var encryptionIV: [UInt8]!
    var protectedStreamKey: [UInt8]
    var streamStartBytes: [UInt8]!
    var innerRandomStreamID: UInt32
    
    // Get the basic information we know is in the header.
    let magic = bytes[0...3]
//    self.secondaryID = UInt32(withData: bytes[4...7])
    self.secondaryID = bytes[4...7].toUInt32()!
    
    let minorVersion = bytes[8...9].toUInt16()!
    let majorVersion = bytes[10...11].toUInt16()!
    self.version = (majorVersion, minorVersion)
    
    // Parse the dynamic header. The headers can appear in different orders
    // and some can be missing.
    print("Parsing dynamic header...")
    var reachedHeaderEnd = false
    var cb = 12 // current byte
    while (!reachedHeaderEnd) {
      let headerID = DynHeaderID(rawValue: bytes[cb]); cb += 1
      
      let headerSize = bytes[cb...cb + 1]; cb += 2
      let hsInt = Int(headerSize.toUInt16()!)
      let headerPayload = bytes[cb..<cb + hsInt]; cb += hsInt;
      
      guard let unwrappedID = headerID else {
        print("Unknown header ID")
        continue
      }
      
      switch (unwrappedID) {
      case .end:
        reachedHeaderEnd = true
      case .comment:
        continue
      case .cipherID:
        cipherID = [UInt8](headerPayload)
      case .compressionFlags:
        let flags =
          CompressionFlags(rawValue:headerPayload.toUInt32()!)
        if flags == nil {
          print("Invalid compression flags")
          continue
        }
        compressionFlags = flags!
      case .masterSeed:
        masterSeed = [UInt8](headerPayload)
      case .transformSeed:
        transformSeed = [UInt8](headerPayload)
      case .transformRounds:
        transformRounds = headerPayload.toUInt64()!
      case .encryptionIV:
        encryptionIV = [UInt8](headerPayload)
      case .protectedStreamKey:
        protectedStreamKey = [UInt8](headerPayload)
      case .streamStartBytes:
        streamStartBytes = [UInt8](headerPayload)
      case .innerRandomStreamID:
        innerRandomStreamID = headerPayload.toUInt32()!
      }
    }
    
    // We have the information we need to decrypt the payload. Start by
    // concatenating the key composites (password, keyfiles, etc)
    // We use the sha256 hash of the password to get its bytes.
    let PASSWORD = [UInt8]("password".utf8)
    print("Creating composite key...")
    // TODO: Support composites besides passwords
    let concatBytes = PASSWORD.sha256()
    
    let compositeKey = concatBytes.sha256()
    
    // Create the transformed and master key. We take the transformSeed to make
    // an AES-256 context, then encrypt the composite key the specified amount
    // in transformRounds. Finally, take the sha256 hash.
    print("Creating the master key...")
    var masterKey: [UInt8]
    let iv = [UInt8](Data(repeating: 0x00, count: 16))

    guard let AESEncryptContext = AES(operation: .Encrypt,
                                      padding: false,
                                      key: transformSeed,
                                      iv: iv) else {
      print("Error creating the AES context for encrypting.")
      return
    }

    var transformedKey = compositeKey
    for i in 1...transformRounds {
      transformedKey = AESEncryptContext.performOperation(transformedKey)
    }
    transformedKey = transformedKey.sha256()
    
    masterKey = masterSeed
    masterKey.append(contentsOf: transformedKey)
    masterKey = masterKey.sha256()
    
    // Now that we have the master key, we can split up the payload
    print("Getting the payload...")
    let masterKeyArray = masterKey
    let encryptionIVArray = encryptionIV
    
    guard let AESDecryptContext = AES(operation: .Decrypt,
                                      padding: true,
                                      key: masterKeyArray,
                                      iv: encryptionIVArray) else {
      print("Error creating the AES context for decrypting.")
      return
    }

    let payloadStart = cb
    let encryptedPayload = [UInt8](bytes[cb...])
    let decryptedPayload = AESDecryptContext.performOperation(encryptedPayload)

    cb = 32
    var payload = [UInt8]()
    while true {
      let blockID = decryptedPayload[cb..<cb + 4]; cb += 4
      let blockHash = decryptedPayload[cb..<cb + 32]; cb += 32
      let blockSize = Int(decryptedPayload[cb..<cb + 4].toUInt32()!); cb += 4
      let blockData = decryptedPayload[cb..<cb + blockSize]; cb += blockSize

      if blockSize == 0 && [UInt8](blockHash) == [UInt8](repeating: 0x00, count: 32) {
        // This condition signals the end of the data.
        break
      }
      
      let trueHash = blockData.sha256()
      if ([UInt8](blockHash) != trueHash) {
        print("Error decrypting payload blocks")
        return
      }

      payload.append(contentsOf: blockData)
    }
    
    // Now that we have the payload, gunzip it if we need to
    var decompressedPayload = payload
    if (compressionFlags == .GZIP) {
      decompressedPayload = try! [UInt8](Data(payload).gunzipped())
    }

    self.payload = String(bytes: decompressedPayload, encoding: .utf8)!
  }
}
