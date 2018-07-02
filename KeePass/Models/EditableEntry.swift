//
//  EditableEntry.swift
//  KeePassSupport
//
//  Created by Donny Lawrence on 7/1/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import Foundation

public protocol EditableEntry {
  var entryNames: [String] { get }
  var currentEntryValues: [String?] { get }
}
