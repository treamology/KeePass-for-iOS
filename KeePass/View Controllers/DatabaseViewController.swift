//
//  DatabaseViewController.swift
//  KeePass
//
//  Created by Donny Lawrence on 6/20/18.
//  Copyright © 2018 Donny Lawrence. All rights reserved.
//

import UIKit
import KeePassSupport

class DatabaseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  static let STORYBOARD_FILE = "Main"
  
  @IBOutlet var passwordCopiedView: UIView!
  @IBOutlet var tableView: UITableView!
  
  var document: KDBXDocument?
  var database: KDBDatabase!
  
  var baseGroup: KDBGroup!
  
  var copiedViewAnimating = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if baseGroup == nil {
      navigationItem.title = document!.localizedName
      baseGroup = database.groups![0]
    } else {
      navigationItem.title = baseGroup.groupName
    }
    
    passwordCopiedView.isHidden = true
    passwordCopiedView.alpha = 0
    passwordCopiedView.layer.cornerRadius = 8
  }
  
  func fadeawayAnimation() {
    UIView.animate(withDuration: 0.1, delay: 2, options: .curveLinear, animations: {
      self.passwordCopiedView.alpha = 0
    }, completion: { (finished) in
      if finished {
        self.passwordCopiedView.isHidden = true
        self.copiedViewAnimating = false
      }
    })
  }
  
  func passwordCopiedPopup() {
    passwordCopiedView.isHidden = false
    if !copiedViewAnimating {
      copiedViewAnimating = true
      UIView.animate(withDuration: 0.1, animations: {
        self.passwordCopiedView.alpha = 1
      }) { (finished) in
        self.fadeawayAnimation()
      }
    } else {
      passwordCopiedView.layer.removeAllAnimations()
      passwordCopiedView.alpha = 1
      fadeawayAnimation()
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "DrillDownSegue" {
      let indexPath = tableView.indexPathForSelectedRow!
      let dest = segue.destination as! DatabaseViewController
      dest.baseGroup = baseGroup.childGroups[indexPath.section - 1].childGroups[indexPath.row]
    }
    #if !EXTENSION
//    if segue.identifier == "EditDatabase" {
//      let controller = (segue.destination as! UINavigationController).topViewController as! EntryDetailsViewController
//      controller.entryType = .Password
//    }
    #endif
  }
  
  // MARK: - Table View
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    // Child groups display at the top of the list, while entries are always after.
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
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return baseGroup.childGroups.count + 1
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return nil
    }
    let group = baseGroup.childGroups[section - 1]
    return group.groupName
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    var group: KDBGroup!
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
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let entry: KDBEntry!
    if indexPath.section == 0 {
      entry = baseGroup.entries[indexPath.row]
    } else {
      let group = baseGroup.childGroups[indexPath.section - 1]
      if indexPath.row < group.childGroups.count {
        let childGroup = group.childGroups[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath) as! GroupTableViewCell
        cell.groupName.text = childGroup.groupName
        if childGroup.groupName == "" {
          cell.groupName.text = "(no name)"
        }
        return cell
      }
      entry = group.entries[indexPath.row - group.childGroups.count]
    }
    
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "DatabaseEntryCell", for: indexPath) as! DatabaseEntryTableViewCell
    cell.nameLabel!.text = entry.name
    cell.siteLabel!.text = entry.username
    #if EXTENSION
    cell.accessoryType = .none
    #endif
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath)
    if cell?.reuseIdentifier == "DatabaseEntryCell" {
      passwordCopiedPopup()
      
      let group: KDBGroup!
      if indexPath.section == 0 {
        group = baseGroup
      } else {
        group = baseGroup.childGroups[indexPath.section - 1]
      }
      let entry = group.entries[indexPath.row - group.childGroups.count]
      let pasteboard = UIPasteboard.general
      pasteboard.string = entry.password
    }
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
