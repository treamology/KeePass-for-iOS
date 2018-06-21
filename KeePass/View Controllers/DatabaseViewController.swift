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
  
  @IBOutlet var passwordCopiedView: UIView!
  @IBOutlet var tableView: UITableView!
  
  var document: KDBXDocument?
  var database: KDBXDatabase!
  
  weak var baseGroup: KDBXGroup!
  
  var playingAnimation = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if baseGroup == nil {
      navigationItem.title = document!.localizedName
      baseGroup = database.groups[0]
    } else {
      navigationItem.title = baseGroup.name
    }
    
    passwordCopiedView.isHidden = true
    passwordCopiedView.alpha = 0
    passwordCopiedView.layer.cornerRadius = 8
  }
  
  func fadeawayAnimation() {
    passwordCopiedView.layer.removeAllAnimations()
    UIView.animate(withDuration: 0.1, delay: 2, options: .curveLinear, animations: {
      self.passwordCopiedView.alpha = 0
    }, completion: { (finished) in
      if finished {
        self.passwordCopiedView.isHidden = true
        self.playingAnimation = false
      }
    })
  }
  
  func passwordCopiedPopup() {
    playingAnimation = true
    passwordCopiedView.isHidden = false
    UIView.animate(withDuration: 0.1, animations: {
      self.passwordCopiedView.alpha = 1
    }) { (finished) in
      self.fadeawayAnimation()
    }
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
    return group.name
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath)
    if cell?.reuseIdentifier == "GroupCell" {
      // If the user selects a group, drill into it.
      let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
      let vc = storyboard.instantiateViewController(withIdentifier: "DatabaseViewController") as! DatabaseViewController
      vc.baseGroup = baseGroup.childGroups[indexPath.section - 1].childGroups[indexPath.row]
      navigationController?.pushViewController(vc, animated: true)
    } else {
      if playingAnimation {
        fadeawayAnimation()
      } else {
        passwordCopiedPopup()
      }
      tableView.deselectRow(at: indexPath, animated: true)
    }
  }
}
