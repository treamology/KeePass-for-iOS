//
//  KDBXFile.swift
//  KeePassSupport
//
//  Created by Donny Lawrence on 9/26/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import Foundation
import Gzip
import AEXML

public class KDBXFileMagician {
  public static func kdbxFile(withBytes bytes: [UInt8], password: [UInt8]?, keyfile: [UInt8]?) throws -> KDBXFile {
    let magic = [UInt8](bytes[0...3])
    if magic == KDBX3File.MAGIC {
      return try KDBX3File(withFileBytes: bytes, password: password, keyfile: keyfile)
    } // TODO: Logic for KDBX4 file
    throw KDBX3File.ParseError.badKDBXFile
  }
}

public protocol KDBXFile: AnyObject {
  static var MAGIC: [UInt8] { get }
  static var HEADER_SIZE: UInt8 { get }
  
  var header: KDBXHeader { get }
  var payloadBytes: [UInt8]? { get }
  var database: KDBXDatabase? { get set }
  
  var filePasswordBytes: [UInt8]? { get set }
  var keyfileBytes: [UInt8]? { get set }
  
  init?(withHeader header: KDBXHeader)
  init(withFileBytes bytes: [UInt8], password: [UInt8]?, keyfile: [UInt8]?) throws
  
  func encryptPayload() throws -> [UInt8]
}

public class KDBX3File: KDBXFile {
  public static let MAGIC: [UInt8] = [0x03,0xD9,0xA2,0x9A]
  public static let HEADER_SIZE: UInt8 = 12
  
  public enum DynHeaderID: UInt8 {
    case end, comment, cipherID, compressionFlags, masterSeed, transformSeed,
    transformRounds, encryptionIV, protectedStreamKey, streamStartBytes,
    innerRandomStreamID
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
    case versionMismatch
  }
  public enum EncryptError: Error {
    case couldntCompress
    case couldntCreateMasterKey
    case randomNumNotAvailable
    case couldntHashPayload
    case invalidDatabaseState
  }
  
  // This pattern is being used because one can't easily specialize protocols in Swift.
  public var header: KDBXHeader
  public var header3: KDBX3Header
  public var payloadBytes: [UInt8]? {
    get {
      guard let utf = database?.xmlDocument.xml.utf8 else {
        return nil
      }
      return [UInt8](utf)
    }
  }
  public var database: KDBXDatabase?
  
  public var filePasswordBytes: [UInt8]?
  public var keyfileBytes: [UInt8]?

  var masterKey: [UInt8]?
  
  var headerLength: Int?
  public var headerSHA: String? {
    get {
      guard let headerLength = headerLength, let keyfileBytes = keyfileBytes else {
        return nil
      }
      let sha = keyfileBytes[0..<headerLength].sha256()
      return String(bytes: sha, encoding: .utf8)
    }
  }
  
  public init(withExistingDatabase: KDBXDatabase) throws {
    self.header3 = try KDBX3Header.generateValidHeader()
    self.header = self.header3
    
  }
  
  required public init?(withHeader header: KDBXHeader) {
    guard header is KDBX3Header else {
      return nil
    }
    self.header = header
    self.header3 = header as! KDBX3Header
  }
  
  required public init(withFileBytes bytes: [UInt8], password: [UInt8]?, keyfile: [UInt8]?) throws {
    guard bytes.count >= 12 else {
      throw ParseError.badKDBXFile
    }
    
    // Make sure we're actually getting a KDBX file.
    let magic = [UInt8](bytes[0...3])
    guard magic == KDBX3File.MAGIC else {
      throw ParseError.versionMismatch
    }
    
    let header = KDBX3Header()
    self.header = header
    self.header3 = header
    
    
    filePasswordBytes = password
    keyfileBytes = keyfile
    
    header.secondaryID = bytes[4...7].toUInt32()!
    
    header.minorVersion = bytes[8...9].toUInt16()!
    header.majorVersion = bytes[10...11].toUInt16()!
    
    // Parse the dynamic header. The headers can appear in different orders
    // and some can be missing.
    print("Parsing dynamic header...")
    var reachedHeaderEnd = false
    var cb = Int(KDBX3File.HEADER_SIZE) // current byte
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
        header.headerEndBytes = [UInt8](headerPayload)
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
          KDBX3Header.CompressionFlags(rawValue:rawFlag)
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
        header.innerRandomStreamID = KDBX3Header.InnerRandomStreamID(rawValue: headerPayload.toUInt32() ?? 0)
      }
    }
    
    // We have the information we need to decrypt the payload. Start by
    // concatenating the key composites (password, keyfiles, etc)
    // We use the sha256 hash of the password to get its bytes.
    print("Creating composite key...")
    let compositeKey = generateCompositeKey(password: password, keyfileBytes: keyfile)
    
    masterKey = try generateMasterKey(compositeKey: compositeKey)
    
    // Now that we have the master key, we can split up the payload
    print("Decrypting payload...")
    let encryptionIVArray = header.encryptionIV
    
    guard let AESDecryptContext = AES(operation: .Decrypt,
                                      padding: true,
                                      key: masterKey!,
                                      iv: encryptionIVArray) else {
                                        throw ParseError.couldntCreateCryptoContext
    }
    
    headerLength = cb
    
    let encryptedPayload = [UInt8](bytes[cb...])
    let decryptedPayload = AESDecryptContext.performOperation(encryptedPayload)
    
    let actualStartBytes = [UInt8](decryptedPayload[..<32])
    if header.streamStartBytes != actualStartBytes {
      // This probably means that the keyfile/password is invalid.
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
    
    database = KDBXDatabase(withXML: decompressedPayload, andFile: self)
    self.header = header
    self.header3 = header
  }
  
  public func encryptPayload() throws -> [UInt8] {
    guard let database = database else {
      throw EncryptError.invalidDatabaseState
    }
    
    // Start by generating a fresh header for the container.
    var fileBytes = header.bytes
    
    // Recompress the payload.
    let compressedPayload: [UInt8]
    do {
      compressedPayload = try [UInt8](Data(payloadBytes!).gzipped())
    } catch {
      throw EncryptError.couldntCompress
    }
    
    let headerHash = header.bytes.sha256()
    let headerHashElem = database.xmlDocument.root["Meta"]["HeaderHash"]
    if headerHashElem.error != nil {
      database.xmlDocument.root["Meta"].addChild(AEXMLElement(name: "HeaderHash"))
    }
    database.xmlDocument.root["Meta"]["HeaderHash"].value = Data(headerHash).base64EncodedString()
    
    if masterKey == nil {
      do {
        masterKey = try generateMasterKey(compositeKey: generateCompositeKey(password: filePasswordBytes, keyfileBytes: keyfileBytes))
      } catch {
        throw EncryptError.couldntCreateMasterKey
      }
    }
    
    // Encrypt the payload.
    guard let AESEncryptContext = AES(operation: .Encrypt,
                                      padding: true,
                                      key: masterKey!,
                                      iv: header3.encryptionIV) else {
                                        throw ParseError.couldntCreateCryptoContext
    }
    
    let payloadHash = compressedPayload.sha256()
    var payloadPayload: [UInt8] = []
    payloadPayload.append(contentsOf: header3.streamStartBytes)
    payloadPayload.append(contentsOf: [UInt8](repeating: 0x00, count: 4)) // payload ID
    payloadPayload.append(contentsOf: payloadHash) // payload hash
    payloadPayload.append(contentsOf: UInt32(compressedPayload.count).toBytes()) // payload length
    payloadPayload.append(contentsOf: compressedPayload) // the payload
    payloadPayload.append(contentsOf: [0x01, 0x00, 0x00, 0x00])
    payloadPayload.append(contentsOf: [UInt8](repeating: 0x00, count: 36)) // blank ID, hash, and length
    
    let encryptedPayload = AESEncryptContext.performOperation(payloadPayload)
    
    fileBytes.append(contentsOf: encryptedPayload)
    
    return fileBytes
  }
  
  public func generateMasterKey(compositeKey: [UInt8]) throws -> [UInt8] {
    // Create the transformed and master key. We take the transformSeed to make
    // an AES-256 context, then encrypt the composite key the specified amount
    // in transformRounds. Finally, take the sha256 hash.
    print("Creating the master key...")
    var masterKey: [UInt8]
    // The specification calls for 16 null bytes.
    let iv = [UInt8](Data(repeating: 0x00, count: 16))
    
    guard let transformSeed = header3.transformSeed else {
      throw ParseError.badKDBXFile
    }
    guard let transformRounds = header3.transformRounds else {
      throw ParseError.badKDBXFile
    }
    guard let masterSeed = header3.masterSeed else {
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
    return masterKey
  }
  
  func generateCompositeKey(password: [UInt8]?, keyfileBytes: [UInt8]?) -> [UInt8] {
    var concat: [UInt8] = []
    if password != nil {
      concat.append(contentsOf: password!.sha256())
    }
    if keyfileBytes != nil {
      concat.append(contentsOf: keyfileBytes!)
    }
    return concat.sha256()
  }
}
