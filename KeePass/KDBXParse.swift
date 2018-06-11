//
//  KDBXParse.swift
//  KeePass
//
//  Created by Donny Lawrence on 6/6/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import Foundation
import Gzip

public class KDBXFile {
  static let KDBX3_MAGIC: [UInt8] = [0x03,0xD9,0xA2,0x9A]
  static let KDBX3_HEADER_SIZE = 12
  
  public enum DynHeaderID: UInt8 {
    case end, comment, cipherID, compressionFlags, masterSeed, transformSeed,
    transformRounds, encryptionIV, protectedStreamKey, streamStartBytes,
    innerRandomStreamID
  }
  enum CompressionFlags: UInt32 {
    case None, GZIP
  }
  public enum ParseError: Error {
    case badHeaderID
    case badCompressionFlags
    case couldntCreateCryptoContext
    case badStreamStartBytes(actualStartBytes: [UInt8])
    case payloadHashMismatch
    case couldntDecompressPayload
    case badPayloadString
    case badKDBXFile
  }
  
  let secondaryID: UInt32
  let version: (major: UInt16, minor: UInt16)
  var payload: String!
  let rawBytes: [UInt8]
  
  public convenience init?(withBytes bytes: [UInt8]) throws {
    guard bytes.count >= 12 else {
      throw ParseError.badKDBXFile
    }
    
    // Get the basic information we know is in the header.
    let magic = [UInt8](bytes[0...3])
    if magic == KDBXFile.KDBX3_MAGIC {
      try self.init(withKDBX3Bytes: bytes)
    }
    return nil
  }
  
  private init?(withKDBX3Bytes bytes: [UInt8]) throws {
    self.rawBytes = bytes
    
    var cipherID: [UInt8]
    var compressionFlags: CompressionFlags!
    var masterSeed: [UInt8]!
    var transformSeed: [UInt8]!
    var transformRounds: UInt64!
    var encryptionIV: [UInt8]!
    var protectedStreamKey: [UInt8]
    var streamStartBytes: [UInt8]!
    var innerRandomStreamID: UInt32
    
    self.secondaryID = bytes[4...7].toUInt32()!
    
    let minorVersion = bytes[8...9].toUInt16()!
    let majorVersion = bytes[10...11].toUInt16()!
    self.version = (majorVersion, minorVersion)
    
    // Parse the dynamic header. The headers can appear in different orders
    // and some can be missing.
    print("Parsing dynamic header...")
    var reachedHeaderEnd = false
    var cb = KDBXFile.KDBX3_HEADER_SIZE // current byte
    while (!reachedHeaderEnd) {
      let headerID = DynHeaderID(rawValue: bytes[cb]); cb += 1
      guard let unwrappedID = headerID else {
        throw ParseError.badHeaderID
      }
      
      let headerSize = bytes[cb...cb + 1]; cb += 2
      let hsInt = Int(headerSize.toUInt16()!)
      guard bytes.count > cb + hsInt else {
        throw ParseError.badKDBXFile
      }
      
      let headerPayload = bytes[cb..<cb + hsInt]; cb += hsInt;
      
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
          throw ParseError.badCompressionFlags
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
      throw ParseError.couldntCreateCryptoContext
    }

    var transformedKey = compositeKey
    for _ in 1...transformRounds {
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
      throw ParseError.couldntCreateCryptoContext
    }

    let encryptedPayload = [UInt8](bytes[cb...])
    let decryptedPayload = AESDecryptContext.performOperation(encryptedPayload)

    let actualStartBytes = [UInt8](decryptedPayload[..<32])
    if streamStartBytes != actualStartBytes {
      throw ParseError.badStreamStartBytes(actualStartBytes: actualStartBytes)
    }
    
    cb = 32
    var payload = [UInt8]()
    while true {
      cb += 4 // block ID
      let blockHash = decryptedPayload[cb..<cb + 32]; cb += 32
      let blockSize = Int(decryptedPayload[cb..<cb + 4].toUInt32()!); cb += 4
      let blockData = decryptedPayload[cb..<cb + blockSize]; cb += blockSize

      if blockSize == 0 && [UInt8](blockHash) == [UInt8](repeating: 0x00, count: 32) {
        // This condition signals the end of the data.
        break
      }
      
      let trueHash = blockData.sha256()
      if ([UInt8](blockHash) != trueHash) {
        throw ParseError.payloadHashMismatch
      }

      payload.append(contentsOf: blockData)
    }
    
    // Now that we have the payload, gunzip it if we need to
    var decompressedPayload = payload
    if compressionFlags == .GZIP {
      do {
        decompressedPayload = try [UInt8](Data(payload).gunzipped())
      } catch {
        throw ParseError.couldntDecompressPayload
      }
      
    }

    self.payload = String(bytes: decompressedPayload, encoding: .utf8)
    if self.payload == nil {
      throw ParseError.badPayloadString
    }
  }
}
