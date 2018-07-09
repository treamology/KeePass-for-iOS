//
//  FileManagement.swift
//  KeePassSupport
//
//  Created by Donny Lawrence on 6/14/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import Foundation
import AEXML

class FileManagement {
  static var filesManager = FileManager.default
  static var signedIntoCloud = false
  static var documentsURL: URL?
  
  static var currentOpenFile: KDBXDocument?
  
  static func checkCloudStatus() {
    // Choose the location to store new databases depending on if the user is signed into iCloud
    // or not.
    if filesManager.ubiquityIdentityToken != nil {
      print("Signed into iCloud")
      signedIntoCloud = true
      DispatchQueue.global(qos: .background).async {
        print("Getting the documents folder URL...")
        // Passing nil gives the first one in the list
        self.documentsURL = self.filesManager.url(forUbiquityContainerIdentifier: nil)
        
        // So for some reason you need to make a Documents directory within your
        // app's iCloud folder. It doesn't actually show in the UI, but you need
        // it in order for the files you save to actually show up.
        self.documentsURL = self.documentsURL?.appendingPathComponent("Documents", isDirectory: true)
        do {
          try self.filesManager.createDirectory(at: self.documentsURL!,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
        } catch {
          print("Couldn't create the documents directory")
          self.signedIntoCloud = false
        }
      }
    } else {
      print("Not signed into iCloud")
      let urls = self.filesManager.urls(for: .documentDirectory, in: .userDomainMask)
      print(urls)
      // FIXME: Is it always the first one of these?
      documentsURL = urls[0]
    }
  }
  
  static func createNewDatabase(name: String, completed: @escaping (Bool) -> Void) {
//    let success = filesManager.createFile(atPath: (documentsURL?.appendingPathComponent("\(name).kdbx",
//      isDirectory: false).path)!,
//                                          contents: Data(bytes: [0, 0, 0, 0]),
//                                          attributes: nil)
    let document = KDBXDocument(fileURL: (documentsURL?.appendingPathComponent("\(name).kdbx", isDirectory: false))!)
    
    let defaultURL = Bundle.main.url(forResource: "Default", withExtension: "xml")
    let defaultData = try! Data(contentsOf: defaultURL!)
    let parsedData = try! AEXMLDocument(xml: defaultData)
    
    
    
    document.save(to: document.fileURL, for: .forCreating) { (success: Bool) in
      if success {
        try! Persistence.addFileBookmark(bookmark: document.fileURL.bookmarkData() as NSData)
      }
      completed(success)
    }
//    print(success)
  }
  
  static func resolveBookmark(bookmark: Data, persistenceIndex: Int?) -> URL? {
    var dataIsStale = false
    var resolved: URL?
    do {
      resolved = try URL(resolvingBookmarkData: bookmark, bookmarkDataIsStale: &dataIsStale)
    } catch {
      print("Couldn't resolve bookmark data")
    }
    if let resolvedURL = resolved {
      if dataIsStale && persistenceIndex != nil {
        do {
          try Persistence.replaceFileBookmark(with: resolvedURL.bookmarkData(), index: persistenceIndex!)
        } catch {
          print("Couldn't create a fresh bookmark for previous stale data.")
        }
      }
      return resolvedURL
    }
    return nil
  }
}
