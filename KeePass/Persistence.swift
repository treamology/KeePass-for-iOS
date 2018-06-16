//
//  Persistence.swift
//  KeePass
//
//  Created by Donny Lawrence on 6/15/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import Foundation

class Persistence {
  // Keeps track of application state that persists across exits. Encapsulates both
  // the local UserDefaults store and the iCloud store, and resolves conflicts between
  // the two. Any time a value is changed, the time is recorded to be able to add and delete
  // items across multiple devices correctly.
  
  typealias ValueChange = (added: Bool, value: Any)
  enum PersistenceKey: String {
    case lastUpdate, bookmarkedFiles
  }
  
  static func registerForCloudNotifications() {
    // It doensn't matter if we're logged into iCloud or not to call this.
    // The keystore only syncs when it wants to, so we have to do some weird stuff
    // to make sure changes are propagated correctly.
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(cloudDataChanged),
                                           name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                                           object: NSUbiquitousKeyValueStore.default)
    NSUbiquitousKeyValueStore.default.synchronize()
  }
  
  private static func setValueLocally(object: Any?, forKey key: String) {
    UserDefaults.standard.set(object, forKey: key)
    UserDefaults.standard.set(NSDate.timeIntervalSinceReferenceDate, forKey: PersistenceKey.lastUpdate.rawValue)
    NSUbiquitousKeyValueStore.default.set(object, forKey: key)
    NSUbiquitousKeyValueStore.default.set(NSDate.timeIntervalSinceReferenceDate, forKey: PersistenceKey.lastUpdate.rawValue)
  }
  
  static func addFileBookmark(bookmark: NSData) {
    var currentBookmarks = UserDefaults.standard.array(forKey: PersistenceKey.bookmarkedFiles.rawValue)
    currentBookmarks?.append(bookmark)
    setValueLocally(object: currentBookmarks, forKey: PersistenceKey.bookmarkedFiles.rawValue)
  }
  
  static func removeFileBookmark(index: Int) {
    var currentBookmarks = UserDefaults.standard.array(forKey: PersistenceKey.bookmarkedFiles.rawValue)
    currentBookmarks?.remove(at: index)
    setValueLocally(object: currentBookmarks, forKey: PersistenceKey.bookmarkedFiles.rawValue)
  }
  
  @objc static func cloudDataChanged(notification: NSNotification) {
    guard let userInfo = notification.userInfo else { return }
    let currentDefaults = UserDefaults.standard
    let remoteValues = NSUbiquitousKeyValueStore.default
    
    let changeReason = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] as! Int
    let changedKeys = userInfo[NSUbiquitousKeyValueStoreChangedKeysKey] as! Array<String>
   
    switch changeReason {
    case NSUbiquitousKeyValueStoreServerChange:
      // Something was changed from some other device, so update our local copy.
      for key in changedKeys {
        guard let persistenceKey = PersistenceKey(rawValue: key) else {
          return
        }
        switch persistenceKey {
        case .bookmarkedFiles:
          var localBookmarks = currentDefaults.array(forKey: key) as! Array<Data>
          let remoteBookmarks = remoteValues.array(forKey: key) as! Array<Data>
          
          // Add any new additions we don't know about.
          let additions = Set(remoteBookmarks).subtracting(localBookmarks)
          localBookmarks.append(contentsOf: additions)
          currentDefaults.set(localBookmarks, forKey: key)
          
          let deletions = Set(localBookmarks).subtracting(remoteBookmarks)
          let lastRemoteUpdate = remoteValues.value(forKey: PersistenceKey.lastUpdate.rawValue) as! Int
          let lastLocalUpdate = currentDefaults.value(forKey: PersistenceKey.lastUpdate.rawValue) as! Int
          if lastRemoteUpdate > lastLocalUpdate {
            // The remote deletions are more recent, so have them correspond locally.
            var localDeletedSet = Set(localBookmarks)
            localDeletedSet.subtract(deletions)
            let localDeleted = Array(localDeletedSet)
            currentDefaults.set(localDeleted, forKey: key)
            currentDefaults.set(NSDate.timeIntervalSinceReferenceDate, forKey: PersistenceKey.lastUpdate.rawValue)
          } else {
            // We have added bookmarks since the last time the other device sent something out,
            // so push them to the other devices.
            remoteValues.set(localBookmarks, forKey: key)
            remoteValues.set(NSDate.timeIntervalSinceReferenceDate, forKey: PersistenceKey.lastUpdate.rawValue)
          }
        case .lastUpdate:
          break
        }
      }
    case NSUbiquitousKeyValueStoreInitialSyncChange | NSUbiquitousKeyValueStoreAccountChange:
      // We're just now syncing all of the values for the first time, so add the differences
      // and sync them with the server.
      for key in changedKeys {
        guard let persistenceKey = PersistenceKey(rawValue: key) else {
          return
        }
        switch persistenceKey {
        case .bookmarkedFiles:
          var localBookmarks = currentDefaults.array(forKey: key) as! Array<Data>
          let remoteBookmarks = remoteValues.array(forKey: key) as! Array<Data>
          localBookmarks.append(contentsOf: remoteBookmarks)
          setValueLocally(object: localBookmarks, forKey: key)
        case .lastUpdate:
          break
        }
      }
    default:
      // This really shouldn't happen...
      return
    }
  }
}
