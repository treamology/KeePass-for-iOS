//
//  EntryDetailsViewController.swift
//  KeePass
//
//  Created by Donny Lawrence on 6/30/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import KeePassSupport
import UIKit

class EntryDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

  static let STORYBOARD_FILE = "Main"
  enum EntryType {
    case Database, Group, Password
  }
  
  @IBOutlet var tableView: UITableView!
  
  struct Identifiers {
    static let textboxReuseIdentifier = "TextboxTableViewCell"
  }
  
  var entryType: EntryType! = EntryType.Database
  // Only one of these will exist at a time depending on what the entry is.
  var entry: EditableEntry!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = entry.currentEntryValues[0]
  }
  
  // MARK: - Table View
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // This might change
    return 1
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return entry.entryNames.count
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return entry.entryNames[section]
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.textboxReuseIdentifier, for: indexPath) as! TextboxTableViewCell
    cell.textbox.text = entry.currentEntryValues[indexPath.section]
    if indexPath.section == 0 {
      cell.textbox.delegate = self
    }
    return cell
  }
  
  // MARK: - Text Field
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let nsString = textField.text as NSString?
    let newString = nsString?.replacingCharacters(in: range, with: string)
    navigationItem.title = newString
    return true
  }
}
