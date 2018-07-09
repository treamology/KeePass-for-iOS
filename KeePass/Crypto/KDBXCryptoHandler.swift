//
//  KDBXParse.swift
//  KeePass
//
//  Created by Donny Lawrence on 6/6/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import Foundation
import Gzip

public class KDBXCryptoHandler {
  static let KDBX3_MAGIC: [UInt8] = [0x03,0xD9,0xA2,0x9A]
  static let KDBX3_HEADER_SIZE = 12
  
  public struct KDBX3Header {
    init() {
      secondaryID = ([0x67,0xFB,0x4B,0xB5] as ArraySlice<UInt8>).toUInt32() // FIXME: Figure out what bytes mean
      majorVersion = 3
      minorVersion = 1
      
      cipherID = [UInt8](repeating: 0x00, count: 32) // FIXME: This probably shouldn't be this
      compressionFlags = CompressionFlags.GZIP
      
      innerRandomStreamID = 0
    }
    var secondaryID: UInt32!
    var majorVersion: UInt16!
    var minorVersion: UInt16!
    
    var cipherID: [UInt8]
    var compressionFlags: CompressionFlags?
    var masterSeed: [UInt8]?
    var transformSeed: [UInt8]?
    var transformRounds: UInt64?
    var encryptionIV: [UInt8]?
    var protectedStreamKey: [UInt8]?
    var streamStartBytes: [UInt8]?
    var innerRandomStreamID: UInt32?
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
      bytes.append(contentsOf: headerPayload)
      bytes.append(contentsOf: headerSize.toBytes())
      return bytes
    }
  }
  
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
  public enum EncryptError: Error {
    case couldntCompress
  }
  
  public var header: KDBX3Header
  public var payload: Data
  public let rawBytes: [UInt8]
  
  let filePassword: [UInt8]
  let keyfileData: [UInt8]?
  
  public convenience init?(withBytes bytes: [UInt8], password: String?) throws {
    guard bytes.count >= 12 else {
      throw ParseError.badKDBXFile
    }
    
    // Get the basic information we know is in the header.
    let magic = [UInt8](bytes[0...3])
    if magic == KDBXCryptoHandler.KDBX3_MAGIC {
      try self.init(withKDBX3Bytes: bytes, password: password, keyfileData: nil)
      return
    }
    throw ParseError.badKDBXFile
  }
  
  private init?(withKDBX3Bytes bytes: [UInt8], password: String?, keyfileData: [UInt8]?) throws {
    self.header = KDBX3Header()
    self.rawBytes = bytes
    if let unwrappedPassword = password {
      self.filePassword = [UInt8](unwrappedPassword.utf8)
    } else {
      self.filePassword = [UInt8]()
    }
    self.keyfileData = keyfileData
    
    header.secondaryID = bytes[4...7].toUInt32()!
    
    header.minorVersion = bytes[8...9].toUInt16()!
    header.majorVersion = bytes[10...11].toUInt16()!
    
    // Parse the dynamic header. The headers can appear in different orders
    // and some can be missing.
    print("Parsing dynamic header...")
    var reachedHeaderEnd = false
    var cb = KDBXCryptoHandler.KDBX3_HEADER_SIZE // current byte
    while (!reachedHeaderEnd) {
      let headerID = DynHeaderID(rawValue: bytes[cb]); cb += 1
      guard let unwrappedID = headerID else {
        throw ParseError.badHeaderID
      }
      
      let headerSize = bytes[cb...cb + 1]; cb += 2
      guard let validHeaderSize = headerSize.toUInt16() else {
        throw ParseError.badKDBXFile
      }
      let hsInt = Int(validHeaderSize)
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
        header.cipherID = [UInt8](headerPayload)
      case .compressionFlags:
        guard let rawFlag = headerPayload.toUInt32() else {
          throw ParseError.badCompressionFlags
        }
        let flags =
          CompressionFlags(rawValue:rawFlag)
        if flags == nil {
          throw ParseError.badCompressionFlags
        }
        header.compressionFlags = flags!
      case .masterSeed:
        header.masterSeed = [UInt8](headerPayload)
      case .transformSeed:
        header.transformSeed = [UInt8](headerPayload)
      case .transformRounds:
        header.transformRounds = headerPayload.toUInt64()
      case .encryptionIV:
        header.encryptionIV = [UInt8](headerPayload)
      case .protectedStreamKey:
        header.protectedStreamKey = [UInt8](headerPayload)
      case .streamStartBytes:
        header.streamStartBytes = [UInt8](headerPayload)
      case .innerRandomStreamID:
        header.innerRandomStreamID = headerPayload.toUInt32()
      }
    }
    
    // We have the information we need to decrypt the payload. Start by
    // concatenating the key composites (password, keyfiles, etc)
    // We use the sha256 hash of the password to get its bytes.
    print("Creating composite key...")
    let concatBytes = filePassword.sha256()
    
    // TODO: Support composites besides passwords
    let compositeKey = concatBytes.sha256()
    
    // Create the transformed and master key. We take the transformSeed to make
    // an AES-256 context, then encrypt the composite key the specified amount
    // in transformRounds. Finally, take the sha256 hash.
    print("Creating the master key...")
    var masterKey: [UInt8]
    // The specification calls for 16 null bytes.
    let iv = [UInt8](Data(repeating: 0x00, count: 16))

    guard let transformSeed = header.transformSeed else {
      throw ParseError.badKDBXFile
    }
    guard let transformRounds = header.transformRounds else {
      throw ParseError.badKDBXFile
    }
    guard let masterSeed = header.masterSeed else {
      throw ParseError.badKDBXFile
    }
    
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
    let encryptionIVArray = header.encryptionIV
    
    guard let AESDecryptContext = AES(operation: .Decrypt,
                                      padding: true,
                                      key: masterKeyArray,
                                      iv: encryptionIVArray) else {
      throw ParseError.couldntCreateCryptoContext
    }

    let encryptedPayload = [UInt8](bytes[cb...])
    let decryptedPayload = AESDecryptContext.performOperation(encryptedPayload)

    let actualStartBytes = [UInt8](decryptedPayload[..<32])
    if header.streamStartBytes != actualStartBytes {
      throw ParseError.badStreamStartBytes(actualStartBytes: actualStartBytes)
    }
    
    cb = 32
    var payload = [UInt8]()
    while true {
      cb += 4 // block ID
      let blockHash = decryptedPayload[cb..<cb + 32]; cb += 32
      guard let validBlockSize = decryptedPayload[cb..<cb + 4].toUInt32() else {
        throw ParseError.badKDBXFile
      }
      let blockSize = Int(validBlockSize); cb += 4
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
    if header.compressionFlags == .GZIP {
      do {
        decompressedPayload = try [UInt8](Data(payload).gunzipped())
      } catch {
        throw ParseError.couldntDecompressPayload
      }
    }

//    guard let payloadString = String(bytes: decompressedPayload, encoding: .utf8) else {
//      throw ParseError.badPayloadString
//    }
    self.payload = Data(decompressedPayload)
  }
  
  func generateKDBX3HeaderBytes() -> [UInt8] {
    var headerBytes = [UInt8]()
    headerBytes.append(contentsOf: KDBXCryptoHandler.KDBX3_MAGIC)
    headerBytes.append(contentsOf: header.secondaryID.toBytes())
    headerBytes.append(contentsOf: header.minorVersion.toBytes())
    headerBytes.append(contentsOf: header.majorVersion.toBytes())
    
    let cipherID = KDBX3HeaderEntry(id: 2, payload: header.cipherID)
    headerBytes.append(contentsOf: cipherID.bytes())

    let compressionFlags = KDBX3HeaderEntry(id: 3, payload: header.compressionFlags!.rawValue.toBytes())
    headerBytes.append(contentsOf: compressionFlags.bytes())
    
    let masterSeed = KDBX3HeaderEntry(id: 4, payload: header.masterSeed)
    headerBytes.append(contentsOf: masterSeed.bytes())
    
    let transformSeed = KDBX3HeaderEntry(id: 5, payload: header.transformSeed)
    headerBytes.append(contentsOf: transformSeed.bytes())
    
    let transformRounds = KDBX3HeaderEntry(id: 6, payload: header.transformRounds!.toBytes())
    headerBytes.append(contentsOf: transformRounds.bytes())
    
    let encryptionIV = KDBX3HeaderEntry(id: 7, payload: header.encryptionIV)
    headerBytes.append(contentsOf: encryptionIV.bytes())
    
    let protectedStreamKey = KDBX3HeaderEntry(id: 8, payload: header.protectedStreamKey)
    headerBytes.append(contentsOf: protectedStreamKey.bytes())
    
    let streamStartBytes = KDBX3HeaderEntry(id: 9, payload: header.streamStartBytes)
    headerBytes.append(contentsOf: streamStartBytes.bytes())
    
    let innerRandomStreamID = KDBX3HeaderEntry(id: 10, payload: header.innerRandomStreamID!.toBytes())
    headerBytes.append(contentsOf: innerRandomStreamID.bytes())
    
    return headerBytes
  }
  
  func encryptPayload() throws -> [UInt8] {
    // Start by generating a fresh header for the container.
    var fileBytes = generateKDBX3HeaderBytes()
    
    // Recompress the payload.
    do {
      let compressedPayload = try [UInt8](payload.gzipped())
    } catch {
      throw EncryptError.couldntCompress
    }
    
    return fileBytes
  }
}
