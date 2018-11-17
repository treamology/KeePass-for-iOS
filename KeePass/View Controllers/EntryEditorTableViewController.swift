//
//  EntryEditorTableViewController.swift
//  KeePass
//
//  Created by Donny Lawrence on 11/17/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import UIKit

class EntryEditorTableViewController: UITableViewController {

  @IBOutlet var entryNameTextbox: UITextField!
  @IBOutlet var usernameTextbox: UITextField!
  @IBOutlet var passwordTextbox: UITextField!
  @IBOutlet var urlTextbox: UITextField!
  @IBOutlet var notesTextfield: UITextView!
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if (segue.identifier == "AddEntry") {
      navigationItem.title = "Add Entry"
    } else if (segue.identifier == "ModifyEntry") {
      navigationItem.title = "Edit Entry"
    }
  }
}
