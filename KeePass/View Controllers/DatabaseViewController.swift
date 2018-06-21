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
  
  weak var baseGroup: KDBXGroup!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = document.localizedName
    
    baseGroup = database.groups[0]
  }
  
  // MARK: - Table View
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return baseGroup.childGroups.count + 1
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return nil
    }
    let group = baseGroup.childGroups[section - 1]
    return group.name
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    var group: KDBXGroup!
    if section == 0 {
      group = baseGroup
    } else {
      group = baseGroup.childGroups[section - 1]
    }
    
    return group.entries.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let entry: KDBXEntry!
    if indexPath.section == 0 {
      entry = baseGroup.entries[indexPath.row]
    } else {
      entry = baseGroup.childGroups[indexPath.section - 1].entries[indexPath.row]
    }
    
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "DatabaseEntryCell", for: indexPath) as! DatabaseEntryTableViewCell
    cell.nameLabel!.text = entry.name
    cell.siteLabel!.text = entry.website
    return cell
  }
  
}
