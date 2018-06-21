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
  
  var document: KDBXDocument?
  var database: KDBXDatabase!
  
  weak var baseGroup: KDBXGroup!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if baseGroup == nil {
      navigationItem.title = document!.localizedName
      baseGroup = database.groups[0]
    } else {
      navigationItem.title = baseGroup.name
    }
  }
  
  // MARK: - Table View
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let groupHeight: CGFloat = 44
    let entryHeight: CGFloat = 58
    if indexPath.section == 0 {
      return entryHeight
    } else {
      if indexPath.row < baseGroup.childGroups[indexPath.section - 1].childGroups.count {
        return groupHeight
      }
    }
    return entryHeight
  }
  
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
    var count: Int!
    if section == 0 {
      group = baseGroup
      count = group.entries.count
    } else {
      group = baseGroup.childGroups[section - 1]
      count = group.childGroups.count + group.entries.count
    }
    
    return count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let entry: KDBXEntry!
    if indexPath.section == 0 {
      entry = baseGroup.entries[indexPath.row]
    } else {
      let group = baseGroup.childGroups[indexPath.section - 1]
      if indexPath.row < group.childGroups.count {
        let childGroup = group.childGroups[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath) as! GroupTableViewCell
        cell.groupName.text = childGroup.name
        if childGroup.name == "" {
          cell.groupName.text = "(no name)"
        }
        return cell
      }
      entry = group.entries[indexPath.row - group.childGroups.count]
    }
    
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "DatabaseEntryCell", for: indexPath) as! DatabaseEntryTableViewCell
    cell.nameLabel!.text = entry.name
    cell.siteLabel!.text = entry.username
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath)
    if cell?.reuseIdentifier == "GroupCell" {
      let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
      let vc = storyboard.instantiateViewController(withIdentifier: "DatabaseViewController") as! DatabaseViewController
      vc.baseGroup = baseGroup.childGroups[indexPath.section - 1].childGroups[indexPath.row]
      navigationController?.pushViewController(vc, animated: true)
    }
  }
}
