//
//  EntryDetailsViewController.swift
//  KeePass
//
//  Created by Donny Lawrence on 6/30/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import Foundation
import UIKit

class EntryDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

  static let STORYBOARD_FILE = "Main"
  
  @IBOutlet var tableView: UITableView!

  struct Identifiers {
    static let textboxReuseIdentifier = "TextboxTableViewCell"
  }
  
  let sectionTitles = [
    "Title"
  ]
  let cells = [
    [Identifiers.textboxReuseIdentifier]
  ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: - Table View
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return cells[section].count
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return sectionTitles.count
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return sectionTitles[section]
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let identifier = cells[indexPath.section][indexPath.row]
    var cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
    
    return cell
  }
}
