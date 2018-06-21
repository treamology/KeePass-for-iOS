//
//  DatabaseViewController.swift
//  KeePass
//
//  Created by Donny Lawrence on 6/20/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import UIKit
import KeePassSupport

class DatabaseViewController: UITableViewController {
  
  var document: KDBXDocument!
  var database: KDBXDatabase!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.title = document.localizedName
  }
  
  // MARK: - Table View
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return database.groups.count
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    let group = database.groups[section]
    return group.name
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let group = database.groups[section]
    return group.entries.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let entry = database.groups[indexPath.section].entries[indexPath.row]
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "DatabaseEntryCell", for: indexPath) as! DatabaseEntryTableViewCell
    cell.nameLabel!.text = entry.name
    cell.siteLabel!.text = entry.website
    return cell
  }
  
}
